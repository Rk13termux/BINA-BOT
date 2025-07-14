import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Servicio profesional de IA usando Groq Mistral 7B
class AIService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Configuración Groq API
  String? _apiKey;
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'mistral-7b-8k';
  static const double _temperature = 0.5;
  static const int _maxTokens = 512;

  // Estado del servicio
  bool _isInitialized = false;
  bool _isAvailable = false;
  String? _lastError;

  // Cache para optimización
  final Map<String, Map<String, dynamic>> _analysisCache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _requestCooldown = Duration(milliseconds: 1000);

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  String? get lastError => _lastError;

  /// Inicializar servicio de IA
  Future<void> initialize() async {
    try {
      _logger.info('🧠 Inicializando Invictus AI Service...');
      
      await _loadStoredApiKey();
      
      if (_apiKey != null) {
        await _testConnection();
      }
      
      _isInitialized = true;
      _logger.info('✅ AI Service inicializado correctamente');
      notifyListeners();
    } catch (e) {
      _logger.error('❌ Error inicializando AI Service: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Configurar API Key de Groq
  Future<bool> setGroqApiKey(String apiKey) async {
    try {
      _apiKey = apiKey.trim();
      
      // Guardar de forma segura
      await _storage.write(key: 'groq_api_key', value: _apiKey);
      
      // Probar conexión
      final isValid = await _testConnection();
      
      if (isValid) {
        _isAvailable = true;
        _lastError = null;
        _logger.info('✅ Groq API Key configurado correctamente');
        notifyListeners();
        return true;
      } else {
        _isAvailable = false;
        _logger.warning('⚠️ API Key de Groq inválido');
        return false;
      }
    } catch (e) {
      _logger.error('❌ Error configurando Groq API Key: $e');
      _lastError = e.toString();
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  /// Cargar API Key almacenado
  Future<void> _loadStoredApiKey() async {
    try {
      _apiKey = await _storage.read(key: 'groq_api_key');
      if (_apiKey != null) {
        _logger.info('🔑 API Key cargado desde almacenamiento seguro');
      }
    } catch (e) {
      _logger.error('❌ Error cargando API Key: $e');
    }
  }

  /// Probar conexión con Groq API
  Future<bool> _testConnection() async {
    try {
      if (_apiKey == null) {
        throw Exception('API Key no configurado');
      }

      final testPrompt = 'Test connection. Responde solo: "OK"';
      final response = await analyzeWithAI(testPrompt);
      
      if (response.isNotEmpty) {
        _isAvailable = true;
        _lastError = null;
        _logger.info('✅ Conexión con Groq exitosa');
        return true;
      } else {
        _isAvailable = false;
        _lastError = 'Respuesta vacía de Groq API';
        return false;
      }
    } catch (e) {
      _isAvailable = false;
      _lastError = e.toString();
      _logger.error('❌ Error probando conexión Groq: $e');
      return false;
    }
  }

  /// Análisis principal con IA - Método core
  Future<String> analyzeWithAI(String prompt) async {
    try {
      if (!_isAvailable || _apiKey == null) {
        throw Exception('Servicio de IA no disponible');
      }

      // Rate limiting
      await _respectRateLimit();

      // Verificar cache
      final cacheKey = prompt.hashCode.toString();
      if (_analysisCache.containsKey(cacheKey)) {
        final cached = _analysisCache[cacheKey]!;
        final cacheTime = DateTime.parse(cached['timestamp']);
        if (DateTime.now().difference(cacheTime) < _cacheDuration) {
          _logger.debug('📄 Usando análisis en cache');
          return cached['result'];
        }
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un experto analista cuantitativo de trading de criptomonedas. Proporciona análisis precisos, concisos y profesionales.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': _temperature,
          'max_tokens': _maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'] ?? '';
        
        // Guardar en cache
        _analysisCache[cacheKey] = {
          'result': result,
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        _logger.debug('🧠 Análisis IA completado');
        return result;
      } else {
        throw Exception('Error Groq API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _logger.error('❌ Error en análisis IA: $e');
      rethrow;
    }
  }

  /// Análisis técnico avanzado de mercado
  Future<Map<String, dynamic>> analyzeTechnicalIndicators({
    required String symbol,
    required List<Map<String, dynamic>> candleData,
    required Map<String, double> indicators,
  }) async {
    try {
      final prompt = '''
Analiza los siguientes datos técnicos para $symbol:

DATOS DE VELAS (últimas 20):
${_formatCandleData(candleData)}

INDICADORES TÉCNICOS:
${_formatIndicators(indicators)}

Proporciona un análisis profesional incluyendo:
1. Tendencia dominante (BULLISH/BEARISH/NEUTRAL)
2. Puntos de entrada y salida potenciales
3. Niveles de soporte y resistencia
4. Gestión de riesgo sugerida
5. Confluencias técnicas importantes

Responde en formato JSON:
{
  "trend": "BULLISH|BEARISH|NEUTRAL",
  "confidence": 0.85,
  "entry_price": 50000.0,
  "stop_loss": 48500.0,
  "take_profit": 55000.0,
  "risk_reward": 2.5,
  "analysis": "descripción detallada...",
  "key_levels": [49000, 51000, 53000],
  "timeframe_suggestion": "4h"
}
''';

      final response = await analyzeWithAI(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      _logger.error('❌ Error en análisis técnico: $e');
      rethrow;
    }
  }

  /// Análisis de sentimiento de noticias
  Future<Map<String, dynamic>> analyzeNewsSentiment(List<String> newsHeadlines) async {
    try {
      final prompt = '''
Analiza el sentimiento de mercado basado en estas noticias recientes:

NOTICIAS:
${newsHeadlines.join('\n- ')}

Proporciona análisis de sentimiento considerando:
1. Impacto en el precio de criptomonedas
2. Nivel de incertidumbre del mercado
3. Oportunidades de trading a corto/medio plazo

Responde en formato JSON:
{
  "sentiment": "BULLISH|BEARISH|NEUTRAL",
  "impact_level": 0.75,
  "market_uncertainty": 0.40,
  "key_catalysts": ["regulación", "adopción institucional"],
  "trading_bias": "LONG|SHORT|NEUTRAL",
  "summary": "resumen ejecutivo..."
}
''';

      final response = await analyzeWithAI(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      _logger.error('❌ Error en análisis de sentimiento: $e');
      rethrow;
    }
  }

  /// Generar estrategia de trading personalizada
  Future<Map<String, dynamic>> generateTradingStrategy({
    required String symbol,
    required double accountBalance,
    required String riskTolerance, // LOW, MEDIUM, HIGH
    required String timeframe,
  }) async {
    try {
      final prompt = '''
Genera una estrategia de trading personalizada para:

SÍMBOLO: $symbol
BALANCE: \$${accountBalance.toStringAsFixed(2)}
TOLERANCIA AL RIESGO: $riskTolerance
TIMEFRAME: $timeframe

Diseña una estrategia completa considerando:
1. Gestión de capital (% por operación)
2. Puntos de entrada y salida
3. Stop loss y take profit dinámicos
4. Condiciones de mercado óptimas
5. Backtesting mental básico

Responde en formato JSON:
{
  "strategy_name": "Scalping AI Pro",
  "position_size_percent": 2.5,
  "entry_conditions": ["RSI < 30", "MACD bullish cross"],
  "exit_conditions": ["RSI > 70", "ATR expansion"],
  "stop_loss_percent": 1.5,
  "take_profit_percent": 3.0,
  "max_daily_trades": 8,
  "market_conditions": "trending markets",
  "expected_win_rate": 0.65
}
''';

      final response = await analyzeWithAI(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      _logger.error('❌ Error generando estrategia: $e');
      rethrow;
    }
  }

  /// Análisis en tiempo real para plugins
  Future<Map<String, dynamic>> analyzeRealTimeSignal({
    required String symbol,
    required Map<String, double> currentIndicators,
    required String strategyType,
  }) async {
    try {
      final prompt = '''
ANÁLISIS EN TIEMPO REAL - $symbol

ESTRATEGIA: $strategyType
INDICADORES ACTUALES:
${_formatIndicators(currentIndicators)}

Genera señal de trading inmediata considerando:
1. Confirmación de múltiples indicadores
2. Momentum del mercado actual
3. Probabilidad de éxito estimada

Responde en formato JSON compacto:
{
  "signal": "BUY|SELL|HOLD",
  "confidence": 0.82,
  "urgency": "HIGH|MEDIUM|LOW",
  "reason": "descripción breve"
}
''';

      final response = await analyzeWithAI(prompt);
      return _parseJsonResponse(response);
    } catch (e) {
      _logger.error('❌ Error en análisis tiempo real: $e');
      rethrow;
    }
  }

  // MÉTODOS HELPER PRIVADOS

  /// Formatear datos de velas para prompt
  String _formatCandleData(List<Map<String, dynamic>> candles) {
    if (candles.isEmpty) return 'No hay datos de velas';
    
    final buffer = StringBuffer();
    for (int i = 0; i < candles.length && i < 20; i++) {
      final candle = candles[i];
      buffer.writeln('${i + 1}. O:${candle['open']} H:${candle['high']} L:${candle['low']} C:${candle['close']} V:${candle['volume']}');
    }
    return buffer.toString();
  }

  /// Formatear indicadores para prompt
  String _formatIndicators(Map<String, double> indicators) {
    if (indicators.isEmpty) return 'No hay indicadores';
    
    final buffer = StringBuffer();
    indicators.forEach((key, value) {
      buffer.writeln('$key: ${value.toStringAsFixed(4)}');
    });
    return buffer.toString();
  }

  /// Parsear respuesta JSON del AI
  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Extraer JSON del response si está embebido en texto
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      return jsonDecode(response);
    } catch (e) {
      _logger.warning('⚠️ No se pudo parsear JSON de IA: $e');
      return {
        'error': 'JSON parsing failed',
        'raw_response': response,
      };
    }
  }

  /// Respetar límites de rate
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _requestCooldown) {
        final waitTime = _requestCooldown - elapsed;
        _logger.debug('⏱️ Rate limiting: esperando ${waitTime.inMilliseconds}ms');
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Limpiar cache
  void clearCache() {
    _analysisCache.clear();
    _logger.info('🗑️ Cache de análisis limpiado');
  }

  /// Limpiar todas las credenciales
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: 'groq_api_key');
      _apiKey = null;
      _isAvailable = false;
      _lastError = null;
      clearCache();
      
      _logger.info('🔐 Credenciales de IA eliminadas');
      notifyListeners();
    } catch (e) {
      _logger.error('❌ Error eliminando credenciales: $e');
    }
  }

  /// Estadísticas del servicio
  Map<String, dynamic> getServiceStats() {
    return {
      'is_available': _isAvailable,
      'cache_size': _analysisCache.length,
      'last_error': _lastError,
      'api_configured': _apiKey != null,
    };
  }
}
