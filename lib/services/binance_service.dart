import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/candle.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class BinanceService extends ChangeNotifier {
  static const String _baseUrl = 'https://api.binance.com';
  static const String _testNetUrl = 'https://testnet.binance.vision';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final AppLogger _logger = AppLogger();

  String? _apiKey;
  String? _secretKey;
  bool _isAuthenticated = false;
  bool _isConnected = false;
  bool _isTestNet = false;
  String? _lastError;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isConnected => _isConnected;
  bool get isTestNet => _isTestNet;
  String? get lastError => _lastError;
  String get baseUrl => _isTestNet ? _testNetUrl : _baseUrl;

  // Initialize service
  Future<void> initialize() async {
    try {
      _logger.info('Initializing Binance service...');
      
      // Load stored credentials
      await _loadStoredCredentials();
      
      // Test connection if authenticated
      if (_isAuthenticated) {
        await _testConnection();
      }
      
      _logger.info('Binance service initialized');
    } catch (e) {
      _logger.error('Failed to initialize Binance service: $e');
    }
  }

  // Load stored credentials
  Future<void> _loadStoredCredentials() async {
    try {
      _apiKey = await _storage.read(key: StorageKeys.binanceApiKey);
      _secretKey = await _storage.read(key: StorageKeys.binanceSecretKey);
      final testNetStr = await _storage.read(key: StorageKeys.binanceTestNet);
      
      _isTestNet = testNetStr == 'true';
      _isAuthenticated = _apiKey != null && _secretKey != null;
      
      if (_isAuthenticated) {
        _logger.info('Binance credentials loaded from storage');
      }
    } catch (e) {
      _logger.error('Failed to load stored credentials: $e');
    }
  }

  // Test connection to Binance API
  Future<void> _testConnection() async {
    try {
      _logger.info('Testing Binance API connection...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/ping'),
      ).timeout(
        const Duration(seconds: 5),
      );
      
      _isConnected = response.statusCode == 200;
      _lastError = _isConnected ? null : 'API connection failed';
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      _lastError = 'Connection timeout or network error';
      _logger.error('Binance connection test failed: $e');
      notifyListeners();
    }
  }

  // Set API credentials
  Future<void> setCredentials(String apiKey, String secretKey, [bool testNet = false]) async {
    try {
      await _storage.write(key: StorageKeys.binanceApiKey, value: apiKey);
      await _storage.write(key: StorageKeys.binanceSecretKey, value: secretKey);
      await _storage.write(key: StorageKeys.binanceTestNet, value: testNet.toString());
      
      _apiKey = apiKey;
      _secretKey = secretKey;
      _isTestNet = testNet;
      _isAuthenticated = true;
      
      await _testConnection();
      _logger.info('Binance credentials saved and tested');
    } catch (e) {
      _logger.error('Failed to save Binance credentials: $e');
      throw Exception('Failed to save credentials');
    }
  }

  // Get current price for a symbol
  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/ticker/price?symbol=${symbol.toUpperCase()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.parse(data['price']);
      } else {
        throw Exception('Failed to get price: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get current price for $symbol: $e');
      throw Exception('Failed to get current price');
    }
  }

  // Get ticker data for multiple symbols
  Future<List<Map<String, dynamic>>> getTickerData(List<String> symbols) async {
    try {
      final results = <Map<String, dynamic>>[];
      
      for (final symbol in symbols) {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/v3/ticker/24hr?symbol=${symbol.toUpperCase()}USDT'),
          );
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            results.add({
              'symbol': symbol,
              'price': double.parse(data['lastPrice']),
              'change': double.parse(data['priceChange']),
              'changePercent': double.parse(data['priceChangePercent']),
              'volume': double.parse(data['volume']),
              'high': double.parse(data['highPrice']),
              'low': double.parse(data['lowPrice']),
            });
          } else {
            // Add placeholder data for failed requests
            results.add({
              'symbol': symbol,
              'price': 0.0,
              'change': 0.0,
              'changePercent': 0.0,
              'volume': 0.0,
              'high': 0.0,
              'low': 0.0,
            });
          }
        } catch (e) {
          // Add placeholder data for errors
          results.add({
            'symbol': symbol,
            'price': 0.0,
            'change': 0.0,
            'changePercent': 0.0,
            'volume': 0.0,
            'high': 0.0,
            'low': 0.0,
          });
        }
      }
      
      _lastError = null;
      if (!_isConnected) {
        _isConnected = true;
        notifyListeners();
      }
      
      return results;
    } catch (e) {
      _lastError = e.toString();
      _isConnected = false;
      notifyListeners();
      _logger.error('Failed to get ticker data: $e');
      throw Exception('Failed to get ticker data: $e');
    }
  }

  // Get 24h price statistics
  Future<Map<String, dynamic>> get24hStats(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/ticker/24hr?symbol=${symbol.toUpperCase()}'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get 24h stats: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get 24h stats for $symbol: $e');
      throw Exception('Failed to get 24h stats');
    }
  }

  // Get candlestick data
  Future<List<Candle>> getCandlestickData(
    String symbol,
    String interval,
    int limit,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/klines?symbol=${symbol.toUpperCase()}&interval=$interval&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((candleData) {
          return Candle(
            openTime: DateTime.fromMillisecondsSinceEpoch(candleData[0]),
            open: double.parse(candleData[1]),
            high: double.parse(candleData[2]),
            low: double.parse(candleData[3]),
            close: double.parse(candleData[4]),
            volume: double.parse(candleData[5]),
            closeTime: DateTime.fromMillisecondsSinceEpoch(candleData[6]),
          );
        }).toList();
      } else {
        throw Exception('Failed to get candlestick data: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get candlestick data for $symbol: $e');
      throw Exception('Failed to get candlestick data');
    }
  }

  // Get account information (requires authentication)
  Future<Map<String, dynamic>> getAccountInfo() async {
    if (!_isAuthenticated) {
      throw Exception('Not authenticated. Please set API credentials.');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString = 'timestamp=$timestamp';
      final signature = _generateSignature(queryString);

      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/account?$queryString&signature=$signature'),
        headers: {
          'X-MBX-APIKEY': _apiKey!,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get account info: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get account info: $e');
      throw Exception('Failed to get account info');
    }
  }

  // Get trading symbols
  Future<List<String>> getTradingSymbols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/exchangeInfo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final symbols = (data['symbols'] as List)
            .where((symbol) => symbol['status'] == 'TRADING')
            .map((symbol) => symbol['symbol'] as String)
            .toList();
        return symbols;
      } else {
        throw Exception('Failed to get trading symbols: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get trading symbols: $e');
      throw Exception('Failed to get trading symbols');
    }
  }

  // Place a test order (for testing purposes)
  Future<void> placeTestOrder(
    String symbol,
    String side,
    String type,
    double quantity,
  ) async {
    if (!_isAuthenticated) {
      throw Exception('Not authenticated. Please set API credentials.');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString =
          'symbol=$symbol&side=$side&type=$type&quantity=$quantity&timestamp=$timestamp';
      final signature = _generateSignature(queryString);

      final response = await http.post(
        Uri.parse('$baseUrl/api/v3/order/test?$queryString&signature=$signature'),
        headers: {
          'X-MBX-APIKEY': _apiKey!,
        },
      );

      if (response.statusCode == 200) {
        _logger.info('Test order placed successfully');
      } else {
        throw Exception('Failed to place test order: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to place test order: $e');
      throw Exception('Failed to place test order');
    }
  }

  // Get top trading pairs
  Future<List<Map<String, dynamic>>> getTopTradingPairs({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v3/ticker/24hr'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> tradingPairs = data
            .where((ticker) => ticker['symbol'].toString().endsWith('USDT'))
            .map((ticker) => {
                  'symbol': ticker['symbol'],
                  'price': double.parse(ticker['lastPrice']),
                  'change': double.parse(ticker['priceChangePercent']),
                  'volume': double.parse(ticker['quoteVolume']),
                })
            .toList();

        tradingPairs.sort((a, b) => b['volume'].compareTo(a['volume']));
        return tradingPairs.take(limit).toList();
      } else {
        throw Exception('Failed to get top trading pairs: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get top trading pairs: $e');
      throw Exception('Failed to get top trading pairs');
    }
  }

  // Generate signature for authenticated requests
  String _generateSignature(String queryString) {
    // This is a placeholder implementation
    // In a real implementation, you would use HMAC-SHA256
    return 'placeholder_signature';
  }

  // Clear credentials
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: StorageKeys.binanceApiKey);
      await _storage.delete(key: StorageKeys.binanceSecretKey);
      await _storage.delete(key: StorageKeys.binanceTestNet);
      _apiKey = null;
      _secretKey = null;
      _isAuthenticated = false;
      _isConnected = false;
      _lastError = null;
      notifyListeners();
      _logger.info('Binance credentials cleared');
    } catch (e) {
      _logger.error('Failed to clear Binance credentials: $e');
    }
  }
}
