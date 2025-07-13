import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/candle.dart';
import '../models/account_info.dart';
import '../models/order_models.dart';
import '../utils/logger.dart';

/// Servicio profesional para integración con Binance API
class BinanceService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // API Configuration
  String get _baseUrl => dotenv.env['BINANCE_BASE_URL'] ?? 'https://api.binance.com';
  String get _testNetUrl => dotenv.env['BINANCE_TESTNET_URL'] ?? 'https://testnet.binance.vision';
  
  // Authentication
  String? _apiKey;
  String? _secretKey;
  bool _isAuthenticated = false;
  bool _isTestNet = false;
  String? _lastError;

  // Account data
  AccountInfo? _accountInfo;
  bool _isConnected = false;

  // Rate limiting
  int _requestWeight = 0;
  DateTime _lastRequestTime = DateTime.now();

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isConnected => _isConnected;
  bool get isTestNet => _isTestNet;
  String? get lastError => _lastError;
  String get baseUrl => _isTestNet ? _testNetUrl : _baseUrl;
  AccountInfo? get accountInfo => _accountInfo;
  int get requestWeight => _requestWeight;

  /// Inicializar servicio Binance
  Future<void> initialize() async {
    try {
      _logger.info('Initializing Binance service...');
      
      // Cargar credenciales almacenadas
      await _loadStoredCredentials();
      
      // Probar conexión si está autenticado
      if (_isAuthenticated) {
        await testConnection();
      }
      
      _logger.info('Binance service initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize Binance service: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Configurar credenciales de API
  Future<bool> setCredentials({
    required String apiKey,
    required String secretKey,
    bool isTestNet = false,
  }) async {
    try {
      _apiKey = apiKey.trim();
      _secretKey = secretKey.trim();
      _isTestNet = isTestNet;

      // Validar credenciales
      final isValid = await testConnection();
      
      if (isValid) {
        // Guardar credenciales de forma segura
        await _storage.write(key: 'binance_api_key', value: _apiKey);
        await _storage.write(key: 'binance_secret_key', value: _secretKey);
        await _storage.write(key: 'binance_is_testnet', value: _isTestNet.toString());
        
        _isAuthenticated = true;
        _lastError = null;
        
        // Cargar información de cuenta
        await getAccountInfo();
        
        _logger.info('Binance credentials configured successfully');
        notifyListeners();
        return true;
      } else {
        _isAuthenticated = false;
        _logger.warning('Invalid Binance credentials provided');
        return false;
      }
    } catch (e) {
      _logger.error('Failed to set Binance credentials: $e');
      _lastError = e.toString();
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Cargar credenciales almacenadas
  Future<void> _loadStoredCredentials() async {
    try {
      _apiKey = await _storage.read(key: 'binance_api_key');
      _secretKey = await _storage.read(key: 'binance_secret_key');
      final isTestNetStr = await _storage.read(key: 'binance_is_testnet');
      
      _isTestNet = isTestNetStr == 'true';
      _isAuthenticated = _apiKey != null && _secretKey != null;
      
      if (_isAuthenticated) {
        _logger.info('Loaded stored Binance credentials');
      }
    } catch (e) {
      _logger.error('Failed to load stored credentials: $e');
    }
  }

  /// Probar conexión con Binance API
  Future<bool> testConnection() async {
    try {
      if (_apiKey == null || _secretKey == null) {
        throw Exception('API credentials not configured');
      }

      final response = await _makeSignedRequest('GET', '/api/v3/account');
      
      if (response.statusCode == 200) {
        _isConnected = true;
        _lastError = null;
        _logger.info('Binance connection test successful');
        return true;
      } else {
        _isConnected = false;
        final errorData = json.decode(response.body);
        _lastError = errorData['msg'] ?? 'Connection test failed';
        _logger.error('Binance connection test failed: $_lastError');
        return false;
      }
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      _logger.error('Binance connection test error: $e');
      return false;
    }
  }

  /// Obtener precio actual de un símbolo
  Future<double> getPrice(String symbol) async {
    try {
      final url = '$baseUrl/api/v3/ticker/price?symbol=${symbol.toUpperCase()}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      _updateRequestWeight(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = double.parse(data['price']);
        
        _logger.debug('Price for $symbol: \$${price.toStringAsFixed(2)}');
        return price;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get price: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error getting price for $symbol: $e');
      rethrow;
    }
  }

  /// Obtener datos de velas (candlesticks)
  Future<List<Candle>> getCandles({
    required String symbol,
    required String interval,
    int limit = 100,
  }) async {
    try {
      final url = '$baseUrl/api/v3/klines'
          '?symbol=${symbol.toUpperCase()}'
          '&interval=$interval'
          '&limit=$limit';

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      _updateRequestWeight(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        final candles = data.map((candleData) {
          return Candle(
            date: DateTime.fromMillisecondsSinceEpoch(candleData[0]),
            high: double.parse(candleData[2]),
            low: double.parse(candleData[3]),
            open: double.parse(candleData[1]),
            close: double.parse(candleData[4]),
            volume: double.parse(candleData[5]),
          );
        }).toList();

        _logger.debug('Retrieved ${candles.length} candles for $symbol');
        return candles;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get candles: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error getting candles for $symbol: $e');
      rethrow;
    }
  }

  /// Obtener información de la cuenta
  Future<AccountInfo> getAccountInfo() async {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated with Binance');
      }

      final response = await _makeSignedRequest('GET', '/api/v3/account');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accountInfo = AccountInfo.fromJson(data);
        
        _logger.info('Account info retrieved successfully');
        notifyListeners();
        return _accountInfo!;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get account info: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error getting account info: $e');
      rethrow;
    }
  }

  /// Colocar una orden
  Future<OrderResponse> placeOrder(OrderRequest orderRequest) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated with Binance');
      }

      final params = orderRequest.toJson();
      final response = await _makeSignedRequest('POST', '/api/v3/order', params);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(data);
        
        _logger.info('Order placed successfully: ${orderResponse.orderId}');
        
        // Actualizar información de cuenta después de la orden
        await getAccountInfo();
        
        return orderResponse;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to place order: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error placing order: $e');
      rethrow;
    }
  }

  /// Cancelar una orden
  Future<OrderResponse> cancelOrder({
    required String symbol,
    required int orderId,
  }) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated with Binance');
      }

      final params = {
        'symbol': symbol.toUpperCase(),
        'orderId': orderId.toString(),
      };

      final response = await _makeSignedRequest('DELETE', '/api/v3/order', params);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(data);
        
        _logger.info('Order cancelled successfully: $orderId');
        
        // Actualizar información de cuenta
        await getAccountInfo();
        
        return orderResponse;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to cancel order: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error cancelling order: $e');
      rethrow;
    }
  }
          _logger.warning('Failed to load account info on init: $e');
        }
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
  Future<void> setCredentials(String apiKey, String secretKey,
      [bool testNet = false]) async {
    try {
      await _storage.write(key: StorageKeys.binanceApiKey, value: apiKey);
      await _storage.write(key: StorageKeys.binanceSecretKey, value: secretKey);
      await _storage.write(key: StorageKeys.binanceTestNet, value: testNet.toString());

      _apiKey = apiKey;
      _secretKey = secretKey;
      _isTestNet = testNet;
      _isAuthenticated = true;

      await _testConnection();
      
      // Load account info after setting credentials
      try {
        await getAccountInfo();
        _logger.info('Account info loaded after setting credentials');
      } catch (e) {
        _logger.warning('Failed to load account info: $e');
      }
      
      notifyListeners();
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

  // Account information (requires authentication)
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
        _accountInfo = json.decode(response.body);
        _balances = List<Map<String, dynamic>>.from(_accountInfo!['balances'] ?? []);

        // Filter only balances with values > 0
        _balances = _balances.where((balance) {
          final free = double.tryParse(balance['free']?.toString() ?? '0') ?? 0;
          final locked = double.tryParse(balance['locked']?.toString() ?? '0') ?? 0;
          return (free + locked) > 0;
        }).toList();

        notifyListeners();
        _logger.info('Account info loaded successfully');
        return _accountInfo!;
      } else {
        final error = json.decode(response.body);
        throw Exception('Binance API Error: ${error['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Failed to get account info: $e');
      throw Exception('Failed to get account info: $e');
    }
  }

  /// Obtener órdenes abiertas
  Future<List<OrderResponse>> getOpenOrders({String? symbol}) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated with Binance');
      }

      final params = <String, String>{};
      if (symbol != null) {
        params['symbol'] = symbol.toUpperCase();
      }

      final response = await _makeSignedRequest('GET', '/api/v3/openOrders', params);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((order) => OrderResponse.fromJson(order)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get open orders: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error getting open orders: $e');
      rethrow;
    }
  }

  /// Obtener pares de trading disponibles
  Future<List<Map<String, dynamic>>> getTradingPairs() async {
    try {
      final url = '$baseUrl/api/v3/exchangeInfo';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      _updateRequestWeight(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final symbols = data['symbols'] as List<dynamic>;
        
        return symbols
            .where((symbol) => symbol['status'] == 'TRADING')
            .map((symbol) => {
                  'symbol': symbol['symbol'],
                  'baseAsset': symbol['baseAsset'],
                  'quoteAsset': symbol['quoteAsset'],
                  'status': symbol['status'],
                })
            .toList();
      } else {
        throw Exception('Failed to get trading pairs');
      }
    } catch (e) {
      _logger.error('Error getting trading pairs: $e');
      rethrow;
    }
  }

  /// Obtener estadísticas de 24hr
  Future<Map<String, dynamic>> get24hrTicker(String symbol) async {
    try {
      final url = '$baseUrl/api/v3/ticker/24hr?symbol=${symbol.toUpperCase()}';
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      _updateRequestWeight(response);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get 24hr ticker');
      }
    } catch (e) {
      _logger.error('Error getting 24hr ticker: $e');
      rethrow;
    }
  }

  /// Limpiar credenciales
  Future<void> clearCredentials() async {
    try {
      await _storage.deleteAll();
      _apiKey = null;
      _secretKey = null;
      _isAuthenticated = false;
      _isConnected = false;
      _accountInfo = null;
      _lastError = null;
      
      _logger.info('Binance credentials cleared');
      notifyListeners();
    } catch (e) {
      _logger.error('Error clearing credentials: $e');
    }
  }

  // MÉTODOS HELPER PRIVADOS

  /// Realizar petición firmada a la API
  Future<http.Response> _makeSignedRequest(
    String method,
    String endpoint, [
    Map<String, String>? params,
  ]) async {
    if (_apiKey == null || _secretKey == null) {
      throw Exception('API credentials not configured');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final parameters = {
      ...?params,
      'timestamp': timestamp,
      'recvWindow': '60000',
    };

    final queryString = _buildQueryString(parameters);
    final signature = _generateSignature(queryString);
    final url = '$baseUrl$endpoint?$queryString&signature=$signature';

    final headers = {
      'X-MBX-APIKEY': _apiKey!,
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'POST':
        return await http.post(Uri.parse(url), headers: headers);
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Generar firma HMAC SHA256
  String _generateSignature(String data) {
    if (_secretKey == null) {
      throw Exception('Secret key not configured');
    }
    
    final key = utf8.encode(_secretKey!);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    
    return digest.toString();
  }

  /// Construir query string
  String _buildQueryString(Map<String, dynamic> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  /// Obtener headers básicos
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'User-Agent': 'InvictusTraderPro/1.0.0',
    };
  }

  /// Actualizar peso de requests
  void _updateRequestWeight(http.Response response) {
    final weightHeader = response.headers['x-mbx-used-weight-1m'];
    if (weightHeader != null) {
      _requestWeight = int.tryParse(weightHeader) ?? 0;
    }
    _lastRequestTime = DateTime.now();
  }

  /// Obtener balance total en USDT
  Future<double> getTotalBalanceUSDT() async {
    try {
      if (_accountInfo == null) {
        await getAccountInfo();
      }
      
      return _accountInfo?.getTotalBalanceUSDT() ?? 0.0;
    } catch (e) {
      _logger.error('Error getting total balance: $e');
      return 0.0;
    }
  }

  /// Verificar si tiene permisos de trading
  bool get canTrade => _accountInfo?.canTrade ?? false;

  /// Verificar límites de rate
  bool get isRateLimited => _requestWeight > 1000;
}
