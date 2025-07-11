import 'package:flutter/foundation.dart';
import '../../models/trade.dart';
import '../../models/candle.dart';
import '../../models/signal.dart';
import '../../services/binance_service.dart';
import '../../services/notification_service.dart';
import '../../utils/logger.dart';

class TradingController extends ChangeNotifier {
  final BinanceService _binanceService = BinanceService();
  final NotificationService _notificationService = NotificationService();
  final AppLogger _logger = AppLogger();

  // State variables
  bool _isLoading = false;
  String? _error;
  String _selectedSymbol = 'BTCUSDT';
  String _selectedInterval = '1h';
  double _currentPrice = 0.0;
  List<Candle> _candleData = [];
  List<Trade> _tradeHistory = [];
  List<Signal> _activeSignals = [];
  Map<String, dynamic> _marketStats = {};
  bool _isConnected = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSymbol => _selectedSymbol;
  String get selectedInterval => _selectedInterval;
  double get currentPrice => _currentPrice;
  List<Candle> get candleData => _candleData;
  List<Trade> get tradeHistory => _tradeHistory;
  List<Signal> get activeSignals => _activeSignals;
  Map<String, dynamic> get marketStats => _marketStats;
  bool get isConnected => _isConnected;

  /// Initialize trading controller
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _binanceService.initialize();
      await _notificationService.initialize();
      await _loadInitialData();
      _isConnected = true;
      _logger.info('Trading controller initialized successfully');
    } catch (e) {
      _setError('Failed to initialize trading controller: $e');
      _logger.error('Trading controller initialization failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load initial market data
  Future<void> _loadInitialData() async {
    await Future.wait([
      _updateCurrentPrice(),
      _updateCandleData(),
      _updateMarketStats(),
    ]);
  }

  /// Set selected trading symbol
  Future<void> setSelectedSymbol(String symbol) async {
    if (_selectedSymbol == symbol) return;

    try {
      _selectedSymbol = symbol;
      notifyListeners();
      
      await _loadInitialData();
      _logger.info('Selected symbol changed to: $symbol');
    } catch (e) {
      _setError('Failed to change symbol: $e');
    }
  }

  /// Set selected time interval
  Future<void> setSelectedInterval(String interval) async {
    if (_selectedInterval == interval) return;

    try {
      _selectedInterval = interval;
      notifyListeners();
      
      await _updateCandleData();
      _logger.info('Selected interval changed to: $interval');
    } catch (e) {
      _setError('Failed to change interval: $e');
    }
  }

  /// Update current price
  Future<void> _updateCurrentPrice() async {
    try {
      final price = await _binanceService.getCurrentPrice(_selectedSymbol);
      _currentPrice = price;
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to update current price: $e');
    }
  }

  /// Update candlestick data
  Future<void> _updateCandleData() async {
    try {
      final candles = await _binanceService.getCandlestickData(
        _selectedSymbol,
        _selectedInterval,
        limit: 100,
      );
      _candleData = candles;
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to update candle data: $e');
    }
  }

  /// Update market statistics
  Future<void> _updateMarketStats() async {
    try {
      final stats = await _binanceService.get24hStats(_selectedSymbol);
      _marketStats = stats;
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to update market stats: $e');
    }
  }

  /// Place a market order
  Future<bool> placeMarketOrder({
    required String side, // BUY or SELL
    required double quantity,
  }) async {
    try {
      _setLoading(true);
      
      // For now, use test order
      final result = await _binanceService.placeTestOrder(
        symbol: _selectedSymbol,
        side: side,
        type: 'MARKET',
        quantity: quantity,
      );

      if (result['success'] == true) {
        // Create trade record
        final trade = Trade(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: _selectedSymbol,
          side: side.toLowerCase() == 'buy' ? OrderSide.buy : OrderSide.sell,
          type: OrderType.market,
          quantity: quantity,
          price: _currentPrice,
          status: TradeStatus.filled,
          createdAt: DateTime.now(),
          filledAt: DateTime.now(),
          filledPrice: _currentPrice,
          filledQuantity: quantity,
        );

        _tradeHistory.insert(0, trade);
        notifyListeners();

        await _notificationService.showTradingSignal(
          Signal(
            id: trade.id,
            symbol: _selectedSymbol,
            type: side.toLowerCase() == 'buy' ? SignalType.buy : SignalType.sell,
            price: _currentPrice,
            confidence: ConfidenceLevel.high,
            reason: 'Manual $side order executed',
            timestamp: DateTime.now(),
            metadata: {'quantity': quantity, 'type': 'market'},
            source: 'manual',
          ),
        );

        _logger.info('Market order placed: $side $quantity $_selectedSymbol');
        return true;
      }

      return false;
    } catch (e) {
      _setError('Failed to place market order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Place a limit order
  Future<bool> placeLimitOrder({
    required String side, // BUY or SELL
    required double quantity,
    required double price,
  }) async {
    try {
      _setLoading(true);
      
      // For now, use test order
      final result = await _binanceService.placeTestOrder(
        symbol: _selectedSymbol,
        side: side,
        type: 'LIMIT',
        quantity: quantity,
        price: price,
      );

      if (result['success'] == true) {
        // Create trade record
        final trade = Trade(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          symbol: _selectedSymbol,
          side: side.toLowerCase() == 'buy' ? OrderSide.buy : OrderSide.sell,
          type: OrderType.limit,
          quantity: quantity,
          price: price,
          status: TradeStatus.pending,
          createdAt: DateTime.now(),
        );

        _tradeHistory.insert(0, trade);
        notifyListeners();

        _logger.info('Limit order placed: $side $quantity $_selectedSymbol at \$${price.toStringAsFixed(2)}');
        return true;
      }

      return false;
    } catch (e) {
      _setError('Failed to place limit order: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a trading signal
  void addSignal(Signal signal) {
    _activeSignals.insert(0, signal);
    
    // Keep only recent signals (last 50)
    if (_activeSignals.length > 50) {
      _activeSignals = _activeSignals.take(50).toList();
    }
    
    notifyListeners();
    _logger.info('Signal added: ${signal.type.name} for ${signal.symbol}');
  }

  /// Remove a signal
  void removeSignal(String signalId) {
    _activeSignals.removeWhere((signal) => signal.id == signalId);
    notifyListeners();
  }

  /// Clear all signals
  void clearSignals() {
    _activeSignals.clear();
    notifyListeners();
    _logger.info('All signals cleared');
  }

  /// Get trading statistics
  Map<String, dynamic> getTradingStats() {
    if (_tradeHistory.isEmpty) {
      return {
        'totalTrades': 0,
        'winRate': 0.0,
        'totalProfit': 0.0,
        'avgTradeSize': 0.0,
      };
    }

    final totalTrades = _tradeHistory.length;
    final buyTrades = _tradeHistory.where((t) => t.side == OrderSide.buy).length;
    final sellTrades = _tradeHistory.where((t) => t.side == OrderSide.sell).length;
    
    final totalVolume = _tradeHistory.fold<double>(
      0.0,
      (sum, trade) => sum + (trade.quantity * (trade.price ?? 0.0)),
    );

    return {
      'totalTrades': totalTrades,
      'buyTrades': buyTrades,
      'sellTrades': sellTrades,
      'totalVolume': totalVolume,
      'avgTradeSize': totalVolume / totalTrades,
      'lastTradeTime': _tradeHistory.isNotEmpty 
          ? _tradeHistory.first.createdAt 
          : null,
    };
  }

  /// Calculate RSI for current data
  double? calculateRSI({int period = 14}) {
    if (_candleData.length < period + 1) return null;

    final gains = <double>[];
    final losses = <double>[];

    for (int i = 1; i < _candleData.length; i++) {
      final change = _candleData[i].close - _candleData[i - 1].close;
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

  /// Calculate simple moving average
  double? calculateSMA({int period = 20}) {
    if (_candleData.length < period) return null;

    final sum = _candleData
        .take(period)
        .fold<double>(0, (sum, candle) => sum + candle.close);
    
    return sum / period;
  }

  /// Refresh all data
  Future<void> refreshData() async {
    try {
      _setLoading(true);
      await _loadInitialData();
      _logger.info('Data refreshed successfully');
    } catch (e) {
      _setError('Failed to refresh data: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get market change percentage
  double getChangePercentage() {
    final changePercent = _marketStats['priceChangePercent'];
    if (changePercent != null) {
      return double.tryParse(changePercent.toString()) ?? 0.0;
    }
    return 0.0;
  }

  /// Get 24h volume
  double get24hVolume() {
    final volume = _marketStats['volume'];
    if (volume != null) {
      return double.tryParse(volume.toString()) ?? 0.0;
    }
    return 0.0;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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
    super.dispose();
  }
}
