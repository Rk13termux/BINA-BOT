import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';
import 'binance_service.dart';

/// Modelo para análisis de trading AI
class AITradingAnalysis {
  final String symbol;
  final String timeframe;
  final String trend;
  final double confidence;
  final String analysis;
  final String motivation;
  final String recommendation;
  final List<String> activeIndicators;
  final Map<String, dynamic> portfolioAnalysis;
  final DateTime timestamp;
  final String riskLevel;
  final double sentimentScore;

  AITradingAnalysis({
    required this.symbol,
    required this.timeframe,
    required this.trend,
    required this.confidence,
    required this.analysis,
    required this.motivation,
    required this.recommendation,
    required this.activeIndicators,
    required this.portfolioAnalysis,
    required this.timestamp,
    required this.riskLevel,
    required this.sentimentScore,
  });

  factory AITradingAnalysis.fromJson(Map<String, dynamic> json) {
    return AITradingAnalysis(
      symbol: json['symbol'] ?? '',
      timeframe: json['timeframe'] ?? '1h',
      trend: json['trend'] ?? 'NEUTRAL',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      analysis: json['analysis'] ?? '',
      motivation: json['motivation'] ?? '',
      recommendation: json['recommendation'] ?? '',
      activeIndicators: List<String>.from(json['active_indicators'] ?? []),
      portfolioAnalysis: json['portfolio_analysis'] ?? {},
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      riskLevel: json['risk_level'] ?? 'MEDIUM',
      sentimentScore: (json['sentiment_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'timeframe': timeframe,
      'trend': trend,
      'confidence': confidence,
      'analysis': analysis,
      'motivation': motivation,
      'recommendation': recommendation,
      'active_indicators': activeIndicators,
      'portfolio_analysis': portfolioAnalysis,
      'timestamp': timestamp.toIso8601String(),
      'risk_level': riskLevel,
      'sentiment_score': sentimentScore,
    };
  }
}

/// Modelo para interacción conversacional con la IA
class AIConversation {
  final String id;
  final String message;
  final String response;
  final DateTime timestamp;
  final String context;
  final bool isUserMessage;

  AIConversation({
    required this.id,
    required this.message,
    required this.response,
    required this.timestamp,
    required this.context,
    required this.isUserMessage,
  });

  factory AIConversation.fromJson(Map<String, dynamic> json) {
    return AIConversation(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      response: json['response'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      context: json['context'] ?? '',
      isUserMessage: json['is_user_message'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'response': response,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'is_user_message': isUserMessage,
    };
  }
}

/// Servicio profesional de IA con Groq para trading
class ProfessionalAIService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _apiKeyKey = 'groq_api_key';
  
  String? _apiKey;
  bool _isConnected = false;
  bool _isAnalyzing = false;
  AITradingAnalysis? _currentAnalysis;
  List<AIConversation> _conversationHistory = [];
  
  // Referencias a otros servicios
  late BinanceService _binanceService;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isAnalyzing => _isAnalyzing;
  AITradingAnalysis? get currentAnalysis => _currentAnalysis;
  List<AIConversation> get conversationHistory => List.unmodifiable(_conversationHistory);
  
  /// Inicializar el servicio AI
  Future<void> initialize(BinanceService binanceService) async {
    _binanceService = binanceService;
    await _loadApiKey();
    if (_apiKey != null) {
      await _testConnection();
    }
  }
  
  /// Cargar API key desde almacenamiento seguro
  Future<void> _loadApiKey() async {
    try {
      _apiKey = await _storage.read(key: _apiKeyKey);
      _logger.info('Groq AI API key loaded');
    } catch (e) {
      _logger.error('Error loading Groq AI API key: $e');
    }
  }
  
  /// Configurar API key
  Future<bool> setApiKey(String apiKey) async {
    try {
      await _storage.write(key: _apiKeyKey, value: apiKey);
      _apiKey = apiKey;
      
      final success = await _testConnection();
      if (success) {
        _logger.info('Groq AI API key configured successfully');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.error('Error configuring Groq AI API key: $e');
      return false;
    }
  }
  
  /// Probar conexión con Groq AI
  Future<bool> _testConnection() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'user',
              'content': 'Test connection. Respond with "Connection OK".'
            }
          ],
          'max_tokens': 10,
        }),
      );
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _logger.info('Groq AI connection established');
      } else {
        _isConnected = false;
        _logger.error('Groq AI connection failed: ${response.statusCode}');
      }
    } catch (e) {
      _isConnected = false;
      _logger.error('Error testing Groq AI connection: $e');
    }
    
    notifyListeners();
    return _isConnected;
  }
  
  /// Analizar mercado con IA profesional
  Future<AITradingAnalysis?> analyzeMarket({
    required String symbol,
    required String timeframe,
    required List<String> activeIndicators,
    Map<String, dynamic>? portfolioData,
  }) async {
    if (!_isConnected || _apiKey == null) {
      _logger.warning('Groq AI not connected or configured');
      return null;
    }
    
    _isAnalyzing = true;
    notifyListeners();
    
    try {
      // Obtener datos del portfolio si está disponible
      Map<String, dynamic> portfolio = portfolioData ?? {};
      if (_binanceService.isAuthenticated && portfolio.isEmpty) {
        portfolio = await _getBinancePortfolioData();
      }
      
      // Crear el prompt profesional para análisis
      final prompt = _buildAnalysisPrompt(symbol, timeframe, activeIndicators, portfolio);
      
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 2000,
          'temperature': 0.7,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final analysis = _parseAIResponse(data['choices'][0]['message']['content'], symbol, timeframe, activeIndicators, portfolio);
        _currentAnalysis = analysis;
        
        _logger.info('AI market analysis completed for $symbol');
        return analysis;
      } else {
        _logger.error('AI analysis failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('Error during AI market analysis: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }
  
  /// Chat conversacional con el asistente AI
  Future<String?> chatWithAssistant(String message, {String? context}) async {
    if (!_isConnected || _apiKey == null) {
      return 'Lo siento, no estoy conectado al servicio de IA. Por favor, configura tu API key de Groq.';
    }
    
    try {
      // Agregar contexto del portfolio y análisis actual
      String fullContext = context ?? '';
      if (_currentAnalysis != null) {
        fullContext += '\\n\\nAnálisis actual: ${_currentAnalysis!.symbol} - ${_currentAnalysis!.trend} (${_currentAnalysis!.confidence}% confianza)';
      }
      
      if (_binanceService.isAuthenticated) {
        final portfolio = await _getBinancePortfolioData();
        fullContext += '\\n\\nPortfolio actual: ${portfolio.toString()}';
      }
      
      final prompt = _buildChatPrompt(message, fullContext);
      
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'mixtral-8x7b-32768',
          'messages': [
            {
              'role': 'system',
              'content': _getChatSystemPrompt(),
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.8,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'];
        
        // Guardar la conversación
        final conversation = AIConversation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: message,
          response: aiResponse,
          timestamp: DateTime.now(),
          context: fullContext,
          isUserMessage: false,
        );
        
        _conversationHistory.add(conversation);
        notifyListeners();
        
        return aiResponse;
      } else {
        _logger.error('AI chat failed: ${response.statusCode}');
        return 'Lo siento, hubo un error al procesar tu mensaje. Inténtalo de nuevo.';
      }
    } catch (e) {
      _logger.error('Error during AI chat: $e');
      return 'Error de conexión. Verifica tu conexión a internet y configuración de API.';
    }
  }
  
  /// Obtener datos del portfolio de Binance
  Future<Map<String, dynamic>> _getBinancePortfolioData() async {
    try {
      if (!_binanceService.isAuthenticated) {
        return {};
      }
      
      final accountInfo = await _binanceService.getAccountInfo();
      
      final balances = accountInfo.balances;
      
      Map<String, dynamic> portfolio = {
        'total_value_usdt': 0.0,
        'assets': <Map<String, dynamic>>[],
        'asset_count': 0,
      };
      
      double totalValue = 0.0;
      int assetCount = 0;
      
      for (var balance in balances) {
        final free = balance.free;
        final locked = balance.locked;
        final total = balance.total;
        
        if (total > 0.0001) { // Solo incluir balances significativos
          portfolio['assets'].add({
            'asset': balance.asset,
            'free': free,
            'locked': locked,
            'total': total,
          });
          assetCount++;
          
          // Calcular valor aproximado en USDT (simplificado)
          if (balance.asset == 'USDT') {
            totalValue += total;
          } else if (balance.asset == 'BTC') {
            totalValue += total * 50000; // Precio aproximado
          } else if (balance.asset == 'ETH') {
            totalValue += total * 3000; // Precio aproximado
          }
        }
      }
      
      portfolio['total_value_usdt'] = totalValue;
      portfolio['asset_count'] = assetCount;
      
      return portfolio;
    } catch (e) {
      _logger.error('Error getting Binance portfolio data: $e');
      return {};
    }
  }
  
  /// Prompt del sistema para análisis
  String _getSystemPrompt() {
    return '''
Eres un asistente profesional de trading de criptomonedas especializado en análisis técnico y fundamental. 
Tu personalidad es carismática, motivadora y profesional. Debes:

1. Analizar datos técnicos con precisión
2. Proporcionar motivación en rachas malas con carisma
3. Felicitar por operaciones ganadoras
4. Recordar que el trading es pasión, no solo dinero
5. Sugerir siempre seguir intentando con gestión de riesgo
6. Ser profesional pero humano en tus respuestas

Responde SIEMPRE en formato JSON con esta estructura:
{
  "trend": "BULLISH|BEARISH|NEUTRAL",
  "confidence": 85.5,
  "analysis": "Análisis técnico detallado",
  "motivation": "Mensaje motivacional personalizado",
  "recommendation": "Recomendación específica",
  "risk_level": "LOW|MEDIUM|HIGH",
  "sentiment_score": 0.75
}
''';
  }
  
  /// Prompt del sistema para chat
  String _getChatSystemPrompt() {
    return '''
Eres un asistente personal de trading llamado "Invictus AI". Tu personalidad es:

- Carismático y motivador
- Profesional pero cercano
- Apasionado por el trading
- Empático en pérdidas, celebrador en ganancias
- Siempre enfocado en el crecimiento personal

Recuerda al usuario que:
- El trading es una pasión, no solo dinero
- Las pérdidas son oportunidades de aprendizaje
- La perseverancia es clave para el éxito
- La gestión de riesgo es fundamental

Responde siempre en español de manera profesional pero amigable.
''';
  }
  
  /// Construir prompt para análisis
  String _buildAnalysisPrompt(String symbol, String timeframe, List<String> indicators, Map<String, dynamic> portfolio) {
    return '''
Analiza la criptomoneda $symbol en timeframe $timeframe.

Indicadores técnicos activos: ${indicators.join(', ')}

Portfolio actual: ${portfolio.isNotEmpty ? portfolio.toString() : 'No disponible'}

Por favor, proporciona:
1. Análisis técnico detallado basado en los indicadores
2. Tendencia del mercado (BULLISH, BEARISH, NEUTRAL)
3. Nivel de confianza (0-100)
4. Mensaje motivacional considerando el estado del portfolio
5. Recomendación específica para esta situación
6. Nivel de riesgo de la operación
7. Sentimiento del mercado (0-1)

Considera el contexto emocional del trading y proporciona motivación apropiada.
''';
  }
  
  /// Construir prompt para chat
  String _buildChatPrompt(String message, String context) {
    return '''
Usuario dice: "$message"

Contexto actual:
$context

Responde como Invictus AI, manteniendo tu personalidad carismática y motivadora.
''';
  }
  
  /// Parsear respuesta de la IA
  AITradingAnalysis _parseAIResponse(String response, String symbol, String timeframe, List<String> indicators, Map<String, dynamic> portfolio) {
    try {
      // Intentar parsear como JSON
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final data = jsonDecode(jsonStr);
        
        return AITradingAnalysis(
          symbol: symbol,
          timeframe: timeframe,
          trend: data['trend'] ?? 'NEUTRAL',
          confidence: (data['confidence'] ?? 50.0).toDouble(),
          analysis: data['analysis'] ?? response,
          motivation: data['motivation'] ?? 'Mantén la disciplina y sigue aprendiendo.',
          recommendation: data['recommendation'] ?? 'Evalúa cuidadosamente antes de actuar.',
          activeIndicators: indicators,
          portfolioAnalysis: portfolio,
          timestamp: DateTime.now(),
          riskLevel: data['risk_level'] ?? 'MEDIUM',
          sentimentScore: (data['sentiment_score'] ?? 0.5).toDouble(),
        );
      }
    } catch (e) {
      _logger.warning('Could not parse AI response as JSON, using fallback: $e');
    }
    
    // Fallback si no se puede parsear como JSON
    return AITradingAnalysis(
      symbol: symbol,
      timeframe: timeframe,
      trend: 'NEUTRAL',
      confidence: 50.0,
      analysis: response,
      motivation: 'El análisis está completo. Recuerda que cada operación es una oportunidad de crecimiento.',
      recommendation: 'Revisa el análisis detallado y toma decisiones informadas.',
      activeIndicators: indicators,
      portfolioAnalysis: portfolio,
      timestamp: DateTime.now(),
      riskLevel: 'MEDIUM',
      sentimentScore: 0.5,
    );
  }
  
  /// Limpiar historial de conversaciones
  void clearConversationHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }
  
  /// Desconectar servicio
  void disconnect() {
    _isConnected = false;
    _apiKey = null;
    _currentAnalysis = null;
    notifyListeners();
  }
}
