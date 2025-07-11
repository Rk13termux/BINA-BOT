import 'package:flutter/foundation.dart';
import '../../models/signal.dart';
import '../../services/binance_service.dart';
import '../../services/notification_service.dart';
import '../../utils/logger.dart';

/// Alert condition types
enum AlertCondition {
  priceAbove,
  priceBelow,
  rsiAbove,
  rsiBelow,
  volumeAbove,
  priceChange,
}

/// Alert model
class PriceAlert {
  final String id;
  final String symbol;
  final AlertCondition condition;
  final double value;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? triggeredAt;
  final String? description;

  PriceAlert({
    required this.id,
    required this.symbol,
    required this.condition,
    required this.value,
    this.isEnabled = true,
    required this.createdAt,
    this.triggeredAt,
    this.description,
  });

  PriceAlert copyWith({
    String? id,
    String? symbol,
    AlertCondition? condition,
    double? value,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? triggeredAt,
    String? description,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      description: description ?? this.description,
    );
  }
}

class AlertsController extends ChangeNotifier {
  final BinanceService _binanceService = BinanceService();
  final NotificationService _notificationService = NotificationService();
  final AppLogger _logger = AppLogger();

  // State variables
  final List<PriceAlert> _alerts = [];
  final List<Signal> _signals = [];
  bool _isMonitoring = false;
  String? _error;

  // Getters
  List<PriceAlert> get alerts => List.unmodifiable(_alerts);
  List<Signal> get signals => List.unmodifiable(_signals);
  bool get isMonitoring => _isMonitoring;
  String? get error => _error;

  /// Initialize alerts controller
  Future<void> initialize() async {
    try {
      await _binanceService.initialize();
      await _notificationService.initialize();
      _logger.info('Alerts controller initialized successfully');
    } catch (e) {
      _setError('Failed to initialize alerts controller: $e');
      _logger.error('Alerts controller initialization failed: $e');
    }
  }

  /// Start monitoring alerts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    notifyListeners();
    
