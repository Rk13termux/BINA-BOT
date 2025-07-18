// Servicio optimizado de trading AI con Llama 3.3 70B Versatile
// Archivo: lib/services/enhanced_trading_ai_service.dart

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/candle.dart';
import '../models/technical_indicator.dart';
import '../utils/logger.dart';

/// Análisis de trading mejorado con IA
class TradingAIAnalysis {
  final String symbol;
  final String recommendation; // STRONG_BUY, BUY, HOLD, SELL, STRONG_SELL
  final double confidence; // 1-100
  final String summary;
  final List<String> keyFactors;
  final double? entryPrice;
  final double? stopLoss;
  final double? takeProfit;
  final String reasoning;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  TradingAIAnalysis({
    required this.symbol,
    required this.recommendation,
    required this.confidence,
    required this.summary,
    required this.keyFactors,
    this.entryPrice,
    this.stopLoss,
    this.takeProfit,
    required this.reasoning,
    required this.timestamp,
    this.metadata = const {},
  });

  factory TradingAIAnalysis.fromJson(Map<String, dynamic> json) {
    return TradingAIAnalysis(
      symbol: json['symbol'] ?? '',
      recommendation: json['recommendation'] ?? 'HOLD',
      confidence: (json['confidence'] ?? 50.0).toDouble(),
      summary: json['briefSummary'] ?? json['summary'] ?? '',
      keyFactors: List<String>.from(json['keyFactors'] ?? []),
      entryPrice: json['priceTarget']?.toDouble() ?? json['entryPrice']?.toDouble(),
      stopLoss: json['stopLoss']?.toDouble(),
      takeProfit: json['takeProfit']?.toDouble(),
      reasoning: json['reasoning'] ?? '',
      timestamp: DateTime.now(),
      metadata: json['metadata'] ?? {},
    );
  }

  bool get isBullish => ['STRONG_BUY', 'BUY'].contains(recommendation);
  bool get isBearish => ['STRONG_SELL', 'SELL'].contains(recommendation);
  bool get isNeutral => recommendation == 'HOLD';
}

