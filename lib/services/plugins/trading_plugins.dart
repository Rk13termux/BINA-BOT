import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../models/candle.dart';
import '../../models/signal.dart';
import '../../utils/logger.dart';

/// Convierte un valor de confianza double a ConfidenceLevel
ConfidenceLevel doubleToConfidenceLevel(double confidence) {
  if (confidence >= 80) return ConfidenceLevel.veryHigh;
  if (confidence >= 60) return ConfidenceLevel.high;
  if (confidence >= 40) return ConfidenceLevel.medium;
  return ConfidenceLevel.low;
}

/// Interfaz base para todos los plugins de trading
abstract class TradingPlugin {
  String get name;
  String get description;
  String get version;
  IconData get icon;
  Color get color;
  Map<String, dynamic> get parameters;
  
  // Propiedades de estado
  bool get isActive => _isActive;
  int get totalSignals => _totalSignals;
  double get successRate => _successRate;
  double get avgConfidence => _avgConfidence;
  
  // Variables de estado privadas
  bool _isActive = false;
  int _totalSignals = 0;
  double _successRate = 0.0;
  double _avgConfidence = 0.0;
  
  /// Activar/desactivar plugin
  void setActive(bool active) => _isActive = active;
  
  /// Actualizar estadísticas
  void updateStats(int signals, double success, double confidence) {
    _totalSignals = signals;
    _successRate = success;
    _avgConfidence = confidence;
  }
  
  /// Inicializar el plugin
  Future<void> initialize();
  
  /// Analizar velas y generar señales
  Future<List<Signal>> analyze(List<Candle> candles);
  
  /// Validar parámetros
  bool validateParameters(Map<String, dynamic> params);
  
  /// Obtener configuración UI
  Widget getConfigurationWidget();
  
  /// Limpiar recursos
  void dispose();
}

/// Plugin de Scalping Rápido
class ScalpingPlugin extends TradingPlugin {
  static final AppLogger _logger = AppLogger();
  
  // Parámetros configurables
  double _rsiOverbought = 70.0;
  double _rsiOversold = 30.0;
  int _rsiPeriod = 14;
  double _stopLossPercent = 0.5;
  double _takeProfitPercent = 1.0;
  int _minVolumeMultiplier = 2;

  @override
  String get name => 'Scalping Rápido';

  @override
  String get description => 'Estrategia de scalping para movimientos rápidos basada en RSI y volumen';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.flash_on;

  @override
  Color get color => const Color(0xFFFF6B35);

  @override
  Map<String, dynamic> get parameters => {
    'rsiOverbought': _rsiOverbought,
    'rsiOversold': _rsiOversold,
    'rsiPeriod': _rsiPeriod,
    'stopLossPercent': _stopLossPercent,
    'takeProfitPercent': _takeProfitPercent,
    'minVolumeMultiplier': _minVolumeMultiplier,
  };

  @override
  Future<void> initialize() async {
    _logger.info('Inicializando Scalping Plugin v$version');
  }

