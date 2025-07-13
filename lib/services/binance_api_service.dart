import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/binance_account.dart';
import '../utils/logger.dart';

class BinanceApiService {
  final AppLogger _logger = AppLogger();
  static const _storage = FlutterSecureStorage();
  
  // URLs de la API
  static const String _baseUrlMainnet = 'https://api.binance.com';
  static const String _baseUrlTestnet = 'https://testnet.binance.vision';
  
  // Estado de la conexión
  BinanceApiCredentials? _credentials;
  BinanceAccount? _account;
  bool _isConnected = false;
  Timer? _connectionTimer;
  
  // Streams para datos en tiempo real
  final StreamController<BinanceAccount> _accountController = 
      StreamController<BinanceAccount>.broadcast();
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  
  // Getters
  Stream<BinanceAccount> get accountStream => _accountController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  BinanceAccount? get currentAccount => _account;
  bool get isConnected => _isConnected;
  BinanceApiCredentials? get credentials => _credentials;
  
  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      _logger.info('Inicializando BinanceApiService...');
      
      // Cargar credenciales guardadas
      await _loadSavedCredentials();
      
      // Si hay credenciales, intentar conectar
      if (_credentials != null && _credentials!.isValid) {
        await connectToAccount();
      }
      
      // Iniciar monitoreo de conexión
      _startConnectionMonitoring();
      
    } catch (e) {
      _logger.error('Error inicializando BinanceApiService: $e');
    }
  }
  
  /// Cargar credenciales guardadas
  Future<void> _loadSavedCredentials() async {
    try {
      final credentialsJson = await _storage.read(key: 'binance_credentials');
      if (credentialsJson != null) {
        final credentialsData = json.decode(credentialsJson);
        _credentials = BinanceApiCredentials.fromJson(credentialsData);
        _logger.info('Credenciales Binance cargadas desde almacenamiento seguro');
      }
    } catch (e) {
      _logger.warning('Error cargando credenciales: $e');
    }
  }
  
  /// Guardar credenciales de forma segura
  Future<void> _saveCredentials(BinanceApiCredentials credentials) async {
    try {
      final credentialsJson = json.encode(credentials.toJson());
      await _storage.write(key: 'binance_credentials', value: credentialsJson);
      _logger.info('Credenciales Binance guardadas de forma segura');
    } catch (e) {
      _logger.error('Error guardando credenciales: $e');
      rethrow;
    }
  }
  
  /// Configurar credenciales de API
  Future<bool> setApiCredentials({
    required String apiKey,
    required String secretKey,
    bool isTestnet = false,
    String? nickname,
  }) async {
    try {
      _logger.info('Configurando credenciales de API Binance...');
      
      // Crear credenciales
      final credentials = BinanceApiCredentials(
        apiKey: apiKey.trim(),
        secretKey: secretKey.trim(),
        isTestnet: isTestnet,
        createdAt: DateTime.now(),
        nickname: nickname?.trim(),
      );
      
      // Verificar credenciales
      final isValid = await _testApiCredentials(credentials);
      
      if (isValid) {
        _credentials = credentials;
        await _saveCredentials(credentials);
        
        // Conectar a la cuenta
        await connectToAccount();
        
        _logger.info('✅ Credenciales configuradas y verificadas');
        return true;
      } else {
        _logger.warning('❌ Credenciales inválidas');
        return false;
      }
      
    } catch (e) {
      _logger.error('Error configurando credenciales: $e');
      return false;
    }
  }
  
  /// Probar credenciales de API
  Future<bool> _testApiCredentials(BinanceApiCredentials credentials) async {
    try {
      final baseUrl = credentials.isTestnet ? _baseUrlTestnet : _baseUrlMainnet;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Crear query string
      final queryString = 'timestamp=$timestamp';
      
      // Crear firma
      final signature = _createSignature(queryString, credentials.secretKey);
      
      // Crear URL completa
      final url = '$baseUrl/api/v3/account?$queryString&signature=$signature';
      
      // Crear cliente HTTP
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      
      // Agregar headers
      request.headers.add('X-MBX-APIKEY', credentials.apiKey);
      request.headers.add('Content-Type', 'application/json');
      
      // Ejecutar request
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode == 200) {
        _logger.info('✅ Credenciales API válidas');
        return true;
      } else {
        _logger.warning('❌ Credenciales API inválidas: ${response.statusCode}');
        _logger.warning('Response: $responseBody');
        return false;
      }
      
    } catch (e) {
      _logger.error('Error probando credenciales: $e');
      return false;
    }
  }
  
  /// Conectar a la cuenta
  Future<bool> connectToAccount() async {
    try {
      if (_credentials == null || !_credentials!.isValid) {
        _logger.warning('No hay credenciales válidas para conectar');
        return false;
      }
      
      _logger.info('Conectando a cuenta Binance...');
      
      // Obtener información de la cuenta
      final accountData = await _getAccountInfo();
      
      if (accountData != null) {
        // Obtener precios para calcular valores
        await _updateAccountBalancePrices(accountData);
        
        _account = accountData;
        _isConnected = true;
        
        // Actualizar último uso
        _credentials = BinanceApiCredentials(
          apiKey: _credentials!.apiKey,
          secretKey: _credentials!.secretKey,
          isTestnet: _credentials!.isTestnet,
          createdAt: _credentials!.createdAt,
          lastUsed: DateTime.now(),
          nickname: _credentials!.nickname,
        );
        
        await _saveCredentials(_credentials!);
        
        // Notificar streams
        _accountController.add(_account!);
        _connectionController.add(true);
        
        _logger.info('✅ Conectado a cuenta Binance');
        return true;
      } else {
        _isConnected = false;
        _connectionController.add(false);
        return false;
      }
      
    } catch (e) {
      _logger.error('Error conectando a cuenta: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }
  
  /// Obtener información de la cuenta
  Future<BinanceAccount?> _getAccountInfo() async {
    try {
      final baseUrl = _credentials!.isTestnet ? _baseUrlTestnet : _baseUrlMainnet;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Crear query string
      final queryString = 'timestamp=$timestamp';
      
      // Crear firma
      final signature = _createSignature(queryString, _credentials!.secretKey);
      
      // Crear URL completa
      final url = '$baseUrl/api/v3/account?$queryString&signature=$signature';
      
      // Crear cliente HTTP
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      
      // Agregar headers
      request.headers.add('X-MBX-APIKEY', _credentials!.apiKey);
      request.headers.add('Content-Type', 'application/json');
      
      // Ejecutar request
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode == 200) {
        final accountJson = json.decode(responseBody);
        return BinanceAccount.fromJson(accountJson);
      } else {
        _logger.error('Error obteniendo info de cuenta: ${response.statusCode}');
        _logger.error('Response: $responseBody');
        return null;
      }
      
    } catch (e) {
      _logger.error('Error en _getAccountInfo: $e');
      return null;
    }
  }
  
  /// Actualizar precios de los balances
  Future<void> _updateAccountBalancePrices(BinanceAccount account) async {
    try {
      // Obtener símbolos únicos que necesitan precio
      final symbols = account.balances
          .where((balance) => balance.total > 0 && balance.asset != 'USDT')
          .map((balance) => '${balance.asset}USDT')
          .toList();
      
      if (symbols.isEmpty) return;
      
      // Obtener precios
      final prices = await _getSymbolPrices(symbols);
      
      // Actualizar balances con precios
      for (final balance in account.balances) {
        if (balance.asset == 'USDT') continue;
        
        final symbolKey = '${balance.asset}USDT';
        if (prices.containsKey(symbolKey)) {
          // Aquí deberías actualizar el balance con el precio
          // Esto requiere modificar el modelo AccountBalance
        }
      }
      
    } catch (e) {
      _logger.warning('Error actualizando precios de balance: $e');
    }
  }
  
  /// Obtener precios de símbolos específicos
  Future<Map<String, double>> _getSymbolPrices(List<String> symbols) async {
    try {
      final baseUrl = _credentials!.isTestnet ? _baseUrlTestnet : _baseUrlMainnet;
      
      Map<String, double> prices = {};
      
      // Obtener precios usando ticker/price endpoint
      for (final symbol in symbols) {
        try {
          final url = '$baseUrl/api/v3/ticker/price?symbol=$symbol';
          
          final client = HttpClient();
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();
          
          client.close();
          
          if (response.statusCode == 200) {
            final priceData = json.decode(responseBody);
            prices[symbol] = double.tryParse(priceData['price']?.toString() ?? '0') ?? 0.0;
          }
        } catch (e) {
          _logger.warning('Error obteniendo precio de $symbol: $e');
        }
      }
      
      return prices;
    } catch (e) {
      _logger.error('Error en _getSymbolPrices: $e');
      return {};
    }
  }
  
  /// Crear firma HMAC SHA256
  String _createSignature(String queryString, String secretKey) {
    final key = utf8.encode(secretKey);
    final message = utf8.encode(queryString);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(message);
    return digest.toString();
  }
  
  /// Obtener datos de klines/candlesticks
  Future<List<Map<String, dynamic>>> getKlineData({
    required String symbol,
    required String interval,
    int limit = 500,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      if (_credentials == null) return [];
      
      final baseUrl = _credentials!.isTestnet ? _baseUrlTestnet : _baseUrlMainnet;
      
      // Construir parámetros
      final params = <String, String>{
        'symbol': symbol.toUpperCase(),
        'interval': interval,
        'limit': limit.toString(),
      };
      
      if (startTime != null) {
        params['startTime'] = startTime.millisecondsSinceEpoch.toString();
      }
      
      if (endTime != null) {
        params['endTime'] = endTime.millisecondsSinceEpoch.toString();
      }
      
      // Construir URL
      final queryString = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final url = '$baseUrl/api/v3/klines?$queryString';
      
      // Ejecutar request
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode == 200) {
        final klineData = json.decode(responseBody) as List<dynamic>;
        
        return klineData.map((kline) {
          final klineList = kline as List<dynamic>;
          return {
            'openTime': klineList[0],
            'open': double.tryParse(klineList[1].toString()) ?? 0.0,
            'high': double.tryParse(klineList[2].toString()) ?? 0.0,
            'low': double.tryParse(klineList[3].toString()) ?? 0.0,
            'close': double.tryParse(klineList[4].toString()) ?? 0.0,
            'volume': double.tryParse(klineList[5].toString()) ?? 0.0,
            'closeTime': klineList[6],
            'quoteAssetVolume': double.tryParse(klineList[7].toString()) ?? 0.0,
            'numberOfTrades': klineList[8],
            'takerBuyBaseAssetVolume': double.tryParse(klineList[9].toString()) ?? 0.0,
            'takerBuyQuoteAssetVolume': double.tryParse(klineList[10].toString()) ?? 0.0,
          };
        }).toList();
      } else {
        _logger.error('Error obteniendo klines: ${response.statusCode}');
        return [];
      }
      
    } catch (e) {
      _logger.error('Error en getKlineData: $e');
      return [];
    }
  }
  
  /// Obtener profundidad del libro de órdenes
  Future<Map<String, dynamic>?> getOrderBookDepth({
    required String symbol,
    int limit = 100,
  }) async {
    try {
      if (_credentials == null) return null;
      
      final baseUrl = _credentials!.isTestnet ? _baseUrlTestnet : _baseUrlMainnet;
      final url = '$baseUrl/api/v3/depth?symbol=${symbol.toUpperCase()}&limit=$limit';
      
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      client.close();
      
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        _logger.error('Error obteniendo order book: ${response.statusCode}');
        return null;
      }
      
    } catch (e) {
      _logger.error('Error en getOrderBookDepth: $e');
      return null;
    }
  }
  
  /// Iniciar monitoreo de conexión
  void _startConnectionMonitoring() {
    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_credentials != null && _credentials!.isValid) {
        final wasConnected = _isConnected;
        await connectToAccount();
        
        // Si el estado cambió, notificar
        if (wasConnected != _isConnected) {
          _connectionController.add(_isConnected);
        }
      }
    });
  }
  
  /// Refrescar datos de cuenta
  Future<void> refreshAccount() async {
    if (_credentials != null && _credentials!.isValid) {
      await connectToAccount();
    }
  }
  
  /// Desconectar
  Future<void> disconnect() async {
    _isConnected = false;
    _account = null;
    _connectionTimer?.cancel();
    _connectionController.add(false);
    _logger.info('Desconectado de Binance');
  }
  
  /// Eliminar credenciales
  Future<void> removeCredentials() async {
    try {
      await _storage.delete(key: 'binance_credentials');
      _credentials = null;
      await disconnect();
      _logger.info('Credenciales eliminadas');
    } catch (e) {
      _logger.error('Error eliminando credenciales: $e');
    }
  }
  
  /// Dispose
  void dispose() {
    _connectionTimer?.cancel();
    _accountController.close();
    _connectionController.close();
  }
}
