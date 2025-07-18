import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Respuesta de análisis de mercado AI
class AIMarketAnalysis {
  final String symbol;
  final String trend;
  final double confidence;
  final String analysis;
  final List<String> indicators;
  final String timeframe;
  final DateTime timestamp;

  AIMarketAnalysis({
    required this.symbol,
    required this.trend,
    required this.confidence,
    required this.analysis,
    required this.indicators,
    required this.timeframe,
    required this.timestamp,
  });

  factory AIMarketAnalysis.fromJson(Map<String, dynamic> json) {
    return AIMarketAnalysis(
      symbol: json['symbol'] ?? '',
      trend: json['trend'] ?? 'NEUTRAL',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      analysis: json['analysis'] ?? '',
      indicators: List<String>.from(json['indicators'] ?? []),
      timeframe: json['timeframe'] ?? '1h',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'trend': trend,
      'confidence': confidence,
      'analysis': analysis,
      'indicators': indicators,
      'timeframe': timeframe,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Señal de trading generada por AI
class AITradingSignal {
  final String symbol;
  final String action; // BUY, SELL, HOLD
  final double confidence;
  final String reasoning;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final String timeframe;
  final DateTime timestamp;

  AITradingSignal({
    required this.symbol,
    required this.action,
    required this.confidence,
    required this.reasoning,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.timeframe,
    required this.timestamp,
  });

  factory AITradingSignal.fromJson(Map<String, dynamic> json) {
    return AITradingSignal(
      symbol: json['symbol'] ?? '',
      action: json['action'] ?? 'HOLD',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      reasoning: json['reasoning'] ?? '',
      entryPrice: json['entryPrice']?.toDouble(),
      stopLoss: json['stopLoss']?.toDouble(),
      takeProfit: json['takeProfit']?.toDouble(),
      timeframe: json['timeframe'] ?? '1h',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'action': action,
      'confidence': confidence,
      'reasoning': reasoning,
      'entryPrice': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'timeframe': timeframe,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Análisis de sentiment de noticias
class AISentimentAnalysis {
  final String text;
  final String sentiment; // BULLISH, BEARISH, NEUTRAL
  final double confidence;
  final List<String> keywords;
  final double impact; // 0-1 scale
  final DateTime timestamp;

  AISentimentAnalysis({
    required this.text,
    required this.sentiment,
    required this.confidence,
    required this.keywords,
    required this.impact,
    required this.timestamp,
  });

  factory AISentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return AISentimentAnalysis(
      text: json['text'] ?? '',
      sentiment: json['sentiment'] ?? 'NEUTRAL',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      keywords: List<String>.from(json['keywords'] ?? []),
      impact: (json['impact'] ?? 0.0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sentiment': sentiment,
      'confidence': confidence,
      'keywords': keywords,
      'impact': impact,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Servicio profesional de AI usando Groq
class AIService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Configuración
  String? _apiKey;
  String get _baseUrl =>
      dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  String get _model => dotenv.env['GROQ_MODEL'] ?? 'mixtral-8x7b-32768';
  int get _defaultMaxTokens =>
      int.tryParse(dotenv.env['GROQ_MAX_TOKENS'] ?? '1000') ?? 1000;
  double get _defaultTemperature =>
      double.tryParse(dotenv.env['GROQ_TEMPERATURE'] ?? '0.3') ?? 0.3;

  // Estado del servicio
  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _lastError;

  // Cache y rate limiting
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _lastRequestTimes = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _rateLimitDuration = Duration(seconds: 2);

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  String? get lastError => _lastError;

  /// Inicializar servicio de AI
  Future<void> initialize() async {
    try {
      _logger.info('Initializing AI service...');
      
      // Cargar API key
      await _loadApiKey();
      
      // Probar conexión
      if (_apiKey != null) {
        await _testConnection();
      }
      
      _isInitialized = true;
      _logger.info('AI service initialized successfully');
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to initialize AI service: $e');
      _lastError = e.toString();
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Configurar API key
  Future<bool> setApiKey(String apiKey) async {
    try {
      _apiKey = apiKey.trim();
      
      // Guardar de forma segura
      await _storage.write(key: 'groq_api_key', value: _apiKey);
      
      // Probar conexión
      final isValid = await _testConnection();
      
      if (isValid) {
        _isAvailable = true;
        _lastError = null;
        _logger.info('AI service API key configured successfully');
        notifyListeners();
        return true;
      } else {
        _isAvailable = false;
        _logger.warning('Invalid AI service API key provided');
        return false;
      }
    } catch (e) {
      _logger.error('Failed to set AI service API key: $e');
      _lastError = e.toString();
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Cargar API key almacenada
  Future<void> _loadApiKey() async {
    try {
      _apiKey = await _storage.read(key: 'groq_api_key');
      if (_apiKey != null) {
        _logger.info('Loaded stored AI service API key');
      }
    } catch (e) {
      _logger.error('Failed to load stored AI API key: $e');
    }
  }

  /// Probar conexión con Groq API
  Future<bool> _testConnection() async {
    try {
      if (_apiKey == null) {
        throw Exception('API key not configured');
      }

      final response = await _makeRequest(
        'Test connection to Groq AI service',
        maxTokens: 10,
      );

      if (response.isNotEmpty) {
        _isAvailable = true;
        _lastError = null;
        _logger.info('AI service connection test successful');
        return true;
      } else {
        _isAvailable = false;
        _lastError = 'Empty response from AI service';
        return false;
      }
    } catch (e) {
      _isAvailable = false;
      _lastError = e.toString();
      _logger.error('AI service connection test failed: $e');
      return false;
    }
  }

  /// Análisis general con AI
  Future<String> analyzeWithAI(String prompt, {String? cacheKey}) async {
    try {
      if (!_isAvailable) {
        throw Exception('AI service not available');
      }

      // Verificar cache
      if (cacheKey != null && _cache.containsKey(cacheKey)) {
        final cached = _cache[cacheKey];
        if (cached['timestamp'].add(_cacheDuration).isAfter(DateTime.now())) {
          _logger.debug('Returning cached AI analysis for: $cacheKey');
          return cached['result'];
        }
      }

      // Rate limiting
      await _respectRateLimit();

      final result = await _makeRequest(prompt);

      // Guardar en cache
      if (cacheKey != null) {
        _cache[cacheKey] = {
          'result': result,
          'timestamp': DateTime.now(),
        };
      }

      return result;
    } catch (e) {
      _logger.error('Error in AI analysis: $e');
      rethrow;
    }
  }

  /// Análisis de mercado
  Future<AIMarketAnalysis> analyzeMarket({
    required String symbol,
    required List<Map<String, dynamic>> priceData,
    String timeframe = '1h',
  }) async {
    try {
      final prompt = '''
Analiza los siguientes datos de precio para $symbol en timeframe $timeframe:
${_formatPriceData(priceData)}

Proporciona un análisis técnico profesional incluyendo:
1. Tendencia actual (BULLISH/BEARISH/NEUTRAL)
2. Nivel de confianza (0-1)
3. Indicadores técnicos relevantes
4. Análisis detallado

Responde en formato JSON con esta estructura:
{
  "trend": "BULLISH|BEARISH|NEUTRAL",
  "confidence": 0.85,
  "analysis": "análisis detallado...",
  "indicators": ["RSI oversold", "MACD bullish cross", ...],
  "timeframe": "$timeframe"
}
''';

      final response = await analyzeWithAI(prompt, cacheKey: 'market_$symbol\_$timeframe');
      final jsonData = _parseJsonResponse(response);
      
      return AIMarketAnalysis(
        symbol: symbol,
        trend: jsonData['trend'] ?? 'NEUTRAL',
        confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
        analysis: jsonData['analysis'] ?? '',
        indicators: List<String>.from(jsonData['indicators'] ?? []),
        timeframe: timeframe,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error in market analysis: $e');
      rethrow;
    }
  }

  /// Generar señal de trading
  Future<AITradingSignal> generateTradingSignal({
    required String symbol,
    required List<Map<String, dynamic>> priceData,
    required Map<String, dynamic> marketConditions,
    String timeframe = '1h',
  }) async {
    try {
      final prompt = '''
Basándote en los siguientes datos para $symbol:

Datos de precio: ${_formatPriceData(priceData)}
Condiciones de mercado: $marketConditions

Genera una señal de trading profesional considerando:
1. Análisis técnico
2. Gestión de riesgo
3. Condiciones actuales del mercado

Responde en formato JSON:
{
  "action": "BUY|SELL|HOLD",
  "confidence": 0.85,
  "reasoning": "razonamiento detallado...",
  "entryPrice": 50000.0,
  "stopLoss": 48000.0,
  "takeProfit": 55000.0
}
''';

      final response = await analyzeWithAI(prompt, cacheKey: 'signal_$symbol\_$timeframe');
      final jsonData = _parseJsonResponse(response);
      
      return AITradingSignal(
        symbol: symbol,
        action: jsonData['action'] ?? 'HOLD',
        confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
        reasoning: jsonData['reasoning'] ?? '',
        entryPrice: jsonData['entryPrice']?.toDouble(),
        stopLoss: jsonData['stopLoss']?.toDouble(),
        takeProfit: jsonData['takeProfit']?.toDouble(),
        timeframe: timeframe,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error generating trading signal: $e');
      rethrow;
    }
  }

  /// Análisis de sentiment de noticias
  Future<AISentimentAnalysis> analyzeNewsSentiment(String newsText) async {
    try {
      final prompt = '''
Analiza el sentiment de la siguiente noticia sobre criptomonedas:

"$newsText"

Proporciona un análisis de sentiment considerando:
1. Impacto en el mercado crypto
2. Palabras clave relevantes
3. Nivel de confianza del análisis

Responde en formato JSON:
{
  "sentiment": "BULLISH|BEARISH|NEUTRAL",
  "confidence": 0.85,
  "keywords": ["bitcoin", "regulación", ...],
  "impact": 0.7
}
''';

      final response = await analyzeWithAI(prompt, cacheKey: 'sentiment_${newsText.hashCode}');
      final jsonData = _parseJsonResponse(response);
      
      return AISentimentAnalysis(
        text: newsText,
        sentiment: jsonData['sentiment'] ?? 'NEUTRAL',
        confidence: (jsonData['confidence'] ?? 0.0).toDouble(),
        keywords: List<String>.from(jsonData['keywords'] ?? []),
        impact: (jsonData['impact'] ?? 0.0).toDouble(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error in sentiment analysis: $e');
      rethrow;
    }
  }

  /// Realizar petición a Groq API
  Future<String> _makeRequest(String prompt, {int? maxTokens}) async {
    if (_apiKey == null) {
      throw Exception('API key not configured');
    }

    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': 'Eres un experto analista de criptomonedas y trading. Proporciona análisis precisos y profesionales.',
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'max_tokens': maxTokens ?? _defaultMaxTokens,
      'temperature': _defaultTemperature,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'] ?? '';
    } else {
      throw Exception('AI API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Formatear datos de precio para prompt
  String _formatPriceData(List<Map<String, dynamic>> priceData) {
    if (priceData.isEmpty) return 'No price data available';
    
    final latest = priceData.last;
    final previous = priceData.length > 1 ? priceData[priceData.length - 2] : latest;
    
    return '''
Precio actual: ${latest['close']}
Precio anterior: ${previous['close']}
Cambio: ${((latest['close'] - previous['close']) / previous['close'] * 100).toStringAsFixed(2)}%
Volumen: ${latest['volume']}
Máximo 24h: ${latest['high']}
Mínimo 24h: ${latest['low']}
''';
  }

  /// Parsear respuesta JSON del AI
  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Extraer JSON del response si está embebido en texto
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }
      return json.decode(response);
    } catch (e) {
      _logger.warning('Failed to parse AI JSON response: $e');
      return {};
    }
  }

  /// Respetar límites de rate
  Future<void> _respectRateLimit() async {
    final lastRequest = _lastRequestTimes['ai_request'];
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest);
      if (elapsed < _rateLimitDuration) {
        final waitTime = _rateLimitDuration - elapsed;
        _logger.debug('Rate limiting: waiting ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTimes['ai_request'] = DateTime.now();
  }

  /// Limpiar cache
  void clearCache() {
    _cache.clear();
    _logger.info('AI service cache cleared');
  }

  /// Limpiar credenciales
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: 'groq_api_key');
      _apiKey = null;
      _isAvailable = false;
      _lastError = null;
      clearCache();
      
      _logger.info('AI service credentials cleared');
      notifyListeners();
    } catch (e) {
      _logger.error('Error clearing AI credentials: $e');
    }
  }
}
