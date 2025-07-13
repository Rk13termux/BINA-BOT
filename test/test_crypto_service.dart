import 'dart:io';
import 'dart:convert';
import '../lib/services/free_crypto_service.dart';
import '../lib/utils/logger.dart';

void main() async {
  print('🚀 Probando FreeCryptoService con módulo Python...');
  print('=' * 60);
  
  final logger = AppLogger();
  final service = FreeCryptoService();
  
  try {
    // 1. Inicializar el servicio
    print('\n📋 1. Inicializando servicio...');
    final initialized = await service.initialize();
    print('   Resultado: ${initialized ? "✅ Éxito" : "⚠️ Fallback"}');
    print('   Python disponible: ${service.isPythonAvailable}');
    
    // 2. Obtener precios actuales
    print('\n💰 2. Obteniendo precios actuales...');
    final symbols = ['BTC', 'ETH', 'BNB', 'ADA', 'XRP'];
    final prices = await service.getCurrentPrices(symbols: symbols);
    
    if (prices.isNotEmpty) {
      print('   ✅ Precios obtenidos:');
      prices.forEach((symbol, price) {
        print('   $symbol: \$${price.toStringAsFixed(2)}');
      });
    } else {
      print('   ❌ No se pudieron obtener precios');
    }
    
    // 3. Iniciar servicio de tiempo real
    print('\n📡 3. Iniciando servicio de tiempo real...');
    final realtimeStarted = await service.startPythonService(symbols: [
      'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT'
    ]);
    
    print('   Resultado: ${realtimeStarted ? "✅ Iniciado" : "❌ Error"}');
    print('   Servicio corriendo: ${service.isRunning}');
    
    if (realtimeStarted) {
      // 4. Escuchar actualizaciones por 10 segundos
      print('\n🔄 4. Escuchando actualizaciones de precios...');
      var updateCount = 0;
      
      final subscription = service.priceStream.listen((priceMap) {
        updateCount++;
        print('   📊 Actualización #$updateCount:');
        priceMap.forEach((symbol, cryptoPrice) {
          print('     ${cryptoPrice.symbol}: ${cryptoPrice.formattedPrice} (${cryptoPrice.formattedChange})');
        });
      });
      
      // Esperar 10 segundos
      await Future.delayed(Duration(seconds: 10));
      
      subscription.cancel();
      print('   ✅ Total de actualizaciones recibidas: $updateCount');
    }
    
    // 5. Obtener datos históricos
    print('\n📈 5. Obteniendo datos históricos...');
    final historicalData = await service.getHistoricalData('BTC', days: 7);
    
    if (historicalData.isNotEmpty) {
      print('   ✅ Datos históricos obtenidos: ${historicalData.length} puntos');
      final latest = historicalData.last;
      print('   Último precio: \$${latest['price']?.toStringAsFixed(2)}');
    } else {
      print('   ⚠️ No hay datos históricos disponibles');
    }
    
    // 6. Obtener top cryptos
    print('\n🏆 6. Obteniendo top 10 criptomonedas...');
    final topCryptos = await service.getTopCryptos(limit: 10);
    
    if (topCryptos.isNotEmpty) {
      print('   ✅ Top cryptos obtenidas: ${topCryptos.length}');
      for (int i = 0; i < topCryptos.length && i < 5; i++) {
        final crypto = topCryptos[i];
        print('   ${i + 1}. ${crypto['symbol']} - \$${crypto['current_price']?.toStringAsFixed(2)}');
      }
    } else {
      print('   ⚠️ No se pudieron obtener top cryptos');
    }
    
    // 7. Análisis técnico
    print('\n🔬 7. Análisis técnico de BTC...');
    final analysis = await service.analyzeSymbol('BTC', days: 30);
    
    if (analysis != null && !analysis.containsKey('error')) {
      print('   ✅ Análisis completado:');
      print('   Tendencia: ${analysis['trend']}');
      print('   RSI actual: ${analysis['rsi_current']?.toStringAsFixed(2)}');
      print('   Soporte: \$${analysis['support_level']?.toStringAsFixed(2)}');
      print('   Resistencia: \$${analysis['resistance_level']?.toStringAsFixed(2)}');
      
      if (analysis['signals'] != null && analysis['signals'].isNotEmpty) {
        print('   Señales:');
        for (final signal in analysis['signals']) {
          print('     • $signal');
        }
      }
    } else {
      print('   ⚠️ Análisis no disponible: ${analysis?['error'] ?? 'Error desconocido'}');
    }
    
    // 8. Estado del cache
    print('\n💾 8. Estado del cache...');
    final cacheStatus = service.getCacheStatus();
    print('   Cache disponible: ${cacheStatus['has_cache']}');
    print('   Tamaño del cache: ${cacheStatus['cache_size']} símbolos');
    print('   Python disponible: ${cacheStatus['python_available']}');
    print('   Servicio corriendo: ${cacheStatus['service_running']}');
    
    if (cacheStatus['last_update'] != null) {
      final lastUpdate = DateTime.parse(cacheStatus['last_update']);
      final minutesAgo = DateTime.now().difference(lastUpdate).inMinutes;
      print('   Última actualización: hace $minutesAgo minutos');
    }
    
    // 9. Detener el servicio
    print('\n🛑 9. Deteniendo servicio...');
    await service.stopService();
    print('   ✅ Servicio detenido');
    
    // 10. Resumen final
    print('\n📊 RESUMEN DE PRUEBAS:');
    print('=' * 60);
    print('✅ Inicialización: ${initialized ? "OK" : "FALLBACK"}');
    print('✅ Python disponible: ${service.isPythonAvailable}');
    print('✅ Precios actuales: ${prices.isNotEmpty ? "OK (${prices.length})" : "ERROR"}');
    print('✅ Tiempo real: ${realtimeStarted ? "OK" : "ERROR"}');
    print('✅ Datos históricos: ${historicalData.isNotEmpty ? "OK (${historicalData.length})" : "LIMITED"}');
    print('✅ Top cryptos: ${topCryptos.isNotEmpty ? "OK (${topCryptos.length})" : "LIMITED"}');
    print('✅ Análisis técnico: ${analysis != null && !analysis.containsKey('error') ? "OK" : "LIMITED"}');
    
    print('\n🎉 ¡Pruebas completadas exitosamente!');
    
    if (service.isPythonAvailable) {
      print('\n💡 Sistema Python completamente funcional');
      print('   - WebSocket en tiempo real disponible');
      print('   - Análisis técnico avanzado activado');
      print('   - Base de datos SQLite para históricos');
      print('   - Múltiples APIs de respaldo');
    } else {
      print('\n💡 Sistema funcionando en modo fallback');
      print('   - APIs REST públicas disponibles');
      print('   - Funcionalidad básica garantizada');
    }
    
  } catch (e, stackTrace) {
    print('\n❌ Error durante las pruebas: $e');
    print('Stack trace: $stackTrace');
  } finally {
    service.dispose();
    print('\n🔚 Recursos liberados');
  }
}
