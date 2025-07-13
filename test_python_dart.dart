import 'dart:io';

void main() async {
  print('🧪 Probando integración Python desde Dart...');
  
  try {
    // Verificar Python
    print('\n📋 Verificando Python...');
    final pythonResult = await Process.run('python', ['--version']);
    print('Python: ${pythonResult.stdout}');
    
    // Probar nuestro script
    print('\n🐍 Probando script crypto_service...');
    final scriptResult = await Process.run(
      'python', 
      ['-c', '''
import sys
sys.path.append("assets")
from crypto_service import get_current_prices_json
result = get_current_prices_json("BTC,ETH,BNB")
print(result)
''']
    );
    
    if (scriptResult.exitCode == 0) {
      print('✅ Script ejecutado exitosamente:');
      print(scriptResult.stdout);
    } else {
      print('❌ Error ejecutando script:');
      print(scriptResult.stderr);
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
