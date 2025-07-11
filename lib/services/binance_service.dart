import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/candle.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class BinanceService {
  static const String _baseUrl = 'https://api.binance.com';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static final AppLogger _logger = AppLogger();

  String? _apiKey;
  String? _secretKey;
  bool _isAuthenticated = false;

  // Initialize with API credentials
  Future<void> initialize() async {
    try {
      _apiKey = await _storage.read(key: StorageKeys.binanceApiKey);
      _secretKey = await _storage.read(key: StorageKeys.binanceSecretKey);
      _isAuthenticated = _apiKey != null && _secretKey != null;

      if (_isAuthenticated) {
        _logger.info('Binance service initialized with credentials');
      } else {
        _logger.warning('Binance service initialized without credentials');
      }
    } catch (e) {
      _logger.error('Failed to initialize Binance service: $e');
    }
  }

  // Set API credentials
  Future<void> setCredentials(String apiKey, String secretKey) async {
    try {
      await _storage.write(key: StorageKeys.binanceApiKey, value: apiKey);
      await _storage.write(key: StorageKeys.binanceSecretKey, value: secretKey);
      _apiKey = apiKey;
      _secretKey = secretKey;
      _isAuthenticated = true;
      _logger.info('Binance credentials saved');
    } catch (e) {
      _logger.error('Failed to save Binance credentials: $e');
      throw Exception('Failed to save credentials');
    }
  }

  // Get current price for a symbol
  Future<double> getCurrentPrice(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/v3/ticker/price?symbol=${symbol.toUpperCase()}'),
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

  // Get 24h price statistics
  Future<Map<String, dynamic>> get24hStats(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/v3/ticker/24hr?symbol=${symbol.toUpperCase()}'),
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
  Future<List<Candle>> getCandlestickData(String symbol, String interval,
      {int limit = 100}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/api/v3/klines?symbol=${symbol.toUpperCase()}&interval=$interval&limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => Candle(
                  openTime: DateTime.fromMillisecondsSinceEpoch(item[0]),
                  open: double.parse(item[1]),
                  high: double.parse(item[2]),
                  low: double.parse(item[3]),
                  close: double.parse(item[4]),
                  volume: double.parse(item[5]),
                  closeTime: DateTime.fromMillisecondsSinceEpoch(item[6]),
                ))
            .toList();
      } else {
        throw Exception(
            'Failed to get candlestick data: ${response.statusCode}');
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
        Uri.parse('$_baseUrl/api/v3/account?$queryString&signature=$signature'),
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
        Uri.parse('$_baseUrl/api/v3/exchangeInfo'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final symbols = (data['symbols'] as List)
            .where((symbol) => symbol['status'] == 'TRADING')
            .map<String>((symbol) => symbol['symbol'] as String)
            .toList();
        return symbols;
      } else {
        throw Exception(
            'Failed to get trading symbols: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get trading symbols: $e');
      throw Exception('Failed to get trading symbols');
    }
  }

  // Place a test order (paper trading)
  Future<Map<String, dynamic>> placeTestOrder({
    required String symbol,
    required String side, // BUY or SELL
    required String type, // MARKET, LIMIT, etc.
    required double quantity,
    double? price,
  }) async {
    if (!_isAuthenticated) {
      throw Exception('Not authenticated. Please set API credentials.');
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      var queryString =
          'symbol=${symbol.toUpperCase()}&side=$side&type=$type&quantity=$quantity&timestamp=$timestamp';

      if (price != null && type == 'LIMIT') {
        queryString += '&price=$price&timeInForce=GTC';
      }

      final signature = _generateSignature(queryString);

      final response = await http.post(
        Uri.parse(
            '$_baseUrl/api/v3/order/test?$queryString&signature=$signature'),
        headers: {
          'X-MBX-APIKEY': _apiKey!,
        },
      );

      if (response.statusCode == 200) {
        _logger.info('Test order placed successfully');
        return {'success': true, 'message': 'Test order placed successfully'};
      } else {
        throw Exception('Failed to place test order: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to place test order: $e');
      throw Exception('Failed to place test order');
    }
  }

  // Get top trading pairs by volume
  Future<List<String>> getTopTradingPairs({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v3/ticker/24hr'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        data.sort((a, b) => double.parse(b['quoteVolume'])
            .compareTo(double.parse(a['quoteVolume'])));
        return data
            .take(limit)
            .map<String>((item) => item['symbol'] as String)
            .toList();
      } else {
        throw Exception(
            'Failed to get top trading pairs: ${response.statusCode}');
      }
    } catch (e) {
      _logger.error('Failed to get top trading pairs: $e');
      throw Exception('Failed to get top trading pairs');
    }
  }

  // Helper method to generate signature for authenticated requests
  String _generateSignature(String queryString) {
    // In a real implementation, you would use HMAC SHA256
    // For now, return a placeholder (this won't work for real trading)
    return 'placeholder_signature';
  }

  // Check if service is authenticated
  bool get isAuthenticated => _isAuthenticated;

  // Clear credentials
  Future<void> clearCredentials() async {
    try {
      await _storage.delete(key: StorageKeys.binanceApiKey);
      await _storage.delete(key: StorageKeys.binanceSecretKey);
      _apiKey = null;
      _secretKey = null;
      _isAuthenticated = false;
      _logger.info('Binance credentials cleared');
    } catch (e) {
      _logger.error('Failed to clear Binance credentials: $e');
    }
  }
}
