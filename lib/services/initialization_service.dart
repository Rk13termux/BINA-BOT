import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/api_manager.dart';
import '../core/websocket_manager.dart';
import '../utils/logger.dart';

/// Servicio encargado de la inicialización completa de la aplicación
class InitializationService extends ChangeNotifier {
  static final InitializationService _instance = InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  final AppLogger _logger = AppLogger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isInitialized = false;
  bool _isInitializing = false;
  String _initStatus = 'Iniciando...';
  String? _errorMessage;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  String get initStatus => _initStatus;
  String? get errorMessage => _errorMessage;
  
  // APIs y servicios
  ApiManager? _apiManager;
  WebSocketManager? _webSocketManager;
  
  ApiManager get apiManager => _apiManager!;
  WebSocketManager get webSocketManager => _webSocketManager!;

  /// Inicializa toda la aplicación
  Future<bool> initialize() async {
    if (_isInitialized || _isInitializing) return _isInitialized;
    
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.info('Starting app initialization...');

      // 1. Inicializar Hive (almacenamiento local)
      _updateStatus('Inicializando almacenamiento...');
      await _initializeHive();

      // 2. Inicializar API Manager
      _updateStatus('Configurando conexiones API...');
      await _initializeApiManager();

      // 3. Inicializar WebSocket Manager
      _updateStatus('Configurando conexiones en tiempo real...');
      await _initializeWebSocketManager();

      // 4. Configurar credenciales por defecto para testing
      _updateStatus('Configurando credenciales de prueba...');
      await _setupTestCredentials();

      // 6. Verificar conectividad
      _updateStatus('Verificando conectividad...');
      await _testConnectivity();

      _updateStatus('¡Aplicación lista!');
      _isInitialized = true;
      _logger.info('App initialization completed successfully');

    } catch (e) {
      _errorMessage = 'Error de inicialización: $e';
      _logger.error('Initialization failed: $e');
      _isInitialized = false;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }

    return _isInitialized;
  }

  /// Inicializa Hive para almacenamiento local
  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      
      // Abrir cajas necesarias
      await Hive.openBox('settings');
      await Hive.openBox('cache');
      await Hive.openBox('user_data');
      
      _logger.info('Hive initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize Hive: $e');
      rethrow;
    }
  }

  /// Inicializa el API Manager
  Future<void> _initializeApiManager() async {
    try {
      _apiManager = ApiManager();
      await _apiManager!.loadCredentials();
      _logger.info('API Manager initialized');
    } catch (e) {
      _logger.error('Failed to initialize API Manager: $e');
      rethrow;
    }
  }

  /// Inicializa el WebSocket Manager
  Future<void> _initializeWebSocketManager() async {
    try {
      _webSocketManager = WebSocketManager();
      _logger.info('WebSocket Manager initialized');
    } catch (e) {
      _logger.error('Failed to initialize WebSocket Manager: $e');
      rethrow;
    }
  }

  /// Configura credenciales de prueba para testing
  Future<void> _setupTestCredentials() async {
    try {
      // Verificar si ya existen credenciales
      final existingApiKey = await _secureStorage.read(key: 'binance_api_key');
      
      if (existingApiKey == null || existingApiKey.isEmpty) {
        // Configurar credenciales de prueba (Binance Testnet)
        // NOTA: Estas son credenciales de ejemplo para testnet
        // En producción, el usuario debe ingresar sus propias credenciales
        const testApiKey = 'YOUR_TESTNET_API_KEY_HERE';
        const testSecretKey = 'YOUR_TESTNET_SECRET_KEY_HERE';
        
        await _apiManager!.setCredentials(
          testApiKey,
          testSecretKey,
          testnet: true,
        );
        
        _logger.info('Test credentials configured');
      } else {
        _logger.info('Existing credentials found');
      }
    } catch (e) {
      _logger.error('Failed to setup test credentials: $e');
      // No re-lanzar el error, esto no es crítico
    }
  }

  /// Verifica la conectividad con APIs
  Future<void> _testConnectivity() async {
    try {
      // Probar conexión con Binance API (endpoint público)
      final priceData = await _apiManager!.getSymbolPrice('BTCUSDT');
      if (priceData != null) {
        _logger.info('API connectivity test passed: BTC price = ${priceData['price']}');
      } else {
        _logger.warning('API connectivity test failed - using offline mode');
      }
    } catch (e) {
      _logger.warning('Connectivity test failed: $e - continuing in offline mode');
      // No re-lanzar el error, la app puede funcionar sin conectividad inicial
    }
  }

  /// Actualiza el estado de inicialización
  void _updateStatus(String status) {
    _initStatus = status;
    _logger.info(status);
    notifyListeners();
  }

  /// Reinicia la inicialización
  Future<bool> retry() async {
    _isInitialized = false;
    _isInitializing = false;
    _errorMessage = null;
    return await initialize();
  }

  /// Libera recursos
  @override
  void dispose() {
    _webSocketManager?.dispose();
    super.dispose();
  }
}
