import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/logger.dart';

class BinanceWebSocketService extends ChangeNotifier {
  static const String _baseUrl = 'wss://stream.binance.com:9443/ws/';
  static const String _testnetUrl = 'wss://testnet.binance.vision/ws/';
  
  final AppLogger _logger = AppLogger();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  
  // Connection state
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  
  // Price data
  final Map<String, double> _prices = {};
  final Map<String, double> _priceChanges = {};
  final Map<String, String> _lastUpdateTimes = {};
  
  // Subscription tracking
  final Set<String> _subscribedSymbols = {};
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  Map<String, double> get prices => Map.unmodifiable(_prices);
  Map<String, double> get priceChanges => Map.unmodifiable(_priceChanges);
  int get reconnectAttempts => _reconnectAttempts;
  
  // Get price for specific symbol
  double? getPrice(String symbol) => _prices[symbol.toUpperCase()];
  
  // Get price change for specific symbol
  double? getPriceChange(String symbol) => _priceChanges[symbol.toUpperCase()];
  
  // Get formatted price with proper decimals
  String getFormattedPrice(String symbol) {
    final price = getPrice(symbol);
    if (price == null) return '--';
    
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(8);
    }
  }
  
  // Connect to Binance WebSocket
  Future<bool> connect({bool useTestnet = false}) async {
    if (_isConnected || _isConnecting) {
      _logger.warning('Already connected or connecting to Binance WebSocket');
      return _isConnected;
    }
    
    try {
      _isConnecting = true;
      notifyListeners();
      
      final url = useTestnet ? _testnetUrl : _baseUrl;
      _logger.info('Connecting to Binance WebSocket: $url');
      
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen to the stream
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      // Wait for connection to establish
      await Future.delayed(const Duration(seconds: 2));
      
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
      _logger.info('Successfully connected to Binance WebSocket');
      notifyListeners();
      
      return true;
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      _logger.error('Failed to connect to Binance WebSocket: $e');
      notifyListeners();
      
      // Schedule reconnection
      _scheduleReconnection();
      return false;
    }
  }
  
  // Subscribe to ticker updates for a symbol
  Future<void> subscribeToTicker(String symbol) async {
    if (!_isConnected) {
      _logger.warning('Not connected to WebSocket. Cannot subscribe to $symbol');
      return;
    }
    
    final symbolLower = symbol.toLowerCase();
    if (_subscribedSymbols.contains(symbolLower)) {
      _logger.info('Already subscribed to $symbol');
      return;
    }
    
    try {
      final subscribeMessage = {
        'method': 'SUBSCRIBE',
        'params': ['${symbolLower}@ticker'],
        'id': _generateId(),
      };
      
      _channel!.sink.add(jsonEncode(subscribeMessage));
      _subscribedSymbols.add(symbolLower);
      
      _logger.info('Subscribed to ticker updates for $symbol');
    } catch (e) {
      _logger.error('Failed to subscribe to $symbol: $e');
    }
  }
  
  // Subscribe to multiple symbols at once
  Future<void> subscribeToMultipleTickers(List<String> symbols) async {
    if (!_isConnected) {
      _logger.warning('Not connected to WebSocket. Cannot subscribe to symbols');
      return;
    }
    
    final streams = symbols
        .map((symbol) => '${symbol.toLowerCase()}@ticker')
        .where((stream) => !_subscribedSymbols.contains(stream.split('@')[0]))
        .toList();
    
    if (streams.isEmpty) {
      _logger.info('All symbols already subscribed');
      return;
    }
    
    try {
      final subscribeMessage = {
        'method': 'SUBSCRIBE',
        'params': streams,
        'id': _generateId(),
      };
      
      _channel!.sink.add(jsonEncode(subscribeMessage));
      
      // Add to subscribed set
      for (final stream in streams) {
        _subscribedSymbols.add(stream.split('@')[0]);
      }
      
      _logger.info('Subscribed to ${streams.length} ticker streams');
    } catch (e) {
      _logger.error('Failed to subscribe to multiple symbols: $e');
    }
  }
  
  // Unsubscribe from a symbol
  Future<void> unsubscribeFromTicker(String symbol) async {
    if (!_isConnected) return;
    
    final symbolLower = symbol.toLowerCase();
    if (!_subscribedSymbols.contains(symbolLower)) return;
    
    try {
      final unsubscribeMessage = {
        'method': 'UNSUBSCRIBE',
        'params': ['${symbolLower}@ticker'],
        'id': _generateId(),
      };
      
      _channel!.sink.add(jsonEncode(unsubscribeMessage));
      _subscribedSymbols.remove(symbolLower);
      
      // Remove price data
      _prices.remove(symbol.toUpperCase());
      _priceChanges.remove(symbol.toUpperCase());
      _lastUpdateTimes.remove(symbol.toUpperCase());
      
      _logger.info('Unsubscribed from $symbol');
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to unsubscribe from $symbol: $e');
    }
  }
  
  // Handle incoming WebSocket messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      
      // Handle ticker updates
      if (data['e'] == '24hrTicker') {
        final symbol = data['s'] as String;
        final price = double.parse(data['c']);
        final change = double.parse(data['P']);
        final updateTime = DateTime.now().toIso8601String();
        
        _prices[symbol] = price;
        _priceChanges[symbol] = change;
        _lastUpdateTimes[symbol] = updateTime;
        
        notifyListeners();
        
        _logger.debug('Updated $symbol: \$${price.toStringAsFixed(2)} (${change.toStringAsFixed(2)}%)');
      }
      
      // Handle subscription confirmations
      else if (data['result'] == null && data['id'] != null) {
        _logger.info('Subscription confirmed: ${data['id']}');
      }
      
    } catch (e) {
      _logger.error('Failed to parse WebSocket message: $e');
    }
  }
  
  // Handle WebSocket errors
  void _handleError(error) {
    _logger.error('WebSocket error: $error');
    _isConnected = false;
    notifyListeners();
    _scheduleReconnection();
  }
  
  // Handle WebSocket disconnection
  void _handleDisconnection() {
    _logger.warning('WebSocket disconnected');
    _isConnected = false;
    _stopPingTimer();
    notifyListeners();
    _scheduleReconnection();
  }
  
  // Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'method': 'PING'}));
        } catch (e) {
          _logger.error('Failed to send ping: $e');
        }
      }
    });
  }
  
  // Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }
  
  // Schedule reconnection attempt
  void _scheduleReconnection() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.error('Max reconnection attempts reached. Giving up.');
      return;
    }
    
    _reconnectTimer?.cancel();
    
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * pow(2, _reconnectAttempts).toInt(),
    );
    
    _logger.info('Scheduling reconnection in ${delay.inSeconds} seconds (attempt ${_reconnectAttempts + 1}/$_maxReconnectAttempts)');
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      _reconnect();
    });
  }
  
  // Reconnect to WebSocket
  Future<void> _reconnect() async {
    _logger.info('Attempting to reconnect...');
    await disconnect();
    
    if (await connect()) {
      // Re-subscribe to all previously subscribed symbols
      if (_subscribedSymbols.isNotEmpty) {
        final symbols = _subscribedSymbols.toList();
        _subscribedSymbols.clear();
        await subscribeToMultipleTickers(symbols);
      }
    }
  }
  
  // Disconnect from WebSocket
  Future<void> disconnect() async {
    _logger.info('Disconnecting from Binance WebSocket');
    
    _stopPingTimer();
    _reconnectTimer?.cancel();
    
    try {
      await _subscription?.cancel();
      await _channel?.sink.close(status.goingAway);
    } catch (e) {
      _logger.error('Error during disconnect: $e');
    }
    
    _subscription = null;
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    
    notifyListeners();
  }
  
  // Generate unique ID for requests
  int _generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
  
  // Test connection with BTC price
  Future<bool> testConnection() async {
    try {
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) return false;
      }
      
      // Subscribe to BTCUSDT for testing
      await subscribeToTicker('BTCUSDT');
      
      // Wait for price data
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (_prices.containsKey('BTCUSDT')) {
          _logger.info('Connection test successful. BTC price: \$${getFormattedPrice('BTCUSDT')}');
          return true;
        }
      }
      
      _logger.warning('Connection test failed - no price data received');
      return false;
    } catch (e) {
      _logger.error('Connection test failed: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
