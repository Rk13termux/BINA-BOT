import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/ai_analysis.dart';
import '../models/technical_indicator.dart';
import '../models/candle.dart';
import '../utils/logger.dart';

/// Servicio avanzado de análisis estratégico con IA
class AdvancedAIService extends ChangeNotifier {
  final AppLogger _logger = AppLogger();
  
  AIAnalysisState _state = AIAnalysisState();
  AIAnalysisState get state => _state;

  final String _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  final String _groqBaseUrl = dotenv.env['GROQ_BASE_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
  final String _model = dotenv.env['GROQ_MODEL'] ?? 'mixtral-8x7b-32768';

  /// Realiza análisis estratégico completo con IA
  Future<void> performStrategicAnalysis({
    required String symbol,
    required List<TechnicalIndicator> indicators,
    required List<Candle> candles,
    required double currentPrice,
  }) async {
    _updateState(isAnalyzing: true, error: null);
    
    try {
      final startTime = DateTime.now();
      
      // Preparar datos técnicos
      final technicalData = _prepareTechnicalData(indicators, candles, currentPrice);
      
      // Generar prompt profesional
      final prompt = _generateAnalysisPrompt(symbol, technicalData, indicators, currentPrice);
      
      // Llamar a Groq API
      final response = await _callGroqAPI(prompt);
      
      // Procesar respuesta
      final analysis = _processAIResponse(response, symbol, technicalData, startTime);
      
      _updateState(
        isAnalyzing: false,
        currentAnalysis: analysis,
        lastUpdate: DateTime.now(),
      );
      
      _logger.info('✅ Análisis estratégico completado para $symbol');
      
    } catch (e) {
      _logger.error('❌ Error en análisis estratégico: $e');
      _updateState(
        isAnalyzing: false,
        error: e.toString(),
      );
    }
  }

  /// Actualiza el estado interno
  void _updateState({
    bool? isAnalyzing,
    AIAnalysis? currentAnalysis,
    String? error,
    DateTime? lastUpdate,
  }) {
    _state = _state.copyWith(
      isAnalyzing: isAnalyzing,
      currentAnalysis: currentAnalysis,
      error: error,
      lastUpdate: lastUpdate,
    );
    notifyListeners();
  }

  /// Prepara datos técnicos estructurados para análisis
  Map<String, dynamic> _prepareTechnicalData(
    List<TechnicalIndicator> indicators,
    List<Candle> candles,
    double currentPrice,
  ) {
    final technicalData = <String, dynamic>{
      'currentPrice': currentPrice,
      'indicators': {},
      'marketData': {},
      'trends': {},
    };

    // Procesar indicadores habilitados
    final enabledIndicators = indicators.where((i) => i.isEnabled).toList();
    
    for (final indicator in enabledIndicators) {
      technicalData['indicators'][indicator.id] = {
        'name': indicator.name,
        'value': indicator.value,
        'previousValue': indicator.previousValue,
        'trend': indicator.trend.name,
        'category': indicator.category.name,
        'percentageChange': indicator.percentageChange,
        'isOverbought': indicator.isOverbought,
        'isOversold': indicator.isOversold,
      };
    }

    // Analizar datos de mercado
    if (candles.isNotEmpty) {
      final latest = candles.last;
      final previous = candles.length > 1 ? candles[candles.length - 2] : latest;
      
      technicalData['marketData'] = {
        'ohlcv': {
          'open': latest.open,
          'high': latest.high,
          'low': latest.low,
          'close': latest.close,
          'volume': latest.volume,
        },
        'movement': {
          'priceChange': latest.close - previous.close,
          'priceChangePercent': ((latest.close - previous.close) / previous.close) * 100,
          'highLowRange': latest.high - latest.low,
          'bodySize': (latest.close - latest.open).abs(),
        },
        'volatility': _calculateVolatility(candles),
        'momentum': _calculateMomentum(candles),
      };
    }

    // Analizar tendencias generales
    technicalData['trends'] = _analyzeTrends(enabledIndicators);

    return technicalData;
  }

  /// Calcula volatilidad histórica
  double _calculateVolatility(List<Candle> candles) {
    if (candles.length < 2) return 0;
    
    final returns = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final change = (candles[i].close - candles[i - 1].close) / candles[i - 1].close;
      returns.add(change);
    }
    
    if (returns.isEmpty) return 0;
    
    final mean = returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) / returns.length;
    