  @override
  Future<List<Signal>> analyze(List<Candle> candles) async {
    if (candles.length < _rsiPeriod + 5) return [];

    List<Signal> signals = [];
    
    try {
      // Calcular RSI
      List<double> rsiValues = _calculateRSI(candles, _rsiPeriod);
      
      // Calcular promedio de volumen
      double avgVolume = _calculateAverageVolume(candles, 20);
      
      for (int i = _rsiPeriod; i < candles.length - 1; i++) {
        final current = candles[i];
        final previous = candles[i - 1];
        final rsi = rsiValues[i - _rsiPeriod];
        
        // Condiciones de entrada LONG
        if (rsi < _rsiOversold && 
            current.volume > avgVolume * _minVolumeMultiplier &&
            current.close > previous.close) {
          
          signals.add(Signal(
            id: 'scalp_long_${current.openTime.millisecondsSinceEpoch}',
            symbol: 'BTCUSDT', // Default, se actualizará
            type: SignalType.buy,
            price: current.close,
            timestamp: current.openTime,
            confidence: doubleToConfidenceLevel(_calculateConfidence(rsi, current.volume, avgVolume)),
            reason: 'RSI oversold ($rsi) with high volume',
            source: name,
            metadata: {
              'rsi': rsi,
              'volume_ratio': current.volume / avgVolume,
              'stop_loss': current.close * (1 - _stopLossPercent / 100),
              'take_profit': current.close * (1 + _takeProfitPercent / 100),
              'timeframe': '1m',
            },
          ));
        }
        
        // Condiciones de entrada SHORT
        if (rsi > _rsiOverbought && 
            current.volume > avgVolume * _minVolumeMultiplier &&
            current.close < previous.close) {
          
          signals.add(Signal(
            id: 'scalp_short_${current.openTime.millisecondsSinceEpoch}',
            symbol: 'BTCUSDT',
            type: SignalType.sell,
            price: current.close,
            timestamp: current.openTime,
            confidence: doubleToConfidenceLevel(_calculateConfidence(100 - rsi, current.volume, avgVolume)),
            reason: 'RSI overbought ($rsi) with high volume',
            source: name,
            metadata: {
              'rsi': rsi,
              'volume_ratio': current.volume / avgVolume,
              'stop_loss': current.close * (1 + _stopLossPercent / 100),
              'take_profit': current.close * (1 - _takeProfitPercent / 100),
              'timeframe': '1m',
            },
          ));
        }
      }
    } catch (e) {
      _logger.error('Error en análisis de Scalping: $e');
    }

    return signals;
  }

  double _calculateConfidence(double rsi, double volume, double avgVolume) {
    double rsiScore = rsi < 20 || rsi > 80 ? 0.8 : 0.6;
    double volumeScore = math.min(volume / avgVolume / 5, 1.0);
    return math.min((rsiScore + volumeScore) / 2, 1.0);
  }

  @override
  bool validateParameters(Map<String, dynamic> params) {
    return params.containsKey('rsiOverbought') &&
           params.containsKey('rsiOversold') &&
           params['rsiOverbought'] > params['rsiOversold'];
  }

  @override
  Widget getConfigurationWidget() {
    return ScalpingConfigWidget(plugin: this);
  }

  @override
  void dispose() {
    _logger.info('Disposing Scalping Plugin');
  }

  // Métodos helper
  List<double> _calculateRSI(List<Candle> candles, int period) {
    List<double> rsi = [];
    List<double> gains = [];
    List<double> losses = [];

    for (int i = 1; i < candles.length; i++) {
      double change = candles[i].close - candles[i - 1].close;
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);

      if (i >= period) {
        double avgGain = gains.sublist(i - period, i).reduce((a, b) => a + b) / period;
        double avgLoss = losses.sublist(i - period, i).reduce((a, b) => a + b) / period;
        double rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
        rsi.add(100 - (100 / (1 + rs)));
      }
    }

    return rsi;
  }

  double _calculateAverageVolume(List<Candle> candles, int period) {
    if (candles.length < period) return 0;
    return candles.sublist(candles.length - period)
        .map((c) => c.volume)
        .reduce((a, b) => a + b) / period;
  }
}

/// Plugin de Swing Trading
class SwingTradingPlugin extends TradingPlugin {
  static final AppLogger _logger = AppLogger();
  
  double _macdFastPeriod = 12;
  double _macdSlowPeriod = 26;
  double _macdSignalPeriod = 9;
  double _bollingerPeriod = 20;
  double _bollingerStdDev = 2;

  @override
  String get name => 'Swing Trading';

  @override
  String get description => 'Estrategia de swing trading basada en MACD y Bollinger Bands';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.trending_up;

  @override
  Color get color => const Color(0xFF4CAF50);

  @override
  Map<String, dynamic> get parameters => {
    'macdFastPeriod': _macdFastPeriod,
    'macdSlowPeriod': _macdSlowPeriod,
    'macdSignalPeriod': _macdSignalPeriod,
    'bollingerPeriod': _bollingerPeriod,
    'bollingerStdDev': _bollingerStdDev,
  };

