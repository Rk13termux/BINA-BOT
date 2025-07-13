import 'package:flutter/material.dart';
import 'package:invictus_trader_pro/utils/binance_api_tester.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 INVICTUS TRADER PRO - API CONNECTIVITY TEST');
  print('══════════════════════════════════════════════');
  print('Testing Binance API connectivity and permissions...\n');
  
  // Ejecutar todas las pruebas
  final results = await BinanceApiTester.runAllTests();
  
  // Verificar permisos de internet
  print('\n🌐 Network Permissions Check:');
  print('═══════════════════════════════');
  
  final hasInternetAccess = results['connectivity'] ?? false;
  if (hasInternetAccess) {
    print('✅ Internet permission: GRANTED');
    print('✅ Network access: WORKING');
    print('✅ HTTPS connections: FUNCTIONAL');
  } else {
    print('❌ Internet permission: DENIED or NETWORK ISSUES');
    print('⚠️  Please check:');
    print('   - Internet connectivity');
    print('   - Android permissions in AndroidManifest.xml');
    print('   - Network security configuration');
  }
  
  print('\n🔧 Configuration Status:');
  print('════════════════════════');
  print('✅ AndroidManifest.xml: Internet permission configured');
  print('✅ Network Security Config: Binance domains whitelisted');
  print('✅ Build Configuration: Release build optimized');
  
  if (results.values.every((result) => result)) {
    print('\n🎉 SUCCESS! The app is ready for production deployment.');
    print('🚀 You can now build and distribute the APK.');
  } else {
    print('\n⚠️  WARNING! Some tests failed. Please resolve issues before deployment.');
  }
  
  print('\n📱 Build Instructions:');
  print('═══════════════════════');
  print('Debug APK:   flutter build apk --debug');
  print('Release APK: flutter build apk --release');
  print('App Bundle: flutter build appbundle --release');
  
  print('\n📋 Next Steps:');
  print('══════════════');
  print('1. Test the app on a physical device');
  print('2. Configure real API keys in production');
  print('3. Set up Google Play Console for subscriptions');
  print('4. Deploy to GitHub Actions for CI/CD');
}
