import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

/// Servicio profesional de IA usando Groq API para análisis de trading
class AIService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // API Configuration
  String get _baseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  String get _model => dotenv.env['GROQ_MODEL'] ?? 'mixtral-8x7b-32768';
  
  // Authentication
  String? _apiKey;
  bool _isInitialized = false;
  String? _lastError;

  // Rate limiting
  int _requestCount = 0;
  DateTime _lastRequestTime = DateTime.now();
  
  // Analysis cache
  final Map<String, dynamic> _analysisCache = {};

  // Getters
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;
  int get requestCount => _requestCount;
  bool get isRateLimited => _requestCount > 100; // Ajustar según límites de Groq

  /// Inicializar servicio de IA
  Future<void> initialize() async {
    try {
      _logger.info('Initializing AI service...');
      
      // Cargar API key almacenada
      await _loadStoredApiKey();
      
      // Probar conexión si hay API key
      if (_apiKey != null) {
        await _testConnection();
      }
      
      _logger.info('AI service initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize AI service: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Configurar API key de Groq
  Future<bool> setApiKey(String apiKey) async {
    try {
      _apiKey = apiKey.trim();
      
      // Probar la API key
      final isValid = await _testConnection();
      
      if (isValid) {
        // Guardar de forma segura
        await _storage.write(key: 'groq_api_key', value: _apiKey);
        _isInitialized = true;
        _lastError = null;
        
        _logger.info('Groq API key configured successfully');
        notifyListeners();
        return true;
      } else {
        _isInitialized = false;
        _logger.warning('Invalid Groq API key provided');
        return false;
      }
    } catch (e) {
      _logger.error('Failed to set Groq API key: $e');
      _lastError = e.toString();
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  /// Cargar API key almacenada
  Future<void> _loadStoredApiKey() async {
    try {
      _apiKey = await _storage.read(key: 'groq_api_key');
      _isInitialized = _apiKey != null;
      
      if (_isInitialized) {
        _logger.info('Loaded stored Groq API key');
      }
    } catch (e) {
      _logger.error('Failed to load stored API key: $e');
    }
  }

  /// Probar conexión con Groq API
  Future<bool> _testConnection() async {
    try {
      if (_apiKey == null) {
        throw Exception('Groq API key not configured');
      }

      const testPrompt = 'Hello, please respond with "AI connection successful"';
      final response = await analyzeWithAI(testPrompt);
      
      if (response.isNotEmpty) {
        _logger.info('Groq AI connection test successful');
        return true;
      } else {
        throw Exception('Empty response from Groq API');
      }
    } catch (e) {
      _logger.error('Groq AI connection test failed: $e');
      _lastError = e.toString();
      return false;
    }
  }

  /// Análisis principal con IA usando Groq API
  Future<String> analyzeWithAI(String prompt) async {
    try {
      if (!_isInitialized || _apiKey == null) {
        throw Exception('AI service not initialized or API key missing');
      }

      // Verificar rate limiting
      if (isRateLimited) {
        throw Exception('Rate limit exceeded. Please try again later.');
      }

      // Verificar cache
      final cacheKey = prompt.hashCode.toString();
      if (_analysisCache.containsKey(cacheKey)) {
        final cachedResult = _analysisCache[cacheKey];
        final cacheTime = cachedResult['timestamp'] as DateTime;
        
        // Cache válido por 5 minutos
        if (DateTime.now().difference(cacheTime).inMinutes < 5) {
          _logger.debug('Returning cached AI analysis');
          return cachedResult['response'] as String;
        }
      }

      final requestBody = {
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert cryptocurrency trading analyst. Provide clear, '
                      'actionable insights based on technical analysis, market sentiment, '
                      'and trading patterns. Always include specific recommendations and '
                      'risk assessments in your responses.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'max_tokens': 1024,
        'temperature': 0.7,
        'top_p': 1,
        'stream': false
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      _updateRequestCount();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices'][0]['message']['content'] as String;
        
        // Guardar en cache
        _analysisCache[cacheKey] = {
          'response': content,
          'timestamp': DateTime.now(),
        };
        
        _logger.info('AI analysis completed successfully');
        _lastError = null;
        notifyListeners();
        
        return content.trim();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Groq API error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error in AI analysis: $e');
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Análisis de sentimiento de mercado
  Future<Map<String, dynamic>> analyzeSentiment({
    required String symbol,
    required List<String> newsHeadlines,
  }) async {
    try {
      final prompt = '''
Analyze the market sentiment for $symbol based on these news headlines:

${newsHeadlines.take(10).map((headline) => '- $headline').join('\n')}

Provide analysis in this JSON format:
{
  "sentiment": "bullish|bearish|neutral",
  "confidence": 0.85,
  "summary": "Brief summary of overall sentiment",
  "key_factors": ["factor1", "factor2", "factor3"],
  "recommendation": "buy|sell|hold",
  "risk_level": "low|medium|high"
}
''';

      final response = await analyzeWithAI(prompt);
      
      // Intentar parsear como JSON
      try {
        return json.decode(response);
      } catch (e) {
        // Si no es JSON válido, crear respuesta estructurada
        return {
          'sentiment': 'neutral',
          'confidence': 0.5,
          'summary': response.length > 200 ? response.substring(0, 200) + '...' : response,
          'key_factors': ['Analysis completed'],
          'recommendation': 'hold',
          'risk_level': 'medium'
        };
      }
    } catch (e) {
      _logger.error('Error in sentiment analysis: $e');
      return {
        'sentiment': 'neutral',
        'confidence': 0.0,
        'summary': 'Analysis failed: ${e.toString()}',
        'key_factors': ['Error occurred'],
        'recommendation': 'hold',
        'risk_level': 'high'
      };
    }
  }

  /// Predicción de precios
  Future<Map<String, dynamic>> predictPrice({
    required String symbol,
    required List<double> priceHistory,
    required String timeframe,
  }) async {
    try {
      final prompt = '''
Based on this price history for $symbol over the last $timeframe:
${priceHistory.take(20).map((price) => price.toStringAsFixed(2)).join(', ')}

Provide a price prediction analysis in this JSON format:
{
  "predicted_price": 45000.50,
  "direction": "up|down|sideways",
  "confidence": 0.75,
  "timeframe": "24h",
  "support_levels": [44000, 43500],
  "resistance_levels": [46000, 47000],
  "reasoning": "Technical analysis reasoning"
}
''';

      final response = await analyzeWithAI(prompt);
      
      try {
        return json.decode(response);
      } catch (e) {
        return {
          'predicted_price': priceHistory.isNotEmpty ? priceHistory.last : 0.0,
          'direction': 'sideways',
          'confidence': 0.5,
          'timeframe': timeframe,
          'support_levels': [],
          'resistance_levels': [],
          'reasoning': response.length > 200 ? response.substring(0, 200) + '...' : response
        };
      }
    } catch (e) {
      _logger.error('Error in price prediction: $e');
      return {
        'predicted_price': 0.0,
        'direction': 'sideways',
        'confidence': 0.0,
        'timeframe': timeframe,
        'support_levels': [],
        'resistance_levels': [],
        'reasoning': 'Prediction failed: ${e.toString()}'
      };
    }
  }

  /// Análisis de riesgo
  Future<Map<String, dynamic>> analyzeRisk({
    required String symbol,
    required double volatility,
    required double volume,
  }) async {
    try {
      final prompt = '''
Analyze the trading risk for $symbol with:
- Volatility: ${volatility.toStringAsFixed(4)}
- Volume: ${volume.toStringAsFixed(0)}

Provide risk analysis in JSON format:
{
  "risk_score": 0.65,
  "risk_level": "medium",
  "volatility_assessment": "high|medium|low",
  "volume_assessment": "high|medium|low",
  "recommendations": ["rec1", "rec2"],
  "max_position_size": 0.05
}
''';

      final response = await analyzeWithAI(prompt);
      
      try {
        return json.decode(response);
      } catch (e) {
        return {
          'risk_score': 0.5,
          'risk_level': 'medium',
          'volatility_assessment': volatility > 0.05 ? 'high' : volatility > 0.02 ? 'medium' : 'low',
          'volume_assessment': volume > 1000000 ? 'high' : volume > 100000 ? 'medium' : 'low',
          'recommendations': ['Monitor closely', 'Use appropriate position sizing'],
          'max_position_size': 0.05
        };
      }
    } catch (e) {
      _logger.error('Error in risk analysis: $e');
      return {
        'risk_score': 1.0,
        'risk_level': 'high',
        'volatility_assessment': 'unknown',
        'volume_assessment': 'unknown',
        'recommendations': ['Analysis failed - exercise extreme caution'],
        'max_position_size': 0.01
      };
    }
  }

  /// Limpiar credenciales de IA
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: 'groq_api_key');
      _apiKey = null;
      _isInitialized = false;
      _lastError = null;
      _analysisCache.clear();
      
      _logger.info('AI credentials cleared');
      notifyListeners();
    } catch (e) {
      _logger.error('Error clearing AI credentials: $e');
    }
  }

  /// Actualizar contador de requests
  void _updateRequestCount() {
    _requestCount++;
    _lastRequestTime = DateTime.now();
    
    // Reset counter cada hora
    if (DateTime.now().difference(_lastRequestTime).inHours >= 1) {
      _requestCount = 0;
    }
  }

  /// Limpiar cache de análisis
  void clearCache() {
    _analysisCache.clear();
    _logger.info('AI analysis cache cleared');
  }
}
