import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../services/binance_service.dart';
import '../services/ai_service_professional.dart';
import '../utils/logger.dart';
import '../models/candle.dart';

/// Servicio profesional de datos en tiempo real con análisis técnico
class DataStreamService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();

  // Servicios dependientes
  final BinanceService _binanceService;
  final AIService _aiService;

  // Configuración
  static const Duration _refreshInterval = Duration(milliseconds: 500);
  
  // Estado del servicio
  bool _isRunning = false;
  Timer? _dataTimer;
  String _currentSymbol = 'BTCUSDT';
  String _currentTimeframe = '1m';

  // Datos en tiempo real
  List<Candle> _candleData = [];
  Map<String, double> _technicalIndicators = {};
  Map<String, dynamic> _aiAnalysis = {};
  double _currentPrice = 0.0;
  
  // Cache para optimización
  DateTime? _lastCandleUpdate;
  DateTime? _lastIndicatorUpdate;
  DateTime? _lastAIUpdate;

  // Configuración de indicadores
  final Map<String, bool> _enabledIndicators = {
    'SMA_20': true,
    'SMA_50': true,
    'EMA_12': true,
    'EMA_26': true,
    'RSI_14': true,
    'MACD': true,
    'BB_UPPER': true,
    'BB_LOWER': true,
    'ATR_14': true,
    'OBV': true,
    'CCI_20': true,
    'STOCH_K': true,
    'STOCH_D': true,
    'WILLIAMS_R': true,
    'MFI_14': true,
    'ADX_14': true,
    'VWAP': true,
    'PIVOT_POINT': true,
    'SUPPORT_1': true,
    'RESISTANCE_1': true,
    'FIBONACCI_382': true,
    'FIBONACCI_618': true,
    'ICHIMOKU_TENKAN': true,
    'ICHIMOKU_KIJUN': true,
    'PARABOLIC_SAR': true,
    'VOLUME_SMA': true,
    'PRICE_VOLUME_TREND': true,
    'CHAIKIN_OSCILLATOR': true,
    'ULTIMATE_OSCILLATOR': true,
    'COMMODITY_CHANNEL': true,
  };

  DataStreamService({
    required BinanceService binanceService,
    required AIService aiService,
  }) : _binanceService = binanceService,
       _aiService = aiService;

  // Getters
  bool get isRunning => _isRunning;
  String get currentSymbol => _currentSymbol;
  String get currentTimeframe => _currentTimeframe;
  List<Candle> get candleData => List.unmodifiable(_candleData);
  Map<String, double> get technicalIndicators => Map.unmodifiable(_technicalIndicators);
  Map<String, dynamic> get aiAnalysis => Map.unmodifiable(_aiAnalysis);
  double get currentPrice => _currentPrice;
  Map<String, bool> get enabledIndicators => Map.unmodifiable(_enabledIndicators);

  /// Inicializar el servicio de datos
  Future<void> initialize() async {
    try {
      _logger.info('📊 Inicializando Data Stream Service...');
      
      // Cargar datos iniciales
      await _loadInitialData();
      
      _logger.info('✅ Data Stream Service inicializado');
      notifyListeners();
    } catch (e) {
      _logger.error('❌ Error inicializando Data Stream Service: $e');
      rethrow;
    }
  }

  /// Cambiar símbolo de trading
  Future<void> setSymbol(String symbol) async {
    if (symbol != _currentSymbol) {
      _currentSymbol = symbol.toUpperCase();
      _logger.info('📈 Cambiando símbolo a: $_currentSymbol');
      
      // Limpiar datos anteriores
      _candleData.clear();
      _technicalIndicators.clear();
      _aiAnalysis.clear();
      
      // Recargar datos
      if (_isRunning) {
        await _loadInitialData();
      }
      
      notifyListeners();
    }
  }

  /// Cambiar timeframe
  Future<void> setTimeframe(String timeframe) async {
    if (timeframe != _currentTimeframe) {
      _currentTimeframe = timeframe;
      _logger.info('⏱️ Cambiando timeframe a: $_currentTimeframe');
      
      // Recargar datos con nuevo timeframe
      if (_isRunning) {
        await _loadInitialData();
      }
      
      notifyListeners();
    }
  }

  /// Activar/desactivar indicador específico
  void toggleIndicator(String indicator, bool enabled) {
    if (_enabledIndicators.containsKey(indicator)) {
      _enabledIndicators[indicator] = enabled;
      _logger.debug('📊 ${enabled ? "Activado" : "Desactivado"} indicador: $indicator');
      
      if (_isRunning) {
        _updateTechnicalIndicators();
      }
      
      notifyListeners();
    }
  }

  /// Iniciar stream de datos en tiempo real
  Future<void> startDataStream() async {
    if (_isRunning) return;

    try {
      _logger.info('🚀 Iniciando stream de datos en tiempo real...');
      _isRunning = true;

      // Cargar datos iniciales si no existen
      if (_candleData.isEmpty) {
        await _loadInitialData();
      }

      // Iniciar timer de actualización
      _dataTimer = Timer.periodic(_refreshInterval, (_) async {
        await _updateDataCycle();
      });

      _logger.info('✅ Stream de datos iniciado correctamente');
      notifyListeners();
    } catch (e) {
      _logger.error('❌ Error iniciando stream de datos: $e');
      _isRunning = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Detener stream de datos
  void stopDataStream() {
    if (!_isRunning) return;

    _logger.info('⏹️ Deteniendo stream de datos...');
    _isRunning = false;
    _dataTimer?.cancel();
    _dataTimer = null;
    
    _logger.info('✅ Stream de datos detenido');
    notifyListeners();
  }

  /// Cargar datos iniciales
  Future<void> _loadInitialData() async {
    try {
      // Obtener datos de velas
      _candleData = await _binanceService.getCandles(
        symbol: _currentSymbol,
        interval: _currentTimeframe,
        limit: 200, // Suficientes para cálculos técnicos
      );

      // Obtener precio actual
      _currentPrice = await _binanceService.getPrice(_currentSymbol);

      // Calcular indicadores técnicos
      _updateTechnicalIndicators();

      // Actualizar timestamps
      _lastCandleUpdate = DateTime.now();
      _lastIndicatorUpdate = DateTime.now();

      _logger.debug('📊 Datos iniciales cargados: ${_candleData.length} velas');
    } catch (e) {
      _logger.error('❌ Error cargando datos iniciales: $e');
      rethrow;
    }
  }

  /// Ciclo principal de actualización de datos
  Future<void> _updateDataCycle() async {
    try {
      final now = DateTime.now();
      
      // Actualizar precio actual (cada ciclo)
      await _updateCurrentPrice();
      
      // Actualizar velas cada 30 segundos
      if (_lastCandleUpdate == null || 
          now.difference(_lastCandleUpdate!).inSeconds >= 30) {
        await _updateCandleData();
        _lastCandleUpdate = now;
      }
      
      // Actualizar indicadores cada 10 segundos
      if (_lastIndicatorUpdate == null || 
          now.difference(_lastIndicatorUpdate!).inSeconds >= 10) {
        _updateTechnicalIndicators();
        _lastIndicatorUpdate = now;
      }
      
      // Actualizar análisis IA cada 2 minutos
      if (_aiService.isAvailable && 
          (_lastAIUpdate == null || 
           now.difference(_lastAIUpdate!).inMinutes >= 2)) {
        await _updateAIAnalysis();
        _lastAIUpdate = now;
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('❌ Error en ciclo de actualización: $e');
    }
  }

  /// Actualizar precio actual
  Future<void> _updateCurrentPrice() async {
    try {
      _currentPrice = await _binanceService.getPrice(_currentSymbol);
    } catch (e) {
      _logger.error('❌ Error actualizando precio: $e');
    }
  }

  /// Actualizar datos de velas
  Future<void> _updateCandleData() async {
    try {
      final newCandles = await _binanceService.getCandles(
        symbol: _currentSymbol,
        interval: _currentTimeframe,
        limit: 50, // Solo las últimas velas
      );

      if (newCandles.isNotEmpty) {
        // Mergear nuevas velas evitando duplicados
        for (final newCandle in newCandles) {
          final existingIndex = _candleData.indexWhere(
            (candle) => candle.openTime == newCandle.openTime,
          );
          
          if (existingIndex != -1) {
            _candleData[existingIndex] = newCandle; // Actualizar
          } else {
            _candleData.add(newCandle); // Agregar nueva
          }
        }

        // Mantener solo las últimas 200 velas
        if (_candleData.length > 200) {
          _candleData = _candleData.sublist(_candleData.length - 200);
        }

        // Ordenar por tiempo
        _candleData.sort((a, b) => a.openTime.compareTo(b.openTime));
      }
    } catch (e) {
      _logger.error('❌ Error actualizando velas: $e');
    }
  }

  /// Actualizar indicadores técnicos
  void _updateTechnicalIndicators() {
    if (_candleData.length < 50) return; // Necesitamos suficientes datos

    try {
      final closes = _candleData.map((c) => c.close).toList();
      final highs = _candleData.map((c) => c.high).toList();
      final lows = _candleData.map((c) => c.low).toList();
      final volumes = _candleData.map((c) => c.volume).toList();

      // Limpiar indicadores anteriores
      _technicalIndicators.clear();

      // === MEDIAS MÓVILES ===
      if (_enabledIndicators['SMA_20'] == true) {
        _technicalIndicators['SMA_20'] = _calculateSMA(closes, 20);
      }
      if (_enabledIndicators['SMA_50'] == true) {
        _technicalIndicators['SMA_50'] = _calculateSMA(closes, 50);
      }
      if (_enabledIndicators['EMA_12'] == true) {
        _technicalIndicators['EMA_12'] = _calculateEMA(closes, 12);
      }
      if (_enabledIndicators['EMA_26'] == true) {
        _technicalIndicators['EMA_26'] = _calculateEMA(closes, 26);
      }

      // === OSCILADORES ===
      if (_enabledIndicators['RSI_14'] == true) {
        _technicalIndicators['RSI_14'] = _calculateRSI(closes, 14);
      }
      if (_enabledIndicators['STOCH_K'] == true || _enabledIndicators['STOCH_D'] == true) {
        final stoch = _calculateStochastic(highs, lows, closes, 14);
        if (_enabledIndicators['STOCH_K'] == true) {
          _technicalIndicators['STOCH_K'] = stoch['k']!;
        }
        if (_enabledIndicators['STOCH_D'] == true) {
          _technicalIndicators['STOCH_D'] = stoch['d']!;
        }
      }
      if (_enabledIndicators['WILLIAMS_R'] == true) {
        _technicalIndicators['WILLIAMS_R'] = _calculateWilliamsR(highs, lows, closes, 14);
      }
      if (_enabledIndicators['MFI_14'] == true) {
        _technicalIndicators['MFI_14'] = _calculateMFI(highs, lows, closes, volumes, 14);
      }

      // === MACD ===
      if (_enabledIndicators['MACD'] == true) {
        final macd = _calculateMACD(closes);
        _technicalIndicators['MACD_LINE'] = macd['macd']!;
        _technicalIndicators['MACD_SIGNAL'] = macd['signal']!;
        _technicalIndicators['MACD_HISTOGRAM'] = macd['histogram']!;
      }

      // === BOLLINGER BANDS ===
      if (_enabledIndicators['BB_UPPER'] == true || _enabledIndicators['BB_LOWER'] == true) {
        final bb = _calculateBollingerBands(closes, 20, 2.0);
        if (_enabledIndicators['BB_UPPER'] == true) {
          _technicalIndicators['BB_UPPER'] = bb['upper']!;
        }
        if (_enabledIndicators['BB_LOWER'] == true) {
          _technicalIndicators['BB_LOWER'] = bb['lower']!;
        }
        _technicalIndicators['BB_MIDDLE'] = bb['middle']!;
      }

      // === ATR ===
      if (_enabledIndicators['ATR_14'] == true) {
        _technicalIndicators['ATR_14'] = _calculateATR(highs, lows, closes, 14);
      }

      // === VOLUMEN ===
      if (_enabledIndicators['OBV'] == true) {
        _technicalIndicators['OBV'] = _calculateOBV(closes, volumes);
      }
      if (_enabledIndicators['VOLUME_SMA'] == true) {
        _technicalIndicators['VOLUME_SMA'] = _calculateSMA(volumes, 20);
      }

      // === OTROS INDICADORES ===
      if (_enabledIndicators['CCI_20'] == true) {
        _technicalIndicators['CCI_20'] = _calculateCCI(highs, lows, closes, 20);
      }
      if (_enabledIndicators['ADX_14'] == true) {
        _technicalIndicators['ADX_14'] = _calculateADX(highs, lows, closes, 14);
      }
      if (_enabledIndicators['VWAP'] == true) {
        _technicalIndicators['VWAP'] = _calculateVWAP(highs, lows, closes, volumes);
      }

      // === NIVELES DE SOPORTE/RESISTENCIA ===
      if (_enabledIndicators['PIVOT_POINT'] == true) {
        final pivot = _calculatePivotPoints(highs.last, lows.last, closes.last);
        _technicalIndicators['PIVOT_POINT'] = pivot['pivot']!;
        if (_enabledIndicators['SUPPORT_1'] == true) {
          _technicalIndicators['SUPPORT_1'] = pivot['s1']!;
        }
        if (_enabledIndicators['RESISTANCE_1'] == true) {
          _technicalIndicators['RESISTANCE_1'] = pivot['r1']!;
        }
      }

      _logger.debug('📊 Indicadores actualizados: ${_technicalIndicators.length}');
    } catch (e) {
      _logger.error('❌ Error calculando indicadores técnicos: $e');
    }
  }

  /// Actualizar análisis de IA
  Future<void> _updateAIAnalysis() async {
    try {
      if (_candleData.length < 20 || _technicalIndicators.isEmpty) return;

      // Preparar datos para IA
      final candleData = _candleData.takeLast(20).map((candle) => {
        'open': candle.open,
        'high': candle.high,
        'low': candle.low,
        'close': candle.close,
        'volume': candle.volume,
      }).toList();

      // Obtener análisis técnico de IA
      _aiAnalysis = await _aiService.analyzeTechnicalIndicators(
        symbol: _currentSymbol,
        candleData: candleData,
        indicators: _technicalIndicators,
      );

      _logger.debug('🧠 Análisis IA actualizado');
    } catch (e) {
      _logger.error('❌ Error en análisis IA: $e');
    }
  }

  // === MÉTODOS DE CÁLCULO DE INDICADORES TÉCNICOS ===

  /// Calcular SMA (Simple Moving Average)
  double _calculateSMA(List<double> prices, int period) {
    if (prices.length < period) return 0.0;
    final slice = prices.sublist(prices.length - period);
    return slice.reduce((a, b) => a + b) / period;
  }

  /// Calcular EMA (Exponential Moving Average)
  double _calculateEMA(List<double> prices, int period) {
    if (prices.length < period) return 0.0;
    
    final multiplier = 2.0 / (period + 1);
    double ema = _calculateSMA(prices.sublist(0, period), period);
    
    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] * multiplier) + (ema * (1 - multiplier));
    }
    
    return ema;
  }

  /// Calcular RSI (Relative Strength Index)
  double _calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return 50.0;
    
    double gains = 0.0;
    double losses = 0.0;
    
    for (int i = prices.length - period; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }
    
    final avgGain = gains / period;
    final avgLoss = losses / period;
    
    if (avgLoss == 0) return 100.0;
    
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calcular MACD
  Map<String, double> _calculateMACD(List<double> prices) {
    final ema12 = _calculateEMA(prices, 12);
    final ema26 = _calculateEMA(prices, 26);
    final macdLine = ema12 - ema26;
    
    // Para el signal, necesitaríamos calcular EMA del MACD line
    // Simplificado para demo
    final signal = macdLine * 0.9; // Aproximación
    final histogram = macdLine - signal;
    
    return {
      'macd': macdLine,
      'signal': signal,
      'histogram': histogram,
    };
  }

  /// Calcular Bollinger Bands
  Map<String, double> _calculateBollingerBands(List<double> prices, int period, double stdDev) {
    final sma = _calculateSMA(prices, period);
    
    // Calcular desviación estándar
    final slice = prices.sublist(prices.length - period);
    final variance = slice.map((price) => math.pow(price - sma, 2)).reduce((a, b) => a + b) / period;
    final standardDeviation = math.sqrt(variance);
    
    return {
      'upper': sma + (standardDeviation * stdDev),
      'middle': sma,
      'lower': sma - (standardDeviation * stdDev),
    };
  }

  /// Calcular ATR (Average True Range)
  double _calculateATR(List<double> highs, List<double> lows, List<double> closes, int period) {
    if (highs.length < period + 1) return 0.0;
    
    final trueRanges = <double>[];
    
    for (int i = 1; i < highs.length && i <= period; i++) {
      final tr1 = highs[i] - lows[i];
      final tr2 = (highs[i] - closes[i - 1]).abs();
      final tr3 = (lows[i] - closes[i - 1]).abs();
      trueRanges.add([tr1, tr2, tr3].reduce(math.max));
    }
    
    return trueRanges.reduce((a, b) => a + b) / trueRanges.length;
  }

  /// Calcular Stochastic Oscillator
  Map<String, double> _calculateStochastic(List<double> highs, List<double> lows, List<double> closes, int period) {
    if (closes.length < period) return {'k': 50.0, 'd': 50.0};
    
    final slice = closes.length - period;
    final highestHigh = highs.sublist(slice).reduce(math.max);
    final lowestLow = lows.sublist(slice).reduce(math.min);
    
    final kPercent = ((closes.last - lowestLow) / (highestHigh - lowestLow)) * 100;
    final dPercent = kPercent * 0.9; // Simplificado
    
    return {
      'k': kPercent,
      'd': dPercent,
    };
  }

  /// Calcular Williams %R
  double _calculateWilliamsR(List<double> highs, List<double> lows, List<double> closes, int period) {
    if (closes.length < period) return -50.0;
    
    final slice = closes.length - period;
    final highestHigh = highs.sublist(slice).reduce(math.max);
    final lowestLow = lows.sublist(slice).reduce(math.min);
    
    return ((highestHigh - closes.last) / (highestHigh - lowestLow)) * -100;
  }

  /// Calcular Money Flow Index (MFI)
  double _calculateMFI(List<double> highs, List<double> lows, List<double> closes, List<double> volumes, int period) {
    if (closes.length < period + 1) return 50.0;
    
    double positiveFlow = 0.0;
    double negativeFlow = 0.0;
    
    for (int i = closes.length - period; i < closes.length; i++) {
      final typicalPrice = (highs[i] + lows[i] + closes[i]) / 3;
      final previousTypicalPrice = (highs[i - 1] + lows[i - 1] + closes[i - 1]) / 3;
      final moneyFlow = typicalPrice * volumes[i];
      
      if (typicalPrice > previousTypicalPrice) {
        positiveFlow += moneyFlow;
      } else {
        negativeFlow += moneyFlow;
      }
    }
    
    if (negativeFlow == 0) return 100.0;
    
    final moneyRatio = positiveFlow / negativeFlow;
    return 100 - (100 / (1 + moneyRatio));
  }

  /// Calcular OBV (On Balance Volume)
  double _calculateOBV(List<double> closes, List<double> volumes) {
    if (closes.length < 2) return 0.0;
    
    double obv = 0.0;
    
    for (int i = 1; i < closes.length; i++) {
      if (closes[i] > closes[i - 1]) {
        obv += volumes[i];
      } else if (closes[i] < closes[i - 1]) {
        obv -= volumes[i];
      }
    }
    
    return obv;
  }

  /// Calcular CCI (Commodity Channel Index)
  double _calculateCCI(List<double> highs, List<double> lows, List<double> closes, int period) {
    if (closes.length < period) return 0.0;
    
    final typicalPrices = <double>[];
    for (int i = 0; i < closes.length; i++) {
      typicalPrices.add((highs[i] + lows[i] + closes[i]) / 3);
    }
    
    final sma = _calculateSMA(typicalPrices, period);
    final slice = typicalPrices.sublist(typicalPrices.length - period);
    final meanDeviation = slice.map((tp) => (tp - sma).abs()).reduce((a, b) => a + b) / period;
    
    return (typicalPrices.last - sma) / (0.015 * meanDeviation);
  }

  /// Calcular ADX (Average Directional Index)
  double _calculateADX(List<double> highs, List<double> lows, List<double> closes, int period) {
    // Implementación simplificada del ADX
    if (closes.length < period + 1) return 25.0;
    
    double plusDM = 0.0;
    double minusDM = 0.0;
    
    for (int i = 1; i < closes.length && i <= period; i++) {
      final highDiff = highs[i] - highs[i - 1];
      final lowDiff = lows[i - 1] - lows[i];
      
      if (highDiff > lowDiff && highDiff > 0) {
        plusDM += highDiff;
      } else if (lowDiff > highDiff && lowDiff > 0) {
        minusDM += lowDiff;
      }
    }
    
    final atr = _calculateATR(highs, lows, closes, period);
    final plusDI = (plusDM / period) / atr * 100;
    final minusDI = (minusDM / period) / atr * 100;
    
    return ((plusDI - minusDI).abs() / (plusDI + minusDI)) * 100;
  }

  /// Calcular VWAP (Volume Weighted Average Price)
  double _calculateVWAP(List<double> highs, List<double> lows, List<double> closes, List<double> volumes) {
    if (closes.isEmpty) return 0.0;
    
    double totalVolume = 0.0;
    double totalVolumePrice = 0.0;
    
    for (int i = 0; i < closes.length; i++) {
      final typicalPrice = (highs[i] + lows[i] + closes[i]) / 3;
      totalVolumePrice += typicalPrice * volumes[i];
      totalVolume += volumes[i];
    }
    
    return totalVolume > 0 ? totalVolumePrice / totalVolume : 0.0;
  }

  /// Calcular Pivot Points
  Map<String, double> _calculatePivotPoints(double high, double low, double close) {
    final pivot = (high + low + close) / 3;
    final r1 = (2 * pivot) - low;
    final s1 = (2 * pivot) - high;
    
    return {
      'pivot': pivot,
      'r1': r1,
      's1': s1,
    };
  }

  /// Obtener resumen completo del estado
  Map<String, dynamic> getCompleteStatus() {
    return {
      'is_running': _isRunning,
      'current_symbol': _currentSymbol,
      'current_timeframe': _currentTimeframe,
      'current_price': _currentPrice,
      'candle_count': _candleData.length,
      'indicators_count': _technicalIndicators.length,
      'ai_analysis_available': _aiAnalysis.isNotEmpty,
      'enabled_indicators': _enabledIndicators.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      'last_update': DateTime.now().toIso8601String(),
    };
  }

  @override
  void dispose() {
    stopDataStream();
    super.dispose();
  }
}

/// Extensión para obtener los últimos N elementos de una lista
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
