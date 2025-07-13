import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import '../models/crypto_price.dart';

class FreeCryptoService {
  final AppLogger _logger = AppLogger();
  
  // Canal para comunicación con Python
  static const MethodChannel _pythonChannel = MethodChannel('crypto_python_bridge');
  
  // Timer para polling de precios en tiempo real
  Timer? _priceTimer;
  Timer? _heartbeatTimer;
  
  // Streams para precios en tiempo real
  final StreamController<Map<String, CryptoPrice>> _priceController = 
      StreamController<Map<String, CryptoPrice>>.broadcast();
  
  // Estado del servicio
  bool _isRunning = false;
  bool _pythonAvailable = false;
  Process? _pythonProcess;
  
  // Cache mejorado
  Map<String, CryptoPrice> _priceCache = {};
  DateTime? _lastUpdate;
  
  // Getters
  Stream<Map<String, CryptoPrice>> get priceStream => _priceController.stream;
  bool get isRunning => _isRunning;
  bool get isPythonAvailable => _pythonAvailable;
  
  /// Inicializar el servicio y verificar disponibilidad de Python
  Future<bool> initialize() async {
    try {
      _logger.info('Inicializando FreeCryptoService...');
      
      // Verificar si Python está disponible
      await _checkPythonAvailability();
      
      if (_pythonAvailable) {
        _logger.info('✅ Python disponible - Usando módulo Python completo');
        return true;
      } else {
        _logger.warning('⚠️ Python no disponible - Usando fallback HTTP');
        return false;
      }
      
    } catch (e) {
      _logger.error('Error inicializando servicio: $e');
      return false;
    }
  }
  
  /// Verificar disponibilidad de Python
  Future<void> _checkPythonAvailability() async {
    try {
      if (Platform.isAndroid) {
        // En Android con Chaquopy
        try {
          final result = await _pythonChannel.invokeMethod('checkPython');
          _pythonAvailable = result == 'available';
        } catch (e) {
          _logger.warning('Python no disponible en Android: $e');
          _pythonAvailable = false;
        }
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // En desktop, verificar si Python está instalado
        try {
          final result = await Process.run('python', ['--version']);
          _pythonAvailable = result.exitCode == 0;
          if (_pythonAvailable) {
            _logger.info('Python encontrado: ${result.stdout}');
          }
        } catch (e) {
          // Intentar con python3
          try {
            final result = await Process.run('python3', ['--version']);
            _pythonAvailable = result.exitCode == 0;
            if (_pythonAvailable) {
              _logger.info('Python3 encontrado: ${result.stdout}');
            }
          } catch (e2) {
            _logger.warning('Python no encontrado en sistema');
            _pythonAvailable = false;
          }
        }
      }
    } catch (e) {
      _logger.error('Error verificando Python: $e');
      _pythonAvailable = false;
    }
  }
  
  /// Iniciar el proceso Python para precios en tiempo real
  Future<bool> startPythonService({
    List<String> symbols = const ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT']
  }) async {
    try {
      if (!_pythonAvailable) {
        _logger.warning('Python no disponible, usando fallback');
        return await _startFallbackService(symbols);
      }
      
      if (Platform.isAndroid) {
        // Android con Chaquopy
        final result = await _pythonChannel.invokeMethod('startCryptoService', {
          'symbols': symbols.join(',')
        });
        
        final response = json.decode(result);
        if (response['status'] == 'success') {
          _isRunning = true;
          _startPricePolling();
          _startHeartbeat();
          _logger.info('✅ Servicio Python iniciado (Android)');
          return true;
        }
      } else {
        // Desktop - ejecutar script Python
        return await _startDesktopPython(symbols);
      }
      
      return false;
    } catch (e) {
      _logger.error('Error iniciando servicio Python: $e');
      return await _startFallbackService(symbols);
    }
  }
  