/// Servicio mejorado de análisis de trading con IA
class EnhancedTradingAIService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();

  // Configuración optimizada desde .env
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  String get _model => dotenv.env['GROQ_MODEL'] ?? 'llama-3.3-70b-versatile';
  int get _maxTokens => int.tryParse(dotenv.env['GROQ_MAX_TOKENS'] ?? '2048') ?? 2048;
  double get _temperature => double.tryParse(dotenv.env['GROQ_TEMPERATURE'] ?? '0.2') ?? 0.2;

  // Estado del servicio
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  TradingAIAnalysis? _lastAnalysis;
  String? _lastError;

  // Cache inteligente
  final Map<String, Map<String, dynamic>> _analysisCache = {};
  static const Duration _cacheDuration = Duration(minutes: 2);

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _requestCooldown = Duration(seconds: 1);

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  bool get isAvailable => _apiKey.isNotEmpty && _apiKey != 'your_groq_api_key_here';
  TradingAIAnalysis? get lastAnalysis => _lastAnalysis;
  String? get lastError => _lastError;

  /// Inicializar servicio
  Future<void> initialize() async {
    try {
      _logger.info('🚀 Inicializando Enhanced Trading AI Service...');
      
      if (!isAvailable) {
        throw Exception('Groq API key no configurada en .env');
      }

      // Test de conectividad
      await _testConnection();
      
      _isInitialized = true;
      _logger.info('✅ Enhanced Trading AI Service inicializado correctamente');
      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      _logger.error('❌ Error inicializando Enhanced Trading AI Service: $e');
      notifyListeners();
    }
  }

  /// Test de conexión con Groq
  Future<bool> _testConnection() async {
    try {
      final testResponse = await _makeAPIRequest(
        'Responde solo: "CONEXION_OK"',
        maxTokens: 10,
      );
      
      return testResponse.isNotEmpty;
    } catch (e) {
      _logger.error('Test de conexión Groq falló: $e');
      return false;
    }
  }

  /// Análisis completo de trading con IA
  Future<TradingAIAnalysis?> analyzeTradingOpportunity({
    required String symbol,
    required List<Candle> candles,
    required List<TechnicalIndicator> indicators,
    required double currentPrice,
    String timeframe = '1h',
    Map<String, dynamic>? marketContext,
  }) async {
    if (!isAvailable || !_isInitialized) {
      throw Exception('Servicio de IA no disponible o no inicializado');
    }

    _isAnalyzing = true;
    _lastError = null;
    notifyListeners();

    try {
      // Verificar cache
      final cacheKey = '${symbol}_${timeframe}_${DateTime.now().millisecondsSinceEpoch ~/ 120000}'; // Cache de 2min
      if (_analysisCache.containsKey(cacheKey)) {
        final cached = _analysisCache[cacheKey]!;
        if (DateTime.parse(cached['timestamp']).add(_cacheDuration).isAfter(DateTime.now())) {
          _logger.info('📋 Retornando análisis desde cache: $symbol');
          return TradingAIAnalysis.fromJson(cached['analysis']);
        }
      }

      // Preparar datos para análisis
      final analysisData = _prepareAnalysisData(symbol, candles, indicators, currentPrice, timeframe, marketContext);
      
      // Generar prompt optimizado
      final prompt = _generateTradingPrompt(analysisData);
      
      // Rate limiting
      await _respectRateLimit();
      
      // Llamar a Groq API
      final response = await _makeAPIRequest(prompt, maxTokens: _maxTokens);
      
      // Parsear respuesta
      final analysis = _parseAnalysisResponse(response, symbol);
      
      // Guardar en cache
      _analysisCache[cacheKey] = {
        'analysis': analysis.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _lastAnalysis = analysis;
      _logger.info('✅ Análisis de trading completado para $symbol: ${analysis.recommendation}');
      
      return analysis;
      
    } catch (e) {
      _lastError = e.toString();
      _logger.error('❌ Error en análisis de trading: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Análisis rápido de entrada/salida
  Future<Map<String, dynamic>?> quickSignalAnalysis({
    required String symbol,
    required double currentPrice,
    required Map<String, double> indicators,
  }) async {
    try {
      final prompt = '''
ANÁLISIS RÁPIDO DE SEÑAL - $symbol
Precio actual: \$${currentPrice.toStringAsFixed(2)}

INDICADORES TÉCNICOS:
${indicators.entries.map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}').join('\n')}

Genera señal inmediata considerando:
1. Momentum actual
2. Niveles de soporte/resistencia
3. Confirmación de indicadores

Responde SOLO en formato JSON compacto:
{
  "signal": "BUY|SELL|HOLD",
  "confidence": 75,
  "reason": "razón principal",
  "entry": ${currentPrice.toStringAsFixed(2)},
  "stop": número,
  "target": número
}
''';

      final response = await _makeAPIRequest(prompt, maxTokens: 200);
      return jsonDecode(response);
    } catch (e) {
      _logger.error('Error en análisis rápido: $e');
      return null;
    }
  }

  /// Preparar datos para análisis
  Map<String, dynamic> _prepareAnalysisData(
    String symbol,
    List<Candle> candles,
    List<TechnicalIndicator> indicators,
    double currentPrice,
    String timeframe,
    Map<String, dynamic>? marketContext,
  ) {
    // Últimas velas para contexto
    final recentCandles = candles.take(20).toList();
    
    // Datos OHLCV recientes
    final ohlcvData = recentCandles.map((c) => {
      'open': c.open,
      'high': c.high,
      'low': c.low,
      'close': c.close,
      'volume': c.volume,
    }).toList();

    // Indicadores técnicos activos
    final activeIndicators = indicators.where((i) => i.isEnabled).map((i) => {
      'name': i.name,
      'value': i.value,
      'signal': i.trend.name,
      'strength': i.isOverbought ? 'OVERBOUGHT' : i.isOversold ? 'OVERSOLD' : 'NEUTRAL',
    }).toList();

    // Análisis de precio
    final priceAnalysis = _analyzePriceAction(recentCandles, currentPrice);

    return {
      'symbol': symbol,
      'timeframe': timeframe,
      'currentPrice': currentPrice,
      'ohlcv': ohlcvData,
      'indicators': activeIndicators,
      'priceAnalysis': priceAnalysis,
      'marketContext': marketContext ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Análisis de acción del precio
  Map<String, dynamic> _analyzePriceAction(List<Candle> candles, double currentPrice) {
    if (candles.isEmpty) return {};

    final latest = candles.first;
    final previous = candles.length > 1 ? candles[1] : latest;

    // Cálculos básicos
    final priceChange = currentPrice - previous.close;
    final priceChangePercent = (priceChange / previous.close) * 100;
    
    // Volatilidad reciente
    final ranges = candles.take(10).map((c) => c.high - c.low).toList();
    final avgRange = ranges.reduce((a, b) => a + b) / ranges.length;
    final currentRange = latest.high - latest.low;
    final volatilityRatio = currentRange / avgRange;

    // Volumen relativo
    final volumes = candles.take(10).map((c) => c.volume).toList();
    final avgVolume = volumes.reduce((a, b) => a + b) / volumes.length;
    final volumeRatio = latest.volume / avgVolume;

    return {
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
      'volatilityRatio': volatilityRatio,
      'volumeRatio': volumeRatio,
      'trend': priceChange > 0 ? 'BULLISH' : 'BEARISH',
      'momentum': priceChangePercent.abs() > 1 ? 'HIGH' : 'LOW',
    };
  }

  /// Generar prompt optimizado para trading
  String _generateTradingPrompt(Map<String, dynamic> data) {
    return '''
ANÁLISIS PROFESIONAL DE TRADING - ${data['symbol']}
═══════════════════════════════════════════════════

CONTEXTO DEL MERCADO:
📊 Símbolo: ${data['symbol']}
⏰ Timeframe: ${data['timeframe']}
💰 Precio Actual: \$${data['currentPrice'].toStringAsFixed(2)}

DATOS TÉCNICOS RECIENTES:
${_formatOHLCVData(data['ohlcv'])}

INDICADORES TÉCNICOS:
${_formatIndicators(data['indicators'])}

ANÁLISIS DE PRECIO:
${_formatPriceAnalysis(data['priceAnalysis'])}

INSTRUCCIONES DE ANÁLISIS:
Como analista cuantitativo experto, realiza un análisis completo considerando:

1. 📈 ANÁLISIS TÉCNICO
   - Tendencia principal y secundaria
   - Niveles de soporte y resistencia
   - Momentum y volatilidad

2. 🎯 CONFLUENCIA DE SEÑALES
   - Confirmación entre múltiples indicadores
   - Fortaleza de la señal
   - Probabilidad de éxito

3. 💼 GESTIÓN DE RIESGO
   - Niveles óptimos de entrada
   - Stop loss conservador
   - Objetivos de beneficio realistas

4. ⏱️ TIMING
   - Calidad del momento de entrada
   - Expectativas de duración
   - Factores de invalidación

FORMATO DE RESPUESTA REQUERIDO (JSON ESTRICTO):
{
  "recommendation": "STRONG_BUY|BUY|HOLD|SELL|STRONG_SELL",
  "confidence": 85,
  "briefSummary": "Resumen ejecutivo en 1-2 líneas",
  "keyFactors": ["Factor 1", "Factor 2", "Factor 3"],
  "priceTarget": número_decimal,
  "stopLoss": número_decimal,
  "reasoning": "Análisis detallado con evidencias específicas"
}

⚠️ CRÍTICO: Responde ÚNICAMENTE con JSON válido, sin texto adicional.
''';
  }

  /// Formatear datos OHLCV
  String _formatOHLCVData(List<dynamic> ohlcv) {
    final recent = ohlcv.take(5);
    return recent.map((candle) {
      return 'O: ${candle['open'].toStringAsFixed(2)} | H: ${candle['high'].toStringAsFixed(2)} | L: ${candle['low'].toStringAsFixed(2)} | C: ${candle['close'].toStringAsFixed(2)} | V: ${_formatVolume(candle['volume'])}';
    }).join('\n');
  }

  /// Formatear indicadores
  String _formatIndicators(List<dynamic> indicators) {
    return indicators.map((ind) {
      return '${ind['name']}: ${ind['value'].toStringAsFixed(2)} (${ind['signal']}) - ${ind['strength']}';
    }).join('\n');
  }

  /// Formatear análisis de precio
  String _formatPriceAnalysis(Map<String, dynamic> analysis) {
    return '''
Cambio: ${analysis['priceChange']?.toStringAsFixed(2) ?? 'N/A'} (${analysis['priceChangePercent']?.toStringAsFixed(2) ?? 'N/A'}%)
Tendencia: ${analysis['trend'] ?? 'N/A'}
Momentum: ${analysis['momentum'] ?? 'N/A'}
Volatilidad: ${(analysis['volatilityRatio']?.toStringAsFixed(2) ?? 'N/A')}x promedio
Volumen: ${(analysis['volumeRatio']?.toStringAsFixed(2) ?? 'N/A')}x promedio
''';
  }

  /// Formatear volumen
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  /// Hacer petición a API
  Future<String> _makeAPIRequest(String prompt, {int? maxTokens}) async {
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': 'Eres un analista cuantitativo profesional especializado en trading de criptomonedas con certificaciones CFA y CMT. Tu especialidad es el análisis de confluencia técnica y gestión de riesgo.',
        },
        {
          'role': 'user',
          'content': prompt,
        }
      ],
      'max_tokens': maxTokens ?? _maxTokens,
      'temperature': _temperature,
    });

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: headers,
      body: body,
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Groq API Error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Parsear respuesta de análisis
  TradingAIAnalysis _parseAnalysisResponse(String response, String symbol) {
    try {
      // Limpiar respuesta y extraer JSON
      String cleanResponse = response.trim();
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.replaceFirst('```json', '').replaceFirst('```', '');
      }
      
      final jsonData = jsonDecode(cleanResponse);
      
      return TradingAIAnalysis(
        symbol: symbol,
        recommendation: jsonData['recommendation'] ?? 'HOLD',
        confidence: (jsonData['confidence'] ?? 50).toDouble(),
        summary: jsonData['briefSummary'] ?? jsonData['summary'] ?? '',
        keyFactors: List<String>.from(jsonData['keyFactors'] ?? []),
        entryPrice: jsonData['priceTarget']?.toDouble(),
        stopLoss: jsonData['stopLoss']?.toDouble(),
        takeProfit: jsonData['takeProfit']?.toDouble(),
        reasoning: jsonData['reasoning'] ?? '',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _logger.error('Error parseando respuesta de IA: $e');
      _logger.debug('Respuesta raw: $response');
      
      // Fallback con análisis básico
      return TradingAIAnalysis(
        symbol: symbol,
        recommendation: 'HOLD',
        confidence: 50.0,
        summary: 'Error parseando análisis de IA',
        keyFactors: ['Error en parseo de respuesta'],
        reasoning: 'No se pudo procesar la respuesta de IA correctamente',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Respetar rate limits
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _requestCooldown) {
        final waitTime = _requestCooldown - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Limpiar cache
  void clearCache() {
    _analysisCache.clear();
    _logger.info('Cache de análisis limpiado');
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}

/// Extension para convertir TradingAIAnalysis a JSON
extension TradingAIAnalysisJson on TradingAIAnalysis {
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'recommendation': recommendation,
      'confidence': confidence,
      'briefSummary': summary,
      'keyFactors': keyFactors,
      'priceTarget': entryPrice,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'reasoning': reasoning,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