  @override
  Future<void> initialize() async {
    _logger.info('Inicializando Swing Trading Plugin v$version');
  }

  @override
  Future<List<Signal>> analyze(List<Candle> candles) async {
    if (candles.length < _macdSlowPeriod + 10) return [];

    List<Signal> signals = [];
    
    try {
      // Calcular MACD
      Map<String, List<double>> macd = _calculateMACD(candles);
      
      // Calcular Bollinger Bands
      Map<String, List<double>> bollinger = _calculateBollingerBands(candles);
      
      for (int i = _macdSlowPeriod.toInt(); i < candles.length - 1; i++) {
        final current = candles[i];
        int macdIndex = i - _macdSlowPeriod.toInt();
        
        if (macdIndex >= macd['histogram']!.length) continue;
        
        double macdLine = macd['macd']![macdIndex];
        double signalLine = macd['signal']![macdIndex];
        double histogram = macd['histogram']![macdIndex];
        
        double upperBand = bollinger['upper']![macdIndex];
        double lowerBand = bollinger['lower']![macdIndex];
        double middleBand = bollinger['middle']![macdIndex];

        // Señal LONG: MACD cruza señal hacia arriba + precio cerca de banda inferior
        if (histogram > 0 && 
            macd['histogram']![macdIndex - 1] <= 0 &&
            current.close < middleBand &&
            current.close > lowerBand * 1.01) {
          
          signals.add(Signal(
            id: 'swing_long_${current.openTime.millisecondsSinceEpoch}',
            symbol: 'BTCUSDT',
            type: SignalType.buy,
            price: current.close,
            timestamp: current.openTime,
            confidence: ConfidenceLevel.high,
            reason: 'MACD bullish crossover with price near lower Bollinger band',
            source: name,
            metadata: {
              'macd': macdLine,
              'signal': signalLine,
              'histogram': histogram,
              'bollinger_position': (current.close - lowerBand) / (upperBand - lowerBand),
              'timeframe': '4h',
            },
          ));
        }

        // Señal SHORT: MACD cruza señal hacia abajo + precio cerca de banda superior
        if (histogram < 0 && 
            macd['histogram']![macdIndex - 1] >= 0 &&
            current.close > middleBand &&
            current.close < upperBand * 0.99) {
          
          signals.add(Signal(
            id: 'swing_short_${current.openTime.millisecondsSinceEpoch}',
            symbol: 'BTCUSDT',
            type: SignalType.sell,
            price: current.close,
            timestamp: current.openTime,
            confidence: ConfidenceLevel.high,
            reason: 'MACD bearish crossover with price near upper Bollinger band',
            source: name,
            metadata: {
              'macd': macdLine,
              'signal': signalLine,
              'histogram': histogram,
              'bollinger_position': (current.close - lowerBand) / (upperBand - lowerBand),
              'timeframe': '4h',
            },
          ));
        }
      }
    } catch (e) {
      _logger.error('Error en análisis de Swing Trading: $e');
    }

    return signals;
  }

  @override
  bool validateParameters(Map<String, dynamic> params) {
    return params.containsKey('macdFastPeriod') &&
           params.containsKey('macdSlowPeriod') &&
           params['macdFastPeriod'] < params['macdSlowPeriod'];
  }

  @override
  Widget getConfigurationWidget() {
    return SwingTradingConfigWidget(plugin: this);
  }

  @override
  void dispose() {
    _logger.info('Disposing Swing Trading Plugin');
  }

