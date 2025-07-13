import 'dart:convert';
import 'package:http/http.dart' as http;

/// Clase para probar la conectividad y configuración de la API de Binance
class BinanceApiTester {
  static const String _baseUrl = 'https://api.binance.com';
  static const String _testnetUrl = 'https://testnet.binance.vision';

  /// Probar conectividad básica a la API de Binance
  static Future<bool> testBasicConnectivity() async {
    try {
      print('🔄 Testing Binance API connectivity...');
      
      // Test servidor de tiempo
      final timeResponse = await http.get(
        Uri.parse('$_baseUrl/api/v3/time'),
        headers: {
          'User-Agent': 'Invictus-Trader-Pro/1.0.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (timeResponse.statusCode == 200) {
        final timeData = json.decode(timeResponse.body);
        final serverTime = DateTime.fromMillisecondsSinceEpoch(timeData['serverTime']);
        print('✅ Binance API is reachable');
        print('📅 Server time: $serverTime');
        return true;
      } else {
        print('❌ Failed to connect to Binance API: ${timeResponse.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error connecting to Binance API: $e');
      return false;
    }
  }

  /// Probar información de exchange
  static Future<bool> testExchangeInfo() async {
    try {
      print('🔄 Testing exchange info...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v3/exchangeInfo'),
        headers: {
          'User-Agent': 'Invictus-Trader-Pro/1.0.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final symbols = data['symbols'] as List;
        final btcusdt = symbols.firstWhere(
          (symbol) => symbol['symbol'] == 'BTCUSDT',
          orElse: () => null,
        );
        
        if (btcusdt != null) {
          print('✅ Exchange info retrieved successfully');
          print('📊 Found ${symbols.length} trading pairs');
          print('💰 BTCUSDT status: ${btcusdt['status']}');
          return true;
        } else {
          print('❌ BTCUSDT pair not found');
          return false;
        }
      } else {
        print('❌ Failed to get exchange info: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error getting exchange info: $e');
      return false;
    }
  }

  /// Probar precios de ticker
  static Future<bool> testTickerPrices() async {
    try {
      print('🔄 Testing ticker prices...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v3/ticker/price?symbol=BTCUSDT'),
        headers: {
          'User-Agent': 'Invictus-Trader-Pro/1.0.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final price = double.parse(data['price']);
        print('✅ Ticker prices working');
        print('💰 BTCUSDT price: \$${price.toStringAsFixed(2)}');
        return true;
      } else {
        print('❌ Failed to get ticker prices: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error getting ticker prices: $e');
      return false;
    }
  }

  /// Probar datos de velas (candlestick)
  static Future<bool> testKlineData() async {
    try {
      print('🔄 Testing kline/candlestick data...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v3/klines?symbol=BTCUSDT&interval=1h&limit=10'),
        headers: {
          'User-Agent': 'Invictus-Trader-Pro/1.0.0',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          print('✅ Kline data retrieved successfully');
          print('📊 Retrieved ${data.length} candles');
          final latestCandle = data.last;
          final openPrice = double.parse(latestCandle[1]);
          final closePrice = double.parse(latestCandle[4]);
          print('📈 Latest candle: Open: \$${openPrice.toStringAsFixed(2)}, Close: \$${closePrice.toStringAsFixed(2)}');
          return true;
        } else {
          print('❌ No kline data received');
          return false;
        }
      } else {
        print('❌ Failed to get kline data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error getting kline data: $e');
      return false;
    }
  }

  /// Ejecutar todas las pruebas
  static Future<Map<String, bool>> runAllTests() async {
    print('🚀 Starting Binance API connectivity tests...\n');
    
    final results = <String, bool>{};
    
    results['connectivity'] = await testBasicConnectivity();
    print('');
    
    results['exchangeInfo'] = await testExchangeInfo();
    print('');
    
    results['tickerPrices'] = await testTickerPrices();
    print('');
    
    results['klineData'] = await testKlineData();
    print('');
    
    // Resumen
    print('📋 Test Results Summary:');
    print('═══════════════════════');
    results.forEach((test, passed) {
      final icon = passed ? '✅' : '❌';
      print('$icon $test: ${passed ? 'PASSED' : 'FAILED'}');
    });
    
    final allPassed = results.values.every((result) => result);
    print('\n🎯 Overall: ${allPassed ? 'ALL TESTS PASSED' : 'SOME TESTS FAILED'}');
    
    if (allPassed) {
      print('🎉 Binance API is fully functional and ready for trading!');
    } else {
      print('⚠️  Please check network connectivity and API configuration.');
    }
    
    return results;
  }

  /// Test rápido para usar en la aplicación
  static Future<bool> quickHealthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v3/ping'),
        headers: {'User-Agent': 'Invictus-Trader-Pro/1.0.0'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