  /// Iniciar Python en desktop
  Future<bool> _startDesktopPython(List<String> symbols) async {
    try {
      final scriptPath = await _copyPythonScript();
      if (scriptPath == null) return false;
      
      // Ejecutar script Python
      final pythonCmd = Platform.isWindows ? 'python' : 'python3';
      _pythonProcess = await Process.start(
        pythonCmd,
        [scriptPath, 'start', symbols.join(',')],
        workingDirectory: Directory.systemTemp.path,
      );
      
      if (_pythonProcess != null) {
        _isRunning = true;
        _startPricePolling();
        _startHeartbeat();
        
        // Escuchar salida del proceso
        _pythonProcess!.stdout.transform(utf8.decoder).listen((data) {
          _logger.info('Python output: $data');
        });
        
        _pythonProcess!.stderr.transform(utf8.decoder).listen((data) {
          _logger.warning('Python error: $data');
        });
        
        _logger.info('✅ Proceso Python iniciado (Desktop)');
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.error('Error iniciando Python desktop: $e');
      return false;
    }
  }
  
  /// Copiar script Python a directorio temporal
  Future<String?> _copyPythonScript() async {
    try {
      final scriptContent = await rootBundle.loadString('assets/crypto_service.py');
      final tempDir = Directory.systemTemp;
      final scriptFile = File('${tempDir.path}/crypto_service.py');
      
      await scriptFile.writeAsString(scriptContent);
      
      _logger.info('Script Python copiado a: ${scriptFile.path}');
      return scriptFile.path;
    } catch (e) {
      _logger.error('Error copiando script Python: $e');
      return null;
    }
  }
  
  /// Servicio fallback usando HTTP directo
  Future<bool> _startFallbackService(List<String> symbols) async {
    try {
      _logger.info('Iniciando servicio fallback HTTP');
      _isRunning = true;
      _startPricePolling();
      return true;
    } catch (e) {
      _logger.error('Error en servicio fallback: $e');
      return false;
    }
  }
  
  /// Iniciar polling de precios
  void _startPricePolling() {
    _priceTimer?.cancel();
    _priceTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      await _updatePrices();
    });
  }
  
  /// Iniciar heartbeat para mantener conexión
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      await _sendHeartbeat();
    });
  }
  
  /// Actualizar precios desde Python
  Future<void> _updatePrices() async {
    try {
      if (_pythonAvailable) {
        await _updatePricesFromPython();
      } else {
        await _updatePricesFromHttp();
      }
    } catch (e) {
      _logger.warning('Error actualizando precios: $e');
    }
  }
  
  /// Actualizar precios desde Python
  Future<void> _updatePricesFromPython() async {
    try {
      String pricesJson;
      
      if (Platform.isAndroid) {
        // Android con Chaquopy
        pricesJson = await _pythonChannel.invokeMethod('getCurrentPricesJson', {
          'symbols': 'BTC,ETH,BNB,ADA,XRP'
        });
      } else {
        // Desktop - leer desde archivo temporal o API call
        pricesJson = await _callPythonFunction('get_current_prices_json', 'BTC,ETH,BNB,ADA,XRP');
      }
      
      if (pricesJson.isNotEmpty) {
        final pricesData = json.decode(pricesJson) as Map<String, dynamic>;
        
        Map<String, CryptoPrice> prices = {};
        
        pricesData.forEach((symbol, data) {
          if (data is Map<String, dynamic>) {
            try {
              prices[symbol] = CryptoPrice.fromJson(data);
            } catch (e) {
              _logger.warning('Error parseando precio de $symbol: $e');
            }
          }
        });
        
        if (prices.isNotEmpty) {
          _priceCache.addAll(prices);
          _lastUpdate = DateTime.now();
          _priceController.add(Map.from(_priceCache));
          
          _logger.info('✅ Precios actualizados desde Python: ${prices.length} símbolos');
        }
      }
    } catch (e) {
      _logger.warning('Error obteniendo precios de Python: $e');
      // Fallback a HTTP
      await _updatePricesFromHttp();
    }
  }
  
  /// Llamar función Python (desktop)
  Future<String> _callPythonFunction(String function, String args) async {
    try {
      final pythonCmd = Platform.isWindows ? 'python' : 'python3';
      final scriptPath = '${Directory.systemTemp.path}/crypto_service.py';
      
      final result = await Process.run(pythonCmd, [
        '-c',
        '''
import sys
sys.path.append("${Directory.systemTemp.path}")
from crypto_service import $function
result = $function("$args")
print(result)
'''
      ]);
      
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      } else {
        throw Exception('Python error: ${result.stderr}');
      }
    } catch (e) {
      _logger.error('Error llamando función Python: $e');
      return '{}';
    }
  }
  
  /// Actualizar precios usando HTTP directo (fallback)
  Future<void> _updatePricesFromHttp() async {
    try {
      // Usar APIs HTTP directamente como fallback
      final prices = await _getBasicPrices();
      
      if (prices.isNotEmpty) {
        _priceCache.addAll(prices);
        _lastUpdate = DateTime.now();
        _priceController.add(Map.from(_priceCache));
        
        _logger.info('✅ Precios actualizados via HTTP: ${prices.length} símbolos');
      }
    } catch (e) {
      _logger.warning('Error obteniendo precios HTTP: $e');
    }
  }
  
  /// Obtener precios básicos via HTTP
  Future<Map<String, CryptoPrice>> _getBasicPrices() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(
        Uri.parse('https://api.binance.com/api/v3/ticker/24hr')
      );
      
      request.headers.add('User-Agent', 'InvictusTrader/1.0');
      
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as List<dynamic>;
        
        Map<String, CryptoPrice> prices = {};
        
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final symbol = item['symbol']?.toString() ?? '';
            
            // Solo procesar los símbolos principales
            if (['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT'].contains(symbol)) {
              try {
                final price = CryptoPrice(
                  symbol: symbol.replaceAll('USDT', ''),
                  price: double.tryParse(item['lastPrice']?.toString() ?? '0') ?? 0,
                  change24h: double.tryParse(item['priceChange']?.toString() ?? '0') ?? 0,
                  changePercent24h: double.tryParse(item['priceChangePercent']?.toString() ?? '0') ?? 0,
                  volume24h: double.tryParse(item['volume']?.toString() ?? '0') ?? 0,
                  high24h: double.tryParse(item['highPrice']?.toString() ?? '0'),
                  low24h: double.tryParse(item['lowPrice']?.toString() ?? '0'),
                  timestamp: DateTime.now(),
                  source: 'Binance HTTP',
                );
                
                prices[price.symbol] = price;
              } catch (e) {
                _logger.warning('Error parseando $symbol: $e');
              }
            }
          }
        }
        
        client.close();
        return prices;
      }
      
      client.close();
      return {};
    } catch (e) {
      _logger.error('Error en HTTP básico: $e');
      return {};
    }
  }
  
  /// Enviar heartbeat
  Future<void> _sendHeartbeat() async {
    try {
      if (_pythonAvailable && Platform.isAndroid) {
        await _pythonChannel.invokeMethod('heartbeat');
      }
      _logger.info('💓 Heartbeat enviado');
    } catch (e) {
      _logger.warning('Error en heartbeat: $e');
    }
  }
  
  /// Obtener precios actuales
  Future<Map<String, double>> getCurrentPrices({
    List<String> symbols = const ['BTC', 'ETH', 'BNB', 'ADA', 'XRP'],
    String currency = 'USD',
  }) async {
    try {
      // Verificar cache reciente
      if (_lastUpdate != null && 
          DateTime.now().difference(_lastUpdate!).inMinutes < 1 &&
          _priceCache.isNotEmpty) {
        
        Map<String, double> result = {};
        for (final symbol in symbols) {
          if (_priceCache.containsKey(symbol)) {
            result[symbol] = _priceCache[symbol]!.price;
          }
        }
        
        if (result.length == symbols.length) {
          _logger.info('Usando precios desde cache');
          return result;
        }
      }
      
      // Obtener precios frescos
      if (_pythonAvailable) {
        return await _getCurrentPricesFromPython(symbols, currency);
      } else {
        return await _getCurrentPricesFromHttp(symbols, currency);
      }
    } catch (e) {
      _logger.error('Error obteniendo precios actuales: $e');
      rethrow;
    }
  }
  
  /// Obtener precios desde Python
  Future<Map<String, double>> _getCurrentPricesFromPython(
    List<String> symbols, 
    String currency
  ) async {
    try {
      String pricesJson;
      
      if (Platform.isAndroid) {
        pricesJson = await _pythonChannel.invokeMethod('getCurrentPricesJson', {
          'symbols': symbols.join(',')
        });
      } else {
        pricesJson = await _callPythonFunction('get_current_prices_json', symbols.join(','));
      }
      
      final pricesData = json.decode(pricesJson) as Map<String, dynamic>;
      Map<String, double> result = {};
      
      pricesData.forEach((symbol, data) {
        if (data is Map<String, dynamic> && data.containsKey('price')) {
          result[symbol] = (data['price'] as num).toDouble();
        }
      });
      
      return result;
    } catch (e) {
      _logger.warning('Error obteniendo precios de Python: $e');
      return await _getCurrentPricesFromHttp(symbols, currency);
    }
  }
  
  /// Obtener precios desde HTTP
  Future<Map<String, double>> _getCurrentPricesFromHttp(
    List<String> symbols, 
    String currency
  ) async {
    final prices = await _getBasicPrices();
    Map<String, double> result = {};
    
    for (final symbol in symbols) {
      if (prices.containsKey(symbol)) {
        result[symbol] = prices[symbol]!.price;
      }
    }
    
    return result;
  }
  
  /// Obtener datos históricos
  Future<List<Map<String, dynamic>>> getHistoricalData(
    String symbol, 
    {int days = 7}
  ) async {
    try {
      if (_pythonAvailable) {
        String dataJson;
        
        if (Platform.isAndroid) {
          dataJson = await _pythonChannel.invokeMethod('getHistoricalDataJson', {
            'symbol': symbol,
            'days': days,
          });
        } else {
          dataJson = await _callPythonFunction('get_historical_data_json', '$symbol,$days');
        }
        
        if (dataJson.isNotEmpty && dataJson != '{}') {
          final data = json.decode(dataJson);
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          }
        }
      }
      
      // Fallback: datos limitados
      return [];
    } catch (e) {
      _logger.error('Error obteniendo datos históricos: $e');
      return [];
    }
  }
  
  /// Obtener top criptomonedas
  Future<List<Map<String, dynamic>>> getTopCryptos({int limit = 50}) async {
    try {
      if (_pythonAvailable) {
        String dataJson;
        
        if (Platform.isAndroid) {
          dataJson = await _pythonChannel.invokeMethod('getTopCryptosJson', {
            'limit': limit,
          });
        } else {
          dataJson = await _callPythonFunction('get_top_cryptos_json', limit.toString());
        }
        
        if (dataJson.isNotEmpty && dataJson != '{}') {
          final data = json.decode(dataJson);
          if (data is List) {
            return data.cast<Map<String, dynamic>>();
          }
        }
      }
      
      return [];
    } catch (e) {
      _logger.error('Error obteniendo top cryptos: $e');
      return [];
    }
  }
  
  /// Análisis técnico de un símbolo
  Future<Map<String, dynamic>?> analyzeSymbol(String symbol, {int days = 30}) async {
    try {
      if (_pythonAvailable) {
        String analysisJson;
        
        if (Platform.isAndroid) {
          analysisJson = await _pythonChannel.invokeMethod('analyzeSymbolJson', {
            'symbol': symbol,
            'days': days,
          });
        } else {
          analysisJson = await _callPythonFunction('analyze_symbol_json', '$symbol,$days');
        }
        
        if (analysisJson.isNotEmpty && analysisJson != '{}') {
          final data = json.decode(analysisJson);
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      }
      
      return null;
    } catch (e) {
      _logger.error('Error analizando símbolo: $e');
      return null;
    }
  }
  
  /// Obtener información detallada de una criptomoneda
  Future<Map<String, dynamic>?> getCoinDetails(String symbol) async {
    try {
      // Esta función usará los datos que ya tenemos o llamará a Python
      if (_priceCache.containsKey(symbol)) {
        final price = _priceCache[symbol]!;
        return {
          'symbol': price.symbol,
          'current_price': price.price,
          'price_change_24h': price.change24h,
          'price_change_percentage_24h': price.changePercent24h,
          'total_volume': price.volume24h,
          'high_24h': price.high24h,
          'low_24h': price.low24h,
          'market_cap': price.marketCap,
          'market_cap_rank': price.marketCapRank,
          'source': price.source,
        };
      }
      
      return null;
    } catch (e) {
      _logger.error('Error obteniendo detalles de $symbol: $e');
      return null;
    }
  }
  
  /// Detener el servicio
  Future<void> stopService() async {
    try {
      _isRunning = false;
      _priceTimer?.cancel();
      _heartbeatTimer?.cancel();
      
      if (_pythonAvailable) {
        if (Platform.isAndroid) {
          await _pythonChannel.invokeMethod('stopCryptoService');
        } else if (_pythonProcess != null) {
          _pythonProcess!.kill();
          _pythonProcess = null;
        }
      }
      
      _logger.info('✅ Servicio detenido');
    } catch (e) {
      _logger.error('Error deteniendo servicio: $e');
    }
  }
  
  /// Limpiar cache
  void clearCache() {
    _priceCache.clear();
    _lastUpdate = null;
    _logger.info('Cache limpiado');
  }
  
  /// Estado del cache
  Map<String, dynamic> getCacheStatus() {
    return {
      'has_cache': _priceCache.isNotEmpty,
      'cache_size': _priceCache.length,
      'last_update': _lastUpdate?.toIso8601String(),
      'minutes_since_update': _lastUpdate != null 
          ? DateTime.now().difference(_lastUpdate!).inMinutes 
          : null,
      'python_available': _pythonAvailable,
      'service_running': _isRunning,
      'symbols_cached': _priceCache.keys.toList(),
    };
  }
  
  /// Dispose del servicio
  void dispose() {
    stopService();
    _priceController.close();
  }
}