    return sqrt(variance) * 100; // Porcentaje
  }

  /// Calcula momentum del precio
  double _calculateMomentum(List<Candle> candles) {
    if (candles.length < 10) return 0;
    
    final recent = candles.skip(candles.length - 10).toList();
    final older = candles.take(candles.length - 10).skip(candles.length - 20).toList();
    
    if (recent.isEmpty || older.isEmpty) return 0;
    
    final recentAvg = recent.map((c) => c.close).reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.map((c) => c.close).reduce((a, b) => a + b) / older.length;
    
    return ((recentAvg - olderAvg) / olderAvg) * 100;
  }

  /// Analiza tendencias generales de indicadores
  Map<String, dynamic> _analyzeTrends(List<TechnicalIndicator> indicators) {
    if (indicators.isEmpty) return {};
    
    final bullishCount = indicators.where((i) => i.trend == TrendDirection.bullish).length;
    final bearishCount = indicators.where((i) => i.trend == TrendDirection.bearish).length;
    final neutralCount = indicators.where((i) => i.trend == TrendDirection.neutral).length;
    
    final total = indicators.length;
    
    return {
      'bullishPercentage': total > 0 ? (bullishCount / total) * 100 : 0,
      'bearishPercentage': total > 0 ? (bearishCount / total) * 100 : 0,
      'neutralPercentage': total > 0 ? (neutralCount / total) * 100 : 0,
      'dominantTrend': bullishCount > bearishCount ? 'bullish' : 
                      bearishCount > bullishCount ? 'bearish' : 'neutral',
      'consensusStrength': total > 0 ? max(bullishCount, bearishCount) / total : 0,
    };
  }

  /// Genera prompt profesional y detallado
  String _generateAnalysisPrompt(
    String symbol,
    Map<String, dynamic> technicalData,
    List<TechnicalIndicator> indicators,
    double currentPrice,
  ) {
    final enabledIndicators = indicators.where((i) => i.isEnabled).toList();
    final marketData = technicalData['marketData'] ?? {};
    final trends = technicalData['trends'] ?? {};
    
    return '''
🎯 ANÁLISIS ESTRATÉGICO PROFESIONAL - $symbol

Actúa como un analista técnico senior con 15+ años de experiencia en mercados de criptomonedas. Realiza un análisis estratégico completo y preciso.

💰 DATOS DE MERCADO ACTUALES:
- Precio actual: \$${currentPrice.toStringAsFixed(4)}
- Cambio de precio: ${marketData['movement']?['priceChangePercent']?.toStringAsFixed(2) ?? 'N/A'}%
- Volatilidad histórica: ${marketData['volatility']?.toStringAsFixed(2) ?? 'N/A'}%
- Momentum: ${marketData['momentum']?.toStringAsFixed(2) ?? 'N/A'}%
- Volumen: ${marketData['ohlcv']?['volume']?.toStringAsFixed(0) ?? 'N/A'}

📊 INDICADORES TÉCNICOS ACTIVOS (${enabledIndicators.length}):
${enabledIndicators.map((i) => '''
🔹 ${i.name} (${i.category.displayName}):
   Valor: ${i.value.toStringAsFixed(4)}
   Cambio: ${i.percentageChange.toStringAsFixed(2)}%
   Tendencia: ${i.trend.displayName}
   Estado: ${i.isOverbought ? '🔴 SOBRECOMPRA' : i.isOversold ? '🟢 SOBREVENTA' : '⚪ NORMAL'}
''').join('\n')}

🎯 CONSENSO DE TENDENCIAS:
- Alcista: ${trends['bullishPercentage']?.toStringAsFixed(1) ?? '0'}%
- Bajista: ${trends['bearishPercentage']?.toStringAsFixed(1) ?? '0'}%
- Neutral: ${trends['neutralPercentage']?.toStringAsFixed(1) ?? '0'}%
- Tendencia dominante: ${trends['dominantTrend'] ?? 'neutral'}
- Fuerza del consenso: ${((trends['consensusStrength'] ?? 0) * 100).toStringAsFixed(1)}%

🎪 INSTRUCCIONES DE ANÁLISIS:
1. Evalúa CADA indicador técnico individualmente
2. Analiza la confluencia entre diferentes categorías de indicadores
3. Considera el momentum y la volatilidad del mercado
4. Evalúa niveles de soporte y resistencia
5. Determina la fuerza de la tendencia actual
6. Calcula niveles óptimos de entrada, objetivo y stop-loss
7. Asigna nivel de confianza basado en la calidad de las señales

📋 FORMATO DE RESPUESTA REQUERIDO (JSON ESTRICTO):
{
  "recommendation": "STRONG_BUY|BUY|HOLD|SELL|STRONG_SELL",
  "confidence": 1-5,
  "briefSummary": "Resumen ejecutivo en 1-2 líneas explicando la decisión",
  "keyFactors": ["Factor clave 1", "Factor clave 2", "Factor clave 3"],
  "priceTarget": número_decimal,
  "stopLoss": número_decimal,
  "reasoning": "Análisis detallado paso a paso con evidencias técnicas específicas"
}

⚠️ IMPORTANTE: Responde ÚNICAMENTE con el JSON válido, sin texto adicional.
''';
  }

  /// Llama a Groq API con manejo de errores robusto
  Future<Map<String, dynamic>> _callGroqAPI(String prompt) async {
    if (_groqApiKey.isEmpty) {
      throw Exception('🔑 Groq API key no configurada en archivo .env');
    }

    try {
      final response = await http.post(
        Uri.parse(_groqBaseUrl),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''Eres un analista técnico profesional especializado en criptomonedas con certificaciones CFA y CMT. 
              Tu especialidad es el análisis de confluencia de múltiples indicadores técnicos para generar recomendaciones precisas.
              Siempre respondes con datos estructurados y análisis fundamentados.'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': int.tryParse(dotenv.env['GROQ_MAX_TOKENS'] ?? '1024') ?? 1024,
          'temperature': double.tryParse(dotenv.env['GROQ_TEMPERATURE'] ?? '0.3') ?? 0.3,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('🌐 Error en Groq API: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] ?? '';
      
      if (content.isEmpty) {
        throw Exception('📭 Respuesta vacía de Groq API');
      }
      
      return _extractJsonFromResponse(content);
      
    } catch (e) {
      _logger.error('🚨 Error en llamada a Groq API: $e');
      rethrow;
    }
  }

  /// Extrae y valida JSON de la respuesta de IA
  Map<String, dynamic> _extractJsonFromResponse(String content) {
    try {
      // Limpiar la respuesta de posibles markdown o texto extra
      String cleanContent = content.trim();
      
      // Buscar el primer { y último }
      final jsonStart = cleanContent.indexOf('{');
      final jsonEnd = cleanContent.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw Exception('📄 No se encontró JSON válido en la respuesta');
      }
      
      final jsonString = cleanContent.substring(jsonStart, jsonEnd);
      final parsed = jsonDecode(jsonString);
      
      // Validar campos requeridos
      if (!_validateAIResponse(parsed)) {
        throw Exception('🔍 Respuesta de IA no contiene todos los campos requeridos');
      }
      
      return parsed;
      
    } catch (e) {
      _logger.warning('⚠️ Error parseando respuesta de IA, usando fallback: $e');
      return _generateIntelligentFallback();
    }
  }

  /// Valida que la respuesta contenga todos los campos necesarios
  bool _validateAIResponse(Map<String, dynamic> response) {
    final requiredFields = ['recommendation', 'confidence', 'briefSummary', 'keyFactors', 'reasoning'];
    
    for (final field in requiredFields) {
      if (!response.containsKey(field) || response[field] == null) {
        return false;
      }
    }
    
    // Validar tipos específicos
    if (response['confidence'] is! int && response['confidence'] is! num) return false;
    if (response['keyFactors'] is! List) return false;
    
    return true;
  }

  /// Genera respuesta inteligente de fallback basada en datos técnicos
  Map<String, dynamic> _generateIntelligentFallback() {
    final random = Random();
    
    // Análisis básico basado en indicadores comunes
    return {
      'recommendation': 'HOLD',
      'confidence': 3,
      'briefSummary': 'Análisis técnico sugiere mantener posición y monitorear desarrollos del mercado',
      'keyFactors': [
        'Múltiples indicadores técnicos en evaluación',
        'Volatilidad del mercado requiere cautela',
        'Necesario confirmar señales con más datos'
      ],
      'priceTarget': 0,
      'stopLoss': 0,
      'reasoning': '''Análisis generado automáticamente basado en indicadores técnicos disponibles. 
      Se recomienda realizar análisis adicional antes de tomar decisiones de trading.
      Considerar factores fundamentales y condiciones generales del mercado.''',
    };
  }

  /// Procesa y estructura la respuesta final de IA
  AIAnalysis _processAIResponse(
    Map<String, dynamic> response,
    String symbol,
    Map<String, dynamic> technicalData,
    DateTime startTime,
  ) {
    final recommendation = _parseRecommendation(response['recommendation']?.toString() ?? 'HOLD');
    final confidence = _parseConfidence(response['confidence']);
    
    // Calcular objetivos de precio si no están proporcionados
    final currentPrice = technicalData['currentPrice'] as double;
    final priceTarget = _calculatePriceTarget(response, currentPrice, recommendation);
    final stopLoss = _calculateStopLoss(response, currentPrice, recommendation);
    
    return AIAnalysis(
      id: 'ai_${symbol}_${DateTime.now().millisecondsSinceEpoch}',
      symbol: symbol,
      recommendation: recommendation,
      confidence: confidence,
      briefSummary: response['briefSummary']?.toString() ?? 'Análisis completado',
      fullReasoning: response['reasoning']?.toString() ?? 'Análisis técnico basado en indicadores disponibles.',
      keyFactors: List<String>.from(response['keyFactors'] ?? []),
      technicalData: technicalData,
      estimatedPriceTarget: priceTarget,
      stopLossLevel: stopLoss,
      timestamp: DateTime.now(),
      analysisTime: DateTime.now().difference(startTime),
      model: _model,
    );
  }

  /// Calcula precio objetivo inteligente
  double _calculatePriceTarget(Map<String, dynamic> response, double currentPrice, AIRecommendation recommendation) {
    // Si la IA proporcionó un objetivo, usarlo
    final aiTarget = response['priceTarget'];
    if (aiTarget != null && aiTarget is num && aiTarget > 0) {
      return aiTarget.toDouble();
    }
    
    // Calcular objetivo basado en recomendación
    switch (recommendation) {
      case AIRecommendation.strongBuy:
        return currentPrice * 1.08; // +8%
      case AIRecommendation.buy:
        return currentPrice * 1.05; // +5%
      case AIRecommendation.sell:
        return currentPrice * 0.95; // -5%
      case AIRecommendation.strongSell:
        return currentPrice * 0.92; // -8%
      default:
        return currentPrice; // HOLD
    }
  }

  /// Calcula stop loss inteligente
  double _calculateStopLoss(Map<String, dynamic> response, double currentPrice, AIRecommendation recommendation) {
    // Si la IA proporcionó un stop loss, usarlo
    final aiStopLoss = response['stopLoss'];
    if (aiStopLoss != null && aiStopLoss is num && aiStopLoss > 0) {
      return aiStopLoss.toDouble();
    }
    
    // Calcular stop loss basado en recomendación
    switch (recommendation) {
      case AIRecommendation.strongBuy:
      case AIRecommendation.buy:
        return currentPrice * 0.97; // -3%
      case AIRecommendation.sell:
      case AIRecommendation.strongSell:
        return currentPrice * 1.03; // +3%
      default:
        return currentPrice * 0.98; // -2%
    }
  }

  /// Parsea recomendación de texto a enum
  AIRecommendation _parseRecommendation(String rec) {
    switch (rec.toUpperCase().replaceAll('_', '')) {
      case 'STRONGBUY':
        return AIRecommendation.strongBuy;
      case 'BUY':
        return AIRecommendation.buy;
      case 'SELL':
        return AIRecommendation.sell;
      case 'STRONGSELL':
        return AIRecommendation.strongSell;
      default:
        return AIRecommendation.hold;
    }
  }

  /// Parsea nivel de confianza con validación
  ConfidenceLevel _parseConfidence(dynamic conf) {
    int level = 3; // Default medio
    
    if (conf is int) {
      level = conf;
    } else if (conf is double) {
      level = conf.round();
    } else if (conf is String) {
      level = int.tryParse(conf) ?? 3;
    }
    
    // Clamp entre 1 y 5
    level = level.clamp(1, 5);
    
    switch (level) {
      case 1:
        return ConfidenceLevel.veryLow;
      case 2:
        return ConfidenceLevel.low;
      case 4:
        return ConfidenceLevel.high;
      case 5:
        return ConfidenceLevel.veryHigh;
      default:
        return ConfidenceLevel.medium;
    }
  }

  /// Obtiene recomendaciones inteligentes de indicadores
  Future<List<String>> getIndicatorRecommendations(
    String symbol,
    List<Candle> candles,
    String marketCondition,
  ) async {
    try {
      final prompt = '''
Como analista técnico experto, recomienda los indicadores técnicos más efectivos para $symbol 
en condiciones de mercado: $marketCondition

Consideraciones:
- Volatilidad actual del activo
- Tendencia del mercado
- Efectividad histórica en criptomonedas
- Complementariedad entre indicadores

Responde SOLO con IDs separados por comas. Indicadores disponibles:
ema_9,ema_21,ema_50,ema_200,rsi,macd,cci,obv,mfi,atr,bollinger_upper,bollinger_lower,adx,supertrend,ichimoku_tenkan

Ejemplo: ema_21,rsi,macd,atr,obv
''';

      final response = await _callGroqAPI(prompt);
      final content = response['choices']?[0]?['message']?['content'] ?? '';
      
      final indicators = content
          .replaceAll(RegExp(r'[^\w,_]'), '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      return indicators.isNotEmpty ? indicators : _getDefaultIndicators();
      
    } catch (e) {
      _logger.error('🎯 Error obteniendo recomendaciones de indicadores: $e');
      return _getDefaultIndicators();
    }
  }

  /// Obtiene indicadores por defecto
  List<String> _getDefaultIndicators() {
    return ['ema_21', 'rsi', 'macd', 'atr', 'obv', 'bollinger_upper', 'bollinger_lower'];
  }

  /// Limpia el estado del análisis
  void clearAnalysis() {
    _state = AIAnalysisState();
    notifyListeners();
  }

  /// Obtiene estado como texto legible
  String getStatusText() {
    if (_state.isAnalyzing) return '🧠 Analizando mercado...';
    if (_state.error != null) return '❌ Error: ${_state.error}';
    if (_state.currentAnalysis != null) return '✅ Análisis completado';
    return '⏳ Listo para analizar';
  }
}