  Map<String, List<double>> _calculateMACD(List<Candle> candles) {
    List<double> ema12 = _calculateEMA(candles, _macdFastPeriod.toInt());
    List<double> ema26 = _calculateEMA(candles, _macdSlowPeriod.toInt());
    
    List<double> macdLine = [];
    for (int i = 0; i < math.min(ema12.length, ema26.length); i++) {
      macdLine.add(ema12[i] - ema26[i]);
    }
    
    List<double> signalLine = _calculateEMAFromValues(macdLine, _macdSignalPeriod.toInt());
    
    List<double> histogram = [];
    for (int i = 0; i < math.min(macdLine.length, signalLine.length); i++) {
      histogram.add(macdLine[i] - signalLine[i]);
    }

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }

  Map<String, List<double>> _calculateBollingerBands(List<Candle> candles) {
    List<double> sma = _calculateSMA(candles, _bollingerPeriod.toInt());
    List<double> upper = [];
    List<double> lower = [];

    for (int i = _bollingerPeriod.toInt() - 1; i < candles.length; i++) {
      List<double> window = candles.sublist(i - _bollingerPeriod.toInt() + 1, i + 1)
          .map((c) => c.close)
          .toList();
      
      double mean = window.reduce((a, b) => a + b) / window.length;
      double variance = window.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) / window.length;
      double stdDev = math.sqrt(variance);

      int smaIndex = i - _bollingerPeriod.toInt() + 1;
      if (smaIndex < sma.length) {
        upper.add(sma[smaIndex] + (_bollingerStdDev * stdDev));
        lower.add(sma[smaIndex] - (_bollingerStdDev * stdDev));
      }
    }

    return {
      'upper': upper,
      'middle': sma,
      'lower': lower,
    };
  }

  List<double> _calculateEMA(List<Candle> candles, int period) {
    if (candles.isEmpty) return [];
    
    List<double> ema = [];
    double multiplier = 2.0 / (period + 1);
    
    // Primer valor es SMA
    double sum = 0;
    for (int i = 0; i < math.min(period, candles.length); i++) {
      sum += candles[i].close;
    }
    ema.add(sum / math.min(period, candles.length));
    
    // Resto son EMA
    for (int i = 1; i < candles.length; i++) {
      ema.add((candles[i].close * multiplier) + (ema[i - 1] * (1 - multiplier)));
    }
    
    return ema;
  }

  List<double> _calculateEMAFromValues(List<double> values, int period) {
    if (values.isEmpty) return [];
    
    List<double> ema = [];
    double multiplier = 2.0 / (period + 1);
    
    ema.add(values[0]);
    
    for (int i = 1; i < values.length; i++) {
      ema.add((values[i] * multiplier) + (ema[i - 1] * (1 - multiplier)));
    }
    
    return ema;
  }

  List<double> _calculateSMA(List<Candle> candles, int period) {
    List<double> sma = [];
    
    for (int i = period - 1; i < candles.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += candles[j].close;
      }
      sma.add(sum / period);
    }
    
    return sma;
  }
}

/// Plugin de Liquidity Sniper
class LiquiditySniperPlugin extends TradingPlugin {
  static final AppLogger _logger = AppLogger();
  
  double _liquidityThreshold = 1000000; // $1M en volumen
  double _priceDeviationPercent = 0.5;
  int _timeWindowMinutes = 5;

  @override
  String get name => 'Liquidity Sniper';

  @override
  String get description => 'Detecta y aprovecha eventos de liquidación masiva';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.gps_fixed;

  @override
  Color get color => const Color(0xFFE91E63);

  @override
  Map<String, dynamic> get parameters => {
    'liquidityThreshold': _liquidityThreshold,
    'priceDeviationPercent': _priceDeviationPercent,
    'timeWindowMinutes': _timeWindowMinutes,
  };

  @override
  Future<void> initialize() async {
    _logger.info('Inicializando Liquidity Sniper Plugin v$version');
  }

