import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

/// Gestiona todas las conexiones con APIs externas (principalmente Binance)
class ApiManager {
  static const String _binanceBaseUrl = 'https://api.binance.com';
  static const String _binanceSpotUrl = '/api/v3';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AppLogger _logger = AppLogger();

  String? _apiKey;
  String? _secretKey;
  bool _isTestnet = false;


  /// Configura las credenciales de la API
  Future<void> setCredentials(String apiKey, String secretKey,
      {bool testnet = false}) async {
    await _secureStorage.write(key: 'binance_api_key', value: apiKey);
    await _secureStorage.write(key: 'binance_secret_key', value: secretKey);
    await _secureStorage.write(key: 'is_testnet', value: testnet.toString());

    _apiKey = apiKey;
    _secretKey = secretKey;
    _isTestnet = testnet;

    _logger.info('API credentials configured');
  }

  /// Carga las credenciales guardadas
  Future<void> loadCredentials() async {
    _apiKey = await _secureStorage.read(key: 'binance_api_key');
    _secretKey = await _secureStorage.read(key: 'binance_secret_key');
    final testnetStr = await _secureStorage.read(key: 'is_testnet');
    _isTestnet = testnetStr == 'true';
  }

  /// Verifica si las credenciales están configuradas
  bool get isConfigured => _apiKey != null && _secretKey != null;

  /// Obtiene el precio actual de un símbolo
  Future<Map<String, dynamic>?> getSymbolPrice(String symbol) async {
    try {
      final url =
          '${_getBaseUrl()}$_binanceSpotUrl/ticker/price?symbol=${symbol.toUpperCase()}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger
            .error('Error getting price for $symbol: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting price for $symbol: $e');
      return null;
    }
  }

  /// Obtiene los precios de todos los símbolos en una sola petición
  Future<List<Map<String, dynamic>>?> getAllSymbolPrices() async {
    try {
      final url = '${_getBaseUrl()}$_binanceSpotUrl/ticker/price';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          _logger.error('Unexpected response format for all prices');
          return null;
        }
      } else {
        _logger.error('Error getting all prices: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting all prices: $e');
      return null;
    }
  }

  /// Obtiene información de la cuenta
  Future<Map<String, dynamic>?> getAccountInfo() async {
    if (!isConfigured) {
      _logger.error('API credentials not configured');
      return null;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final queryString = 'timestamp=$timestamp';
      final signature = _generateSignature(queryString);

      final url =
          '${_getBaseUrl()}$_binanceSpotUrl/account?$queryString&signature=$signature';
      final response = await http.get(
        Uri.parse(url),
        headers: {'X-MBX-APIKEY': _apiKey!},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.error('Error getting account info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting account info: $e');
      return null;
    }
  }

  /// Coloca una orden de compra/venta
  Future<Map<String, dynamic>?> placeOrder({
    required String symbol,
    required String side, // BUY or SELL
    required String type, // MARKET, LIMIT, etc.
    required double quantity,
    double? price,
    String? timeInForce = 'GTC',
  }) async {
    if (!isConfigured) {
      _logger.error('API credentials not configured');
      return null;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final params = {
        'symbol': symbol.toUpperCase(),
        'side': side.toUpperCase(),
        'type': type.toUpperCase(),
        'quantity': quantity.toString(),
        'timestamp': timestamp.toString(),
      };

      if (price != null && type.toUpperCase() == 'LIMIT') {
        params['price'] = price.toString();
        params['timeInForce'] = timeInForce!;
      }

      final queryString =
          params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final signature = _generateSignature(queryString);

      final url = '${_getBaseUrl()}$_binanceSpotUrl/order';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'X-MBX-APIKEY': _apiKey!,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: '$queryString&signature=$signature',
      );

      if (response.statusCode == 200) {
        _logger.info('Order placed successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        _logger.error(
            'Error placing order: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception placing order: $e');
      return null;
    }
  }

  /// Testa la conexión con la API de Binance
  Future<bool> testConnection() async {
    try {
      _logger.info('Testing Binance API connection...');

      // Test endpoint simple sin autenticación
      final url = '${_getBaseUrl()}$_binanceSpotUrl/ping';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _logger.info('Binance API connection successful');

        // Test adicional con precio de BTC
        final btcPrice = await getSymbolPrice('BTCUSDT');
        if (btcPrice != null) {
          _logger.info('BTC price test successful: \$${btcPrice['price']}');
          return true;
        } else {
          _logger.warning('API ping successful but price test failed');
          return false;
        }
      } else {
        _logger.error('Binance API connection failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.error('Binance API connection test failed: $e');
      return false;
    }
  }

  /// Verifica el estado del servidor de Binance
  Future<Map<String, dynamic>?> getServerStatus() async {
    try {
      final url = '${_getBaseUrl()}$_binanceSpotUrl/system/status';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.info('Server status: ${data['status']} - ${data['msg']}');
        return data;
      } else {
        _logger.error('Error getting server status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting server status: $e');
      return null;
    }
  }

  /// Genera la firma HMAC SHA256 requerida por Binance
  String _generateSignature(String queryString) {
    final key = utf8.encode(_secretKey!);
    final bytes = utf8.encode(queryString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Obtiene la URL base según si es testnet o no
  String _getBaseUrl() {
    return _isTestnet ? 'https://testnet.binance.vision' : _binanceBaseUrl;
  }

  /// Obtiene todos los símbolos disponibles
  Future<List<Map<String, dynamic>>?> getAllSymbols() async {
    try {
      final url = '${_getBaseUrl()}$_binanceSpotUrl/exchangeInfo';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['symbols']);
      } else {
        _logger.error('Error getting symbols: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting symbols: $e');
      return null;
    }
  }

  /// Obtiene las estadísticas de 24h para un símbolo
  Future<Map<String, dynamic>?> get24hrStats(String symbol) async {
    try {
      final url =
          '${_getBaseUrl()}$_binanceSpotUrl/ticker/24hr?symbol=${symbol.toUpperCase()}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        _logger.error(
            'Error getting 24hr stats for $symbol: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.error('Exception getting 24hr stats for $symbol: $e');
      return null;
    }
  }
}
