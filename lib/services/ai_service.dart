import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Servicio de IA para BINA-BOT PRO usando Groq Cloud con Mistral 7B
class AIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'mixtral-8x7b-32768'; // Modelo Mistral 8x7B optimizado
  static const String _apiKeyStorage = 'groq_api_key';
  
  final AppLogger _logger = AppLogger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final http.Client _httpClient = http.Client();
  
  String? _apiKey;
  bool _isInitialized = false;

  /// Inicializar el servicio de IA
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.info('🤖 Inicializando servicio de IA con Groq...');
      
      // Cargar API key desde almacenamiento seguro
      _apiKey = await _secureStorage.read(key: _apiKeyStorage);
      
      if (_apiKey == null || _apiKey!.isEmpty) {
        _logger.warning('⚠️ No se encontró API key de Groq - Funciones de IA deshabilitadas');
      } else {
        // Verificar conectividad
        final isConnected = await _testConnection();
        if (isConnected) {
          _logger.info('✅ Servicio de IA inicializado correctamente');
        } else {
          _logger.warning('⚠️ Error de conectividad con Groq API');
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      _logger.error('❌ Error inicializando servicio de IA: $e');
      _isInitialized = true;
    }
  }

  /// Configurar API key de Groq
  Future<bool> setApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: _apiKeyStorage, value: apiKey);
      _apiKey = apiKey;
      
      final isValid = await _testConnection();
      if (isValid) {
        _logger.info('✅ API key de Groq configurada correctamente');
        return true;
      } else {
        _logger.error('❌ API key de Groq inválida');
        return false;
      }
    } catch (e) {
      _logger.error('❌ Error configurando API key: $e');
      return false;
    }
  }

  /// Verificar si el servicio está disponible
  bool get isAvailable => _isInitialized && _apiKey != null && _apiKey!.isNotEmpty;

  /// Getter para verificar si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Getter para verificar si tiene API key válida
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  /// Analizar mercado con IA
  Future<AIMarketAnalysis?> analyzeMarket({
    required String symbol,
    required List<Map<String, dynamic>> priceData,
    required Map<String, dynamic> technicalIndicators,
    String? additionalContext,
  }) async {
    if (!isAvailable) {
      _logger.warning('⚠️ Servicio de IA no disponible');
      return null;
    }

    try {
      _logger.info('🤖 Analizando mercado para $symbol...');

      final prompt = _buildMarketAnalysisPrompt(
        symbol: symbol,
        priceData: priceData,
        technicalIndicators: technicalIndicators,
        additionalContext: additionalContext,
      );

      final response = await _makeRequest(prompt);
      if (response == null) return null;

      return _parseMarketAnalysis(response, symbol);
    } catch (e) {
      _logger.error('❌ Error en análisis de mercado: $e');
      return null;
    }
  }

  /// Generar señales de trading
  Future<AITradingSignal?> generateTradingSignal({
    required String symbol,
    required Map<String, dynamic> marketData,
    required String timeframe,
    double? riskTolerance,
  }) async {
    if (!isAvailable) {
      _logger.warning('⚠️ Servicio de IA no disponible');
      return null;
    }

    try {
      _logger.info('🎯 Generando señal de trading para $symbol...');

      final prompt = _buildTradingSignalPrompt(
        symbol: symbol,
        marketData: marketData,
        timeframe: timeframe,
        riskTolerance: riskTolerance,
      );

      final response = await _makeRequest(prompt);
      if (response == null) return null;

      return _parseTradingSignal(response, symbol);
    } catch (e) {
      _logger.error('❌ Error generando señal de trading: $e');
      return null;
    }
  }

  /// Analizar noticias y sentiment
  Future<AISentimentAnalysis?> analyzeNewsSentiment({
    required List<String> newsArticles,
    required String symbol,
  }) async {
    if (!isAvailable) {
      _logger.warning('⚠️ Servicio de IA no disponible');
      return null;
    }

    try {
      _logger.info('📰 Analizando sentiment de noticias para $symbol...');

      final prompt = _buildSentimentAnalysisPrompt(
        newsArticles: newsArticles,
        symbol: symbol,
      );

      final response = await _makeRequest(prompt);
      if (response == null) return null;

      return _parseSentimentAnalysis(response, symbol);
    } catch (e) {
      _logger.error('❌ Error en análisis de sentiment: $e');
      return null;
    }
  }

  /// Crear prompt para análisis de mercado
  String _buildMarketAnalysisPrompt({
    required String symbol,
    required List<Map<String, dynamic>> priceData,
    required Map<String, dynamic> technicalIndicators,
    String? additionalContext,
  }) {
    final priceDataStr = priceData.take(10).map((p) => 
      '- Precio: ${p['close']}, Volumen: ${p['volume']}, Tiempo: ${p['timestamp']}'
    ).join('\n');
    
    final indicatorsStr = technicalIndicators.entries.map((e) => 
      '- ${e.key}: ${e.value}'
    ).join('\n');
    
    return '''
Actúa como un analista profesional de trading de criptomonedas. Analiza los siguientes datos para $symbol:

DATOS DE PRECIO RECIENTES:
$priceDataStr

INDICADORES TÉCNICOS:
$indicatorsStr

CONTEXTO ADICIONAL:
${additionalContext ?? 'Sin contexto adicional'}

Proporciona un análisis estructurado en formato JSON con:
{
  "trend": "alcista|bajista|lateral",
  "strength": 1-10,
  "support_levels": [números],
  "resistance_levels": [números],
  "key_insights": ["insight1", "insight2", "insight3"],
  "risk_assessment": "bajo|medio|alto",
  "time_horizon": "corto|medio|largo",
  "confidence": 1-10,
  "summary": "resumen en español de máximo 200 caracteres"
}

Mantén el análisis objetivo y basado en datos técnicos.
''';
  }

  /// Crear prompt para señales de trading
  String _buildTradingSignalPrompt({
    required String symbol,
    required Map<String, dynamic> marketData,
    required String timeframe,
    double? riskTolerance,
  }) {
    return '''
Actúa como un experto en trading algorítmico. Genera una señal de trading para $symbol en timeframe $timeframe:

DATOS DE MERCADO:
${marketData.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

TOLERANCIA AL RIESGO: ${riskTolerance ?? 'Media (5/10)'}

Genera una señal de trading en formato JSON:
{
  "action": "buy|sell|hold",
  "confidence": 1-10,
  "entry_price": número,
  "stop_loss": número,
  "take_profit": [número1, número2],
  "position_size": 1-10,
  "reasoning": ["razón1", "razón2", "razón3"],
  "risk_reward": número,
  "timeframe": "corto|medio|largo",
  "warning": "texto de advertencia si aplica"
}

Base tu análisis en indicadores técnicos válidos y gestión de riesgo profesional.
''';
  }

  /// Crear prompt para análisis de sentiment
  String _buildSentimentAnalysisPrompt({
    required List<String> newsArticles,
    required String symbol,
  }) {
    final articles = newsArticles.take(5).join('\n\n---\n\n');
    
    return '''
Analiza el sentiment de las siguientes noticias relacionadas con $symbol:

NOTICIAS:
$articles

Proporciona un análisis de sentiment en formato JSON:
{
  "overall_sentiment": "muy_positivo|positivo|neutral|negativo|muy_negativo",
  "sentiment_score": -10 a 10,
  "key_themes": ["tema1", "tema2", "tema3"],
  "market_impact": "alto|medio|bajo",
  "time_sensitivity": "inmediato|corto_plazo|largo_plazo",
  "bullish_factors": ["factor1", "factor2"],
  "bearish_factors": ["factor1", "factor2"],
  "summary": "resumen en español de máximo 200 caracteres"
}

Analiza objetivamente el contenido y su potencial impacto en el precio.
''';
  }

  /// Realizar petición a Groq API
  Future<String?> _makeRequest(String prompt) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.3,
          'top_p': 0.9,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _logger.error('❌ Error en API Groq: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('❌ Error en petición a Groq: $e');
      return null;
    }
  }

  /// Verificar conexión con Groq API
  Future<bool> _testConnection() async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': 'Test connection',
            }
          ],
          'max_tokens': 10,
        }),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Parsear análisis de mercado
  AIMarketAnalysis _parseMarketAnalysis(String response, String symbol) {
    try {
      // Extraer JSON del response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No se encontró JSON válido en la respuesta');
      }
      
      final jsonStr = response.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonStr);
      
      return AIMarketAnalysis(
        symbol: symbol,
        trend: data['trend'] ?? 'lateral',
        strength: (data['strength'] ?? 5).toDouble(),
        supportLevels: List<double>.from(data['support_levels'] ?? []),
        resistanceLevels: List<double>.from(data['resistance_levels'] ?? []),
        keyInsights: List<String>.from(data['key_insights'] ?? []),
        riskAssessment: data['risk_assessment'] ?? 'medio',
        timeHorizon: data['time_horizon'] ?? 'medio',
        confidence: (data['confidence'] ?? 5).toDouble(),
        summary: data['summary'] ?? 'Análisis generado por IA',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('❌ Error parseando análisis de mercado: $e');
      // Devolver análisis por defecto
      return AIMarketAnalysis(
        symbol: symbol,
        trend: 'lateral',
        strength: 5.0,
        supportLevels: [],
        resistanceLevels: [],
        keyInsights: ['Error al procesar análisis'],
        riskAssessment: 'medio',
        timeHorizon: 'medio',
        confidence: 1.0,
        summary: 'Error en análisis de IA',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Parsear señal de trading
  AITradingSignal _parseTradingSignal(String response, String symbol) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No se encontró JSON válido en la respuesta');
      }
      
      final jsonStr = response.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonStr);
      
      return AITradingSignal(
        symbol: symbol,
        action: data['action'] ?? 'hold',
        confidence: (data['confidence'] ?? 5).toDouble(),
        entryPrice: (data['entry_price'] ?? 0).toDouble(),
        stopLoss: (data['stop_loss'] ?? 0).toDouble(),
        takeProfits: List<double>.from(data['take_profit'] ?? []),
        positionSize: (data['position_size'] ?? 5).toDouble(),
        reasoning: List<String>.from(data['reasoning'] ?? []),
        riskReward: (data['risk_reward'] ?? 1.0).toDouble(),
        timeframe: data['timeframe'] ?? 'medio',
        warning: data['warning'],
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('❌ Error parseando señal de trading: $e');
      return AITradingSignal(
        symbol: symbol,
        action: 'hold',
        confidence: 1.0,
        entryPrice: 0.0,
        stopLoss: 0.0,
        takeProfits: [],
        positionSize: 1.0,
        reasoning: ['Error al procesar señal'],
        riskReward: 1.0,
        timeframe: 'medio',
        warning: 'Error en análisis de IA',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Parsear análisis de sentiment
  AISentimentAnalysis _parseSentimentAnalysis(String response, String symbol) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('No se encontró JSON válido en la respuesta');
      }
      
      final jsonStr = response.substring(jsonStart, jsonEnd);
      final data = jsonDecode(jsonStr);
      
      return AISentimentAnalysis(
        symbol: symbol,
        overallSentiment: data['overall_sentiment'] ?? 'neutral',
        sentimentScore: (data['sentiment_score'] ?? 0).toDouble(),
        keyThemes: List<String>.from(data['key_themes'] ?? []),
        marketImpact: data['market_impact'] ?? 'bajo',
        timeSensitivity: data['time_sensitivity'] ?? 'largo_plazo',
        bullishFactors: List<String>.from(data['bullish_factors'] ?? []),
        bearishFactors: List<String>.from(data['bearish_factors'] ?? []),
        summary: data['summary'] ?? 'Análisis de sentiment',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('❌ Error parseando análisis de sentiment: $e');
      return AISentimentAnalysis(
        symbol: symbol,
        overallSentiment: 'neutral',
        sentimentScore: 0.0,
        keyThemes: [],
        marketImpact: 'bajo',
        timeSensitivity: 'largo_plazo',
        bullishFactors: [],
        bearishFactors: [],
        summary: 'Error en análisis de sentiment',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Limpiar recursos
  void dispose() {
    _httpClient.close();
  }
}

/// Modelo para análisis de mercado por IA
class AIMarketAnalysis {
  final String symbol;
  final String trend;
  final double strength;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final List<String> keyInsights;
  final String riskAssessment;
  final String timeHorizon;
  final double confidence;
  final String summary;
  final DateTime timestamp;

  AIMarketAnalysis({
    required this.symbol,
    required this.trend,
    required this.strength,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.keyInsights,
    required this.riskAssessment,
    required this.timeHorizon,
    required this.confidence,
    required this.summary,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'trend': trend,
    'strength': strength,
    'support_levels': supportLevels,
    'resistance_levels': resistanceLevels,
    'key_insights': keyInsights,
    'risk_assessment': riskAssessment,
    'time_horizon': timeHorizon,
    'confidence': confidence,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Modelo para señales de trading por IA
class AITradingSignal {
  final String symbol;
  final String action;
  final double confidence;
  final double entryPrice;
  final double stopLoss;
  final List<double> takeProfits;
  final double positionSize;
  final List<String> reasoning;
  final double riskReward;
  final String timeframe;
  final String? warning;
  final DateTime timestamp;

  AITradingSignal({
    required this.symbol,
    required this.action,
    required this.confidence,
    required this.entryPrice,
    required this.stopLoss,
    required this.takeProfits,
    required this.positionSize,
    required this.reasoning,
    required this.riskReward,
    required this.timeframe,
    this.warning,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'action': action,
    'confidence': confidence,
    'entry_price': entryPrice,
    'stop_loss': stopLoss,
    'take_profits': takeProfits,
    'position_size': positionSize,
    'reasoning': reasoning,
    'risk_reward': riskReward,
    'timeframe': timeframe,
    'warning': warning,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Modelo para análisis de sentiment por IA
class AISentimentAnalysis {
  final String symbol;
  final String overallSentiment;
  final double sentimentScore;
  final List<String> keyThemes;
  final String marketImpact;
  final String timeSensitivity;
  final List<String> bullishFactors;
  final List<String> bearishFactors;
  final String summary;
  final DateTime timestamp;

  AISentimentAnalysis({
    required this.symbol,
    required this.overallSentiment,
    required this.sentimentScore,
    required this.keyThemes,
    required this.marketImpact,
    required this.timeSensitivity,
    required this.bullishFactors,
    required this.bearishFactors,
    required this.summary,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'overall_sentiment': overallSentiment,
    'sentiment_score': sentimentScore,
    'key_themes': keyThemes,
    'market_impact': marketImpact,
    'time_sensitivity': timeSensitivity,
    'bullish_factors': bullishFactors,
    'bearish_factors': bearishFactors,
    'summary': summary,
    'timestamp': timestamp.toIso8601String(),
  };
}