  @override
  Future<List<Signal>> analyze(List<Candle> candles) async {
    if (candles.length < 20) return [];

    List<Signal> signals = [];
    
    try {
      for (int i = 10; i < candles.length - 1; i++) {
        final current = candles[i];
        final previous = candles[i - 1];
        
        // Detectar spike de volumen
        double avgVolume = _calculateAverageVolume(candles.sublist(i - 10, i), 10);
        double volumeRatio = current.volume / avgVolume;
        
        // Detectar movimiento de precio significativo
        double priceChange = ((current.close - previous.close) / previous.close).abs();
        
        if (volumeRatio > 3.0 && // Volumen 3x superior al promedio
            priceChange > _priceDeviationPercent / 100 &&
            current.volume * current.close > _liquidityThreshold) {
          
          // Determinar dirección de reversión
          SignalType signalType = current.close < previous.close ? SignalType.buy : SignalType.sell;
          
          signals.add(Signal(
            id: 'liquidity_${signalType.name}_${current.openTime.millisecondsSinceEpoch}',
            symbol: 'BTCUSDT',
            type: signalType,
            price: current.close,
            timestamp: current.openTime,
            confidence: doubleToConfidenceLevel(math.min(volumeRatio / 10, 0.9) * 100),
            reason: 'High volume liquidation event detected (${volumeRatio.toStringAsFixed(1)}x volume)',
            source: name,
            metadata: {
              'volume_ratio': volumeRatio,
              'price_change_percent': priceChange * 100,
              'liquidity_value': current.volume * current.close,
              'reversal_probability': _calculateReversalProbability(volumeRatio, priceChange),
              'timeframe': '1m',
            },
          ));
        }
      }
    } catch (e) {
      _logger.error('Error en análisis de Liquidity Sniper: $e');
    }

    return signals;
  }

  double _calculateReversalProbability(double volumeRatio, double priceChange) {
    double volumeScore = math.min(volumeRatio / 5, 1.0);
    double priceScore = math.min(priceChange * 20, 1.0);
    return (volumeScore + priceScore) / 2;
  }

  double _calculateAverageVolume(List<Candle> candles, int period) {
    if (candles.length < period) return 0;
    return candles.map((c) => c.volume).reduce((a, b) => a + b) / candles.length;
  }

  @override
  bool validateParameters(Map<String, dynamic> params) {
    return params.containsKey('liquidityThreshold') &&
           params['liquidityThreshold'] > 0;
  }

  @override
  Widget getConfigurationWidget() {
    return LiquiditySniperConfigWidget(plugin: this);
  }

  @override
  void dispose() {
    _logger.info('Disposing Liquidity Sniper Plugin');
  }
}

/// Widget de configuración para Scalping Plugin
class ScalpingConfigWidget extends StatefulWidget {
  final ScalpingPlugin plugin;

  const ScalpingConfigWidget({super.key, required this.plugin});

  @override
  State<ScalpingConfigWidget> createState() => _ScalpingConfigWidgetState();
}

class _ScalpingConfigWidgetState extends State<ScalpingConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Configuración de ${widget.plugin.name}',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        // TODO: Agregar sliders y campos de configuración
        const SizedBox(height: 20),
        const Text(
          'Configuración disponible en la próxima actualización',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

/// Widget de configuración para Swing Trading Plugin
class SwingTradingConfigWidget extends StatefulWidget {
  final SwingTradingPlugin plugin;

  const SwingTradingConfigWidget({super.key, required this.plugin});

  @override
  State<SwingTradingConfigWidget> createState() => _SwingTradingConfigWidgetState();
}

class _SwingTradingConfigWidgetState extends State<SwingTradingConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Configuración de ${widget.plugin.name}',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Configuración disponible en la próxima actualización',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

/// Widget de configuración para Liquidity Sniper Plugin
class LiquiditySniperConfigWidget extends StatefulWidget {
  final LiquiditySniperPlugin plugin;

  const LiquiditySniperConfigWidget({super.key, required this.plugin});

  @override
  State<LiquiditySniperConfigWidget> createState() => _LiquiditySniperConfigWidgetState();
}

class _LiquiditySniperConfigWidgetState extends State<LiquiditySniperConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Configuración de ${widget.plugin.name}',
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Configuración disponible en la próxima actualización',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}


