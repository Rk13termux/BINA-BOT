import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import '../models/candle.dart';
import '../models/account_info.dart';
import '../models/order_models.dart';
import '../utils/logger.dart';

/// Servicio profesional para integración con Binance API
class BinanceService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // API Configuration
  static const String _baseUrl = 'https://api.binance.com';
  static const String _testNetUrl = 'https://testnet.binance.vision';

  // Authentication
  String? _apiKey;
  String? _secretKey;
  bool _isAuthenticated = false;
  bool _isTestNet = false;
  String? _lastError;

  // Account data
  AccountInfo? _accountInfo;
  bool _isConnected = false;

  // Rate limiting and connection management
  int _requestWeight = 0;
  DateTime? _lastRequestTime;

  // Circuit breaker pattern
  bool _circuitBreakerOpen = false;
  int _consecutiveFailures = 0;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isConnected => _isConnected;
  bool get isTestNet => _isTestNet;
  String? get lastError => _lastError;
  String get baseUrl => _isTestNet ? _testNetUrl : _baseUrl;
  AccountInfo? get accountInfo => _accountInfo;
  int get requestWeight => _requestWeight;
  bool get isRateLimited => _requestWeight > 1000;
  bool get isCircuitBreakerOpen => _circuitBreakerOpen;
  int get consecutiveFailures => _consecutiveFailures;

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
        await _storage.write(
            key: 'binance_is_testnet', value: _isTestNet.toString());

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
        _consecutiveFailures = 0; // Reset failure counter on success
        _logger.info('Binance connection test successful');
        return true;
      } else {
        _isConnected = false;
        final errorData = json.decode(response.body);
        _lastError = errorData['msg'] ?? 'Connection test failed';
        _consecutiveFailures++;
        _logger.error('Binance connection test failed: $_lastError');
        return false;
      }
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      _consecutiveFailures++;
      _logger.error('Binance connection test error: $e');
      return false;
    }
  }

  /// Obtener precio actual de un símbolo
  Future<double> getPrice(String symbol) async {
    try {
      // Verificar rate limiting básico
      if (_requestWeight > 1000) {
        _logger.warning('Rate limit approaching: $_requestWeight/1200');
        await Future.delayed(Duration(seconds: 1));
      }

      final url = '$baseUrl/api/v3/ticker/price?symbol=${symbol.toUpperCase()}';

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      _updateRequestWeight(response);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = double.parse(data['price']);

        _consecutiveFailures = 0; // Reset on success
        _logger.debug('Price for $symbol: \$${price.toStringAsFixed(2)}');
        return price;
      } else {
        _consecutiveFailures++;
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get price: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _consecutiveFailures++;
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
            openTime: DateTime.fromMillisecondsSinceEpoch(candleData[0]),
            open: double.parse(candleData[1]),
            high: double.parse(candleData[2]),
            low: double.parse(candleData[3]),
            close: double.parse(candleData[4]),
            volume: double.parse(candleData[5]),
            closeTime: DateTime.fromMillisecondsSinceEpoch(candleData[6]),
          );
        }).toList();

        _logger.debug('Retrieved ${candles.length} candles for $symbol');
        return candles;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get candles: ${errorData['msg'] ?? 'Unknown error'}');
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
        throw Exception(
            'Failed to get account info: ${errorData['msg'] ?? 'Unknown error'}');
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
      final response =
          await _makeSignedRequest('POST', '/api/v3/order', params);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(data);

        _logger.info('Order placed successfully: ${orderResponse.orderId}');

        // Actualizar información de cuenta después de la orden
        await getAccountInfo();

        return orderResponse;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to place order: ${errorData['msg'] ?? 'Unknown error'}');
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

      final response =
          await _makeSignedRequest('DELETE', '/api/v3/order', params);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final orderResponse = OrderResponse.fromJson(data);

        _logger.info('Order cancelled successfully: $orderId');

        // Actualizar información de cuenta
        await getAccountInfo();

        return orderResponse;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to cancel order: ${errorData['msg'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.error('Error cancelling order: $e');
      rethrow;
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

      final response =
          await _makeSignedRequest('GET', '/api/v3/openOrders', params);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((order) => OrderResponse.fromJson(order)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to get open orders: ${errorData['msg'] ?? 'Unknown error'}');
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
    Map<String, dynamic>? params,
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
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
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
  }

  /// Obtener balance total en USDT
  Future<double> getTotalBalanceUSDT() async {
    try {
      if (_accountInfo == null) {
        await getAccountInfo();
      }

      if (_accountInfo == null) {
        return 0.0;
      }

      double total = 0.0;
      for (final balance in _accountInfo!.balances) {
        if (balance.free > 0 || balance.locked > 0) {
          if (balance.asset == 'USDT') {
            total += balance.free + balance.locked;
          } else {
            try {
              final price = await getPrice('${balance.asset}USDT');
              total += (balance.free + balance.locked) * price;
            } catch (e) {
              _logger.warning('Could not get USDT price for ${balance.asset}: $e');
              // Si no se puede obtener el precio, se ignora este activo para el total en USDT
            }
          }
        }
      }
      return total;
    } catch (e) {
      _logger.error('Error getting total balance: $e');
      return 0.0;
    }
  }

  /// Verificar si tiene permisos de trading
  bool get canTrade => _accountInfo?.canTrade ?? false;

  /// Realizar orden de prueba (para testing sin fondos reales)
  Future<Map<String, dynamic>> placeTestOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
  }) async {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated with Binance');
      }

      _logger.info('Placing test order: $side $quantity $symbol');

      // Simular orden de prueba exitosa
      await Future.delayed(Duration(milliseconds: 500));

      return {
        'success': true,
        'orderId': DateTime.now().millisecondsSinceEpoch,
        'symbol': symbol.toUpperCase(),
        'side': side.toUpperCase(),
        'type': type.toUpperCase(),
        'quantity': quantity,
        'price': price ?? 0.0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'FILLED',
        'testOrder': true,
      };
    } catch (e) {
      _logger.error('Error placing test order: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Limpiar recursos al destruir el servicio
  @override
  void dispose() {
    super.dispose();
  }

  /// Obtener estadísticas del servicio para monitoreo
  Map<String, dynamic> getServiceStats() {
    return {
      'isAuthenticated': _isAuthenticated,
      'isConnected': _isConnected,
      'isTestNet': _isTestNet,
      'requestWeight': _requestWeight,
      'consecutiveFailures': _consecutiveFailures,
      'circuitBreakerOpen': _circuitBreakerOpen,
      'lastRequestTime': _lastRequestTime?.toIso8601String(),
      'accountType': _accountInfo?.accountType,
      'canTrade': canTrade,
      'totalBalanceUSDT':
          _accountInfo?.getTotalBalanceUSDT().toStringAsFixed(2),
    };
  }

  /// Resetear circuit breaker manualmente (para testing o admin)
  void resetCircuitBreaker() {
    _circuitBreakerOpen = false;
    _consecutiveFailures = 0;
    _logger.info('Circuit breaker manually reset');
    notifyListeners();
  }

  /// Obtener precio actual (método de compatibilidad)
  Future<double> getCurrentPrice(String symbol) async {
    return await getPrice(symbol);
  }

  /// Obtener estadísticas de 24hr (método de compatibilidad) 
  Future<Map<String, dynamic>> get24hStats(String symbol) async {
    return await get24hrTicker(symbol);
  }

  /// Obtener datos de velas (método de compatibilidad)
  Future<List<Candle>> getCandlestickData({
    required String symbol,
    required String interval,
    int limit = 100,
  }) async {
    return await getCandles(
      symbol: symbol,
      interval: interval,
      limit: limit,
    );
  }

  /// Obtener balances formateados para UI
  Future<List<Map<String, dynamic>>> getFormattedBalances() async {
    try {
      if (_accountInfo == null) {
        await getAccountInfo();
      }

      return _accountInfo?.balances
          .where((balance) => balance.free > 0 || balance.locked > 0)
          .map((balance) => {
                'asset': balance.asset,
                'free': balance.free,
                'locked': balance.locked,
                'total': balance.free + balance.locked,
              })
          .toList() ?? [];
    } catch (e) {
      _logger.error('Error getting formatted balances: $e');
      return [];
    }
  }

  /// Getter para balances (compatibilidad)
  List<Balance> get balances => _accountInfo?.balances ?? [];
}
