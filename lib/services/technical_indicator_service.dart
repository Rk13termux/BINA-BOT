import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/technical_indicator.dart';
import '../models/candle.dart';
import '../utils/logger.dart';

/// Servicio para calcular indicadores técnicos
class TechnicalIndicatorService extends ChangeNotifier {
  final AppLogger _logger = AppLogger();
  
  List<TechnicalIndicator> _indicators = [];
  Map<String, List<double>> _priceHistory = {};
  Map<String, List<double>> _volumeHistory = {};
  
  List<TechnicalIndicator> get indicators => _indicators;
  List<TechnicalIndicator> get enabledIndicators => 
      _indicators.where((i) => i.isEnabled).toList();

  /// Inicializa los indicadores por defecto
  void initializeIndicators() {
    _indicators = IndicatorFactory.createDefaultIndicators();
    _logger.info('Initialized ${_indicators.length} technical indicators');
    notifyListeners();
  }

  /// Actualiza un indicador específico
  void updateIndicator(String id, {double? value, bool? isEnabled}) {
    final index = _indicators.indexWhere((i) => i.id == id);
    if (index != -1) {
      final indicator = _indicators[index];
      _indicators[index] = indicator.copyWith(
        value: value,
        isEnabled: isEnabled,
        lastUpdate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Habilita/deshabilita un indicador
  void toggleIndicator(String id) {
    final index = _indicators.indexWhere((i) => i.id == id);
    if (index != -1) {
      final indicator = _indicators[index];
      _indicators[index] = indicator.copyWith(
        isEnabled: !indicator.isEnabled,
        lastUpdate: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Calcula todos los indicadores habilitados
  void calculateIndicators(List<Candle> candles, String symbol) {
    if (candles.isEmpty) return;

    try {
      _updatePriceHistory(candles, symbol);
      
      for (int i = 0; i < _indicators.length; i++) {
        if (_indicators[i].isEnabled) {
          _indicators[i] = _calculateIndicator(_indicators[i], candles);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Error calculating indicators: $e');
    }
  }

  /// Actualiza el historial de precios
  void _updatePriceHistory(List<Candle> candles, String symbol) {
    _priceHistory[symbol] = candles.map((c) => c.close).toList();
    _volumeHistory[symbol] = candles.map((c) => c.volume).toList();
  }

  /// Calcula un indicador específico
  TechnicalIndicator _calculateIndicator(TechnicalIndicator indicator, List<Candle> candles) {
    final previousValue = indicator.value;
    double newValue = 0;
    TrendDirection trend = TrendDirection.neutral;
    List<double> sparklineData = [];

    switch (indicator.id) {
      case 'ema_9':
        newValue = _calculateEMA(candles, 9);
        break;
      case 'ema_21':
        newValue = _calculateEMA(candles, 21);
        break;
      case 'ema_50':
        newValue = _calculateEMA(candles, 50);
        break;
      case 'ema_200':
        newValue = _calculateEMA(candles, 200);
        break;
      case 'rsi':
        newValue = _calculateRSI(candles, 14);
        break;
      case 'macd':
        newValue = _calculateMACD(candles)['macd'] ?? 0;
        break;
      case 'cci':
        newValue = _calculateCCI(candles, 20);
        break;
      case 'obv':
        newValue = _calculateOBV(candles);
        break;
      case 'mfi':
        newValue = _calculateMFI(candles, 14);
        break;
      case 'atr':
        newValue = _calculateATR(candles, 14);
        break;
      case 'bollinger_upper':
        newValue = _calculateBollingerBands(candles, 20, 2)['upper'] ?? 0;
        break;
      case 'bollinger_lower':
        newValue = _calculateBollingerBands(candles, 20, 2)['lower'] ?? 0;
        break;
      case 'adx':
        newValue = _calculateADX(candles, 14);
        break;
      case 'supertrend':
        newValue = _calculateSuperTrend(candles, 10, 3.0);
        break;
    }

    // Determinar tendencia
    if (newValue > previousValue) {
      trend = TrendDirection.bullish;
    } else if (newValue < previousValue) {
      trend = TrendDirection.bearish;
    }

    // Generar datos de sparkline (últimos 20 valores)
    sparklineData = _generateSparklineData(indicator.id, candles);

    return indicator.copyWith(
      value: newValue,
      previousValue: previousValue,
      trend: trend,
      lastUpdate: DateTime.now(),
      sparklineData: sparklineData,
    );
  }

  /// Calcula EMA (Exponential Moving Average)
  double _calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) return 0;

    final multiplier = 2.0 / (period + 1);
    double ema = candles.take(period).map((c) => c.close).reduce((a, b) => a + b) / period;

    for (int i = period; i < candles.length; i++) {
      ema = (candles[i].close * multiplier) + (ema * (1 - multiplier));
    }

    return ema;
  }

  /// Calcula RSI (Relative Strength Index)
  double _calculateRSI(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 50;

    double avgGain = 0;
    double avgLoss = 0;

    // Primeros valores
    for (int i = 1; i <= period; i++) {
      final change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }

    avgGain /= period;
    avgLoss /= period;

    // Calcular RSI para el resto de valores
    for (int i = period + 1; i < candles.length; i++) {
      final change = candles[i].close - candles[i - 1].close;
      
      if (change > 0) {
        avgGain = (avgGain * (period - 1) + change) / period;
        avgLoss = (avgLoss * (period - 1)) / period;
      } else {
        avgGain = (avgGain * (period - 1)) / period;
        avgLoss = (avgLoss * (period - 1) + change.abs()) / period;
      }
    }

    if (avgLoss == 0) return 100;
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calcula MACD
  Map<String, double> _calculateMACD(List<Candle> candles) {
    final ema12 = _calculateEMA(candles, 12);
    final ema26 = _calculateEMA(candles, 26);
    final macd = ema12 - ema26;
    
    return {
      'macd': macd,
      'signal': 0, // Simplificado por ahora
      'histogram': macd,
    };
  }

  /// Calcula CCI (Commodity Channel Index)
  double _calculateCCI(List<Candle> candles, int period) {
    if (candles.length < period) return 0;

    final recentCandles = candles.take(period).toList();
    final typicalPrices = recentCandles.map((c) => (c.high + c.low + c.close) / 3).toList();
    final sma = typicalPrices.reduce((a, b) => a + b) / period;
    
    final meanDeviation = typicalPrices.map((tp) => (tp - sma).abs()).reduce((a, b) => a + b) / period;
    
    if (meanDeviation == 0) return 0;
    
    final currentTypicalPrice = (candles.last.high + candles.last.low + candles.last.close) / 3;
    return (currentTypicalPrice - sma) / (0.015 * meanDeviation);
  }

  /// Calcula OBV (On Balance Volume)
  double _calculateOBV(List<Candle> candles) {
    if (candles.length < 2) return 0;

    double obv = 0;
    for (int i = 1; i < candles.length; i++) {
      if (candles[i].close > candles[i - 1].close) {
        obv += candles[i].volume;
      } else if (candles[i].close < candles[i - 1].close) {
        obv -= candles[i].volume;
      }
    }
    return obv;
  }

  /// Calcula MFI (Money Flow Index)
  double _calculateMFI(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 50;

    double positiveFlow = 0;
    double negativeFlow = 0;

    for (int i = 1; i <= period; i++) {
      final typicalPrice = (candles[i].high + candles[i].low + candles[i].close) / 3;
      final prevTypicalPrice = (candles[i - 1].high + candles[i - 1].low + candles[i - 1].close) / 3;
      final moneyFlow = typicalPrice * candles[i].volume;

      if (typicalPrice > prevTypicalPrice) {
        positiveFlow += moneyFlow;
      } else if (typicalPrice < prevTypicalPrice) {
        negativeFlow += moneyFlow;
      }
    }

    if (negativeFlow == 0) return 100;
    final moneyRatio = positiveFlow / negativeFlow;
    return 100 - (100 / (1 + moneyRatio));
  }

  /// Calcula ATR (Average True Range)
  double _calculateATR(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 0;

    double atr = 0;
    for (int i = 1; i <= period; i++) {
      final trueRange = max(
        max(
          candles[i].high - candles[i].low,
          (candles[i].high - candles[i - 1].close).abs(),
        ),
        (candles[i].low - candles[i - 1].close).abs(),
      );
      atr += trueRange;
    }

    return atr / period;
  }

  /// Calcula Bollinger Bands
  Map<String, double> _calculateBollingerBands(List<Candle> candles, int period, double deviation) {
    if (candles.length < period) return {'upper': 0, 'middle': 0, 'lower': 0};

    final recentCandles = candles.take(period).toList();
    final closes = recentCandles.map((c) => c.close).toList();
    final sma = closes.reduce((a, b) => a + b) / period;
    
    final variance = closes.map((c) => pow(c - sma, 2)).reduce((a, b) => a + b) / period;
    final stdDev = sqrt(variance);

    return {
      'upper': sma + (deviation * stdDev),
      'middle': sma,
      'lower': sma - (deviation * stdDev),
    };
  }

  /// Calcula ADX (Average Directional Index)
  double _calculateADX(List<Candle> candles, int period) {
    if (candles.length < period * 2) return 25;

    // Simplificación del cálculo ADX
    double trSum = 0;
    double plusDMSum = 0;
    double minusDMSum = 0;

    for (int i = 1; i < min(period + 1, candles.length); i++) {
      final tr = max(
        max(
          candles[i].high - candles[i].low,
          (candles[i].high - candles[i - 1].close).abs(),
        ),
        (candles[i].low - candles[i - 1].close).abs(),
      );
      
      final plusDM = max(0, candles[i].high - candles[i - 1].high);
      final minusDM = max(0, candles[i - 1].low - candles[i].low);

      trSum += tr;
      plusDMSum += plusDM;
      minusDMSum += minusDM;
    }

    if (trSum == 0) return 25;

    final plusDI = (plusDMSum / trSum) * 100;
    final minusDI = (minusDMSum / trSum) * 100;
    final dx = ((plusDI - minusDI).abs() / (plusDI + minusDI)) * 100;

    return dx;
  }

  /// Calcula SuperTrend
  double _calculateSuperTrend(List<Candle> candles, int period, double multiplier) {
    if (candles.length < period) return 0;

    final atr = _calculateATR(candles, period);
    final hl2 = (candles.last.high + candles.last.low) / 2;
    
    return hl2 + (multiplier * atr);
  }

  /// Genera datos de sparkline para un indicador
  List<double> _generateSparklineData(String indicatorId, List<Candle> candles) {
    const sparklineLength = 20;
    if (candles.length < sparklineLength) return [];

    final recentCandles = candles.skip(max(0, candles.length - sparklineLength)).toList();
    
    // Para este ejemplo, usamos los precios de cierre como sparkline
    // En una implementación real, calcularíamos el indicador para cada punto
    return recentCandles.map((c) => c.close).toList();
  }

  /// Obtiene indicadores por categoría
  List<TechnicalIndicator> getIndicatorsByCategory(IndicatorCategory category) {
    return _indicators.where((i) => i.category == category).toList();
  }

  /// Busca indicadores por texto
  List<TechnicalIndicator> searchIndicators(String query) {
    if (query.isEmpty) return _indicators;
    
    final lowQuery = query.toLowerCase();
    return _indicators.where((i) => 
      i.name.toLowerCase().contains(lowQuery) ||
      i.description.toLowerCase().contains(lowQuery)
    ).toList();
  }

  /// Obtiene resumen de indicadores habilitados
  Map<String, dynamic> getIndicatorsSummary() {
    final enabled = enabledIndicators;
    final bullish = enabled.where((i) => i.trend == TrendDirection.bullish).length;
    final bearish = enabled.where((i) => i.trend == TrendDirection.bearish).length;
    final neutral = enabled.where((i) => i.trend == TrendDirection.neutral).length;

    return {
      'total': enabled.length,
      'bullish': bullish,
      'bearish': bearish,
      'neutral': neutral,
      'bullishPercentage': enabled.isNotEmpty ? (bullish / enabled.length) * 100 : 0,
      'bearishPercentage': enabled.isNotEmpty ? (bearish / enabled.length) * 100 : 0,
    };
  }
}