    // Start periodic checking (every 30 seconds)
    _startPeriodicCheck();
    _logger.info('Alert monitoring started');
  }

  /// Stop monitoring alerts
  void stopMonitoring() {
    _isMonitoring = false;
    notifyListeners();
    _logger.info('Alert monitoring stopped');
  }

  /// Add a new price alert
  void addPriceAlert({
    required String symbol,
    required AlertCondition condition,
    required double value,
    String? description,
  }) {
    final alert = PriceAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol.toUpperCase(),
      condition: condition,
      value: value,
      createdAt: DateTime.now(),
      description: description,
    );

    _alerts.add(alert);
    notifyListeners();
    
    _logger.info('Price alert added: ${alert.symbol} ${_getConditionText(condition)} ${value}');
  }

  /// Remove an alert
  void removeAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
    _logger.info('Alert removed: $alertId');
  }

  /// Toggle alert enabled state
  void toggleAlert(String alertId, bool enabled) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isEnabled: enabled);
      notifyListeners();
      _logger.info('Alert ${enabled ? 'enabled' : 'disabled'}: $alertId');
    }
  }

  /// Add a trading signal
  void addSignal(Signal signal) {
    _signals.insert(0, signal);
    
    // Keep only recent signals (last 100)
    if (_signals.length > 100) {
      _signals.removeRange(100, _signals.length);
    }
    
    notifyListeners();
    
    // Send notification for the signal
    _notificationService.showTradingSignal(signal);
    
    _logger.info('Signal added: ${signal.type.name} for ${signal.symbol}');
  }

  /// Clear all signals
  void clearSignals() {
    _signals.clear();
    notifyListeners();
    _logger.info('All signals cleared');
  }

  /// Get signals for a specific symbol
  List<Signal> getSignalsForSymbol(String symbol) {
    return _signals.where((signal) => signal.symbol == symbol).toList();
  }

  /// Generate RSI signals
  Future<void> generateRSISignals(String symbol, List<double> closePrices) async {
    try {
      final rsi = _calculateRSI(closePrices);
      if (rsi == null) return;

      Signal? signal;

      if (rsi < 30) {
        // Oversold condition - potential buy signal
        signal = Signal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: symbol,
          type: SignalType.buy,
          price: closePrices.last,
          confidence: ConfidenceLevel.high,
          reason: 'RSI Oversold (${rsi.toStringAsFixed(2)})',
          timestamp: DateTime.now(),
          metadata: {'rsi': rsi, 'indicator': 'RSI'},
          source: 'technical_analysis',
        );
      } else if (rsi > 70) {
        // Overbought condition - potential sell signal
        signal = Signal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: symbol,
          type: SignalType.sell,
          price: closePrices.last,
          confidence: ConfidenceLevel.high,
          reason: 'RSI Overbought (${rsi.toStringAsFixed(2)})',
          timestamp: DateTime.now(),
          metadata: {'rsi': rsi, 'indicator': 'RSI'},
          source: 'technical_analysis',
        );
      }

      if (signal != null) {
        addSignal(signal);
      }
    } catch (e) {
      _logger.error('Failed to generate RSI signals: $e');
    }
  }

  /// Generate EMA crossover signals
  Future<void> generateEMASignals(String symbol, List<double> closePrices) async {
    try {
      final ema12 = _calculateEMA(closePrices, 12);
      final ema26 = _calculateEMA(closePrices, 26);
      
      if (ema12 == null || ema26 == null) return;

      // Get previous EMAs to detect crossover
      if (closePrices.length < 27) return;

      final prevClosePrices = closePrices.sublist(0, closePrices.length - 1);
      final prevEma12 = _calculateEMA(prevClosePrices, 12);
      final prevEma26 = _calculateEMA(prevClosePrices, 26);
      
      if (prevEma12 == null || prevEma26 == null) return;

      Signal? signal;

      // Bullish crossover: EMA12 crosses above EMA26
      if (prevEma12 <= prevEma26 && ema12 > ema26) {
        signal = Signal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: symbol,
          type: SignalType.buy,
          price: closePrices.last,
          confidence: ConfidenceLevel.medium,
          reason: 'EMA Bullish Crossover (12>26)',
          timestamp: DateTime.now(),
          metadata: {'ema12': ema12, 'ema26': ema26, 'indicator': 'EMA'},
          source: 'technical_analysis',
        );
      }
      // Bearish crossover: EMA12 crosses below EMA26
      else if (prevEma12 >= prevEma26 && ema12 < ema26) {
        signal = Signal(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: symbol,
          type: SignalType.sell,
          price: closePrices.last,
          confidence: ConfidenceLevel.medium,
          reason: 'EMA Bearish Crossover (12<26)',
          timestamp: DateTime.now(),
          metadata: {'ema12': ema12, 'ema26': ema26, 'indicator': 'EMA'},
          source: 'technical_analysis',
        );
      }

      if (signal != null) {
        addSignal(signal);
      }
    } catch (e) {
      _logger.error('Failed to generate EMA signals: $e');
    }
  }

  /// Start periodic alert checking
  void _startPeriodicCheck() {
    if (!_isMonitoring) return;

    Future.delayed(const Duration(seconds: 30), () async {
      if (_isMonitoring) {
        await _checkAlerts();
        _startPeriodicCheck(); // Schedule next check
      }
    });
  }

  /// Check all alerts for triggers
  Future<void> _checkAlerts() async {
    if (_alerts.isEmpty) return;

    // Group alerts by symbol to minimize API calls
    final symbolGroups = <String, List<PriceAlert>>{};
    for (final alert in _alerts.where((a) => a.isEnabled && a.triggeredAt == null)) {
      symbolGroups.putIfAbsent(alert.symbol, () => []).add(alert);
    }

    for (final entry in symbolGroups.entries) {
      await _checkAlertsForSymbol(entry.key, entry.value);
    }
  }

  /// Check alerts for a specific symbol
  Future<void> _checkAlertsForSymbol(String symbol, List<PriceAlert> symbolAlerts) async {
    try {
      final currentPrice = await _binanceService.getCurrentPrice(symbol);
      
      for (final alert in symbolAlerts) {
        bool triggered = false;

        switch (alert.condition) {
          case AlertCondition.priceAbove:
            triggered = currentPrice >= alert.value;
            break;
          case AlertCondition.priceBelow:
            triggered = currentPrice <= alert.value;
            break;
          case AlertCondition.volumeAbove:
            // Would need volume data - simplified for now
            break;
          case AlertCondition.rsiAbove:
          case AlertCondition.rsiBelow:
            // Would need candlestick data to calculate RSI
            break;
          case AlertCondition.priceChange:
            // Would need previous price data
            break;
        }

        if (triggered) {
          await _triggerAlert(alert, currentPrice);
        }
      }
    } catch (e) {
      _logger.error('Failed to check alerts for $symbol: $e');
    }
  }

  /// Trigger an alert
  Future<void> _triggerAlert(PriceAlert alert, double currentPrice) async {
    // Mark alert as triggered
    final index = _alerts.indexWhere((a) => a.id == alert.id);
    if (index != -1) {
      _alerts[index] = alert.copyWith(triggeredAt: DateTime.now());
      notifyListeners();
    }

    // Send notification
    await _notificationService.showPriceAlert(
      symbol: alert.symbol,
      currentPrice: currentPrice,
      targetPrice: alert.value,
      condition: alert.condition == AlertCondition.priceAbove ? 'above' : 'below',
    );

    _logger.info('Alert triggered: ${alert.symbol} ${_getConditionText(alert.condition)} ${alert.value}');
  }

  /// Calculate RSI
  double? _calculateRSI(List<double> prices, {int period = 14}) {
    if (prices.length < period + 1) return null;

    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        gains.add(change);
        losses.add(0);
      } else {
        gains.add(0);
        losses.add(-change);
      }
    }

    if (gains.length < period) return null;

    final avgGain = gains.take(period).reduce((a, b) => a + b) / period;
    final avgLoss = losses.take(period).reduce((a, b) => a + b) / period;

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calculate EMA
  double? _calculateEMA(List<double> prices, int period) {
    if (prices.length < period) return null;

    final multiplier = 2.0 / (period + 1);
    double ema = prices.take(period).reduce((a, b) => a + b) / period;

    for (int i = period; i < prices.length; i++) {
      ema = (prices[i] * multiplier) + (ema * (1 - multiplier));
    }

    return ema;
  }

  /// Get condition text for display
  String _getConditionText(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.priceAbove:
        return 'above';
      case AlertCondition.priceBelow:
        return 'below';
      case AlertCondition.rsiAbove:
        return 'RSI above';
      case AlertCondition.rsiBelow:
        return 'RSI below';
      case AlertCondition.volumeAbove:
        return 'volume above';
      case AlertCondition.priceChange:
        return 'price change';
    }
  }

  /// Get alert statistics
  Map<String, dynamic> getAlertStats() {
    final totalAlerts = _alerts.length;
    final activeAlerts = _alerts.where((a) => a.isEnabled && a.triggeredAt == null).length;
    final triggeredAlerts = _alerts.where((a) => a.triggeredAt != null).length;

    return {
      'total': totalAlerts,
      'active': activeAlerts,
      'triggered': triggeredAlerts,
      'disabled': totalAlerts - activeAlerts - triggeredAlerts,
    };
  }

  /// Clear all alerts
  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
    _logger.info('All alerts cleared');
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
