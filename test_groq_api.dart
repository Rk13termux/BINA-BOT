import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Script de prueba para verificar la conectividad con la API de Groq
/// 
/// Este script verifica:
/// 1. Si el archivo .env existe y tiene la clave GROQ_API_KEY
/// 2. Si la API de Groq responde correctamente
/// 3. Si el formato de la respuesta es el esperado
void main() async {
  print('🔧 Iniciando pruebas de la API de Groq...\n');

  // Test 1: Verificar archivo .env
  final apiKey = await testDotEnvFile();
  
  if (apiKey.isNotEmpty && apiKey != 'your_groq_api_key_here') {
    // Test 2: Probar conectividad con la API
    await testGroqApiConnectivity(apiKey);
  } else {
    print('⚠️  Saltando test de conectividad (API key no configurada)');
  }
  
  print('\n✅ Pruebas completadas.');
}

/// Test 1: Verificar si el archivo .env existe y extraer la API key
Future<String> testDotEnvFile() async {
  print('📄 Test 1: Verificando archivo .env...');
  
  final envFile = File('.env');
  if (await envFile.exists()) {
    print('   ✅ Archivo .env encontrado');
    
    final content = await envFile.readAsString();
    final lines = content.split('\n');
    
    String? groqApiKey;
    for (final line in lines) {
      if (line.trim().startsWith('GROQ_API_KEY=')) {
        groqApiKey = line.split('=').skip(1).join('=').trim();
        break;
      }
    }
    
    if (groqApiKey != null) {
      print('   ✅ Variable GROQ_API_KEY encontrada en .env');
      
      if (groqApiKey.isEmpty) {
        print('   ❌ GROQ_API_KEY está vacía');
        return '';
      } else if (groqApiKey == 'your_groq_api_key_here') {
        print('   ❌ GROQ_API_KEY tiene el valor por defecto');
        print('   💡 Configura tu clave real de Groq');
        return groqApiKey;
      } else {
        print('   ✅ GROQ_API_KEY configurada');
        print('   🔍 Longitud: ${groqApiKey.length} caracteres');
        print('   🔍 Primeros 10 chars: ${groqApiKey.substring(0, groqApiKey.length > 10 ? 10 : groqApiKey.length)}...');
        
        // Verificar formato básico de la clave
        if (groqApiKey.startsWith('gsk_')) {
          print('   ✅ Formato de clave parece correcto (comienza con gsk_)');
        } else {
          print('   ⚠️  Formato de clave inusual (no comienza con gsk_)');
        }
        return groqApiKey;
      }
    } else {
      print('   ❌ Variable GROQ_API_KEY NO encontrada en .env');
      return '';
    }
  } else {
    print('   ❌ Archivo .env NO encontrado');
    print('   💡 Crea un archivo .env en la raíz del proyecto');
    return '';
  }
}

/// Test 2: Probar conectividad con la API de Groq
Future<void> testGroqApiConnectivity(String apiKey) async {
  print('\n🌐 Test 2: Probando conectividad con API de Groq...');
  
  const baseUrl = 'https://api.groq.com/openai/v1';
  
  // Preparar mensaje de prueba
  final testMessage = {
    'messages': [
      {
        'role': 'user',
        'content': 'Hola, solo di "API funcionando correctamente" para confirmar que la conexión está bien.'
      }
    ],
    'model': 'llama3-8b-8192',
    'max_tokens': 50,
  };
  
  try {
    print('   🔄 Enviando petición de prueba...');
    
    final response = await http.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(testMessage),
    );
    
    print('   📡 Código de respuesta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      print('   ✅ Conexión exitosa con la API de Groq');
      
      try {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        print('   📄 Estructura de respuesta válida');
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final content = data['choices'][0]['message']['content'] as String;
          print('   💬 Respuesta de la IA: "${content.trim()}"');
          print('   ✅ Test de conectividad EXITOSO');
        } else {
          print('   ⚠️  Respuesta sin contenido esperado');
        }
        
        // Mostrar información adicional
        if (data['usage'] != null) {
          print('   📊 Tokens usados: ${data['usage']['total_tokens']}');
        }
        
      } catch (e) {
        print('   ❌ Error al parsear respuesta JSON: $e');
        print('   📄 Respuesta cruda: ${response.body}');
      }
      
    } else {
      print('   ❌ Error en la API (${response.statusCode})');
      print('   📄 Respuesta: ${response.body}');
      
      // Diagnóstico de errores comunes
      if (response.statusCode == 401) {
        print('   💡 Error 401: Clave API inválida o expirada');
      } else if (response.statusCode == 429) {
        print('   💡 Error 429: Límite de rate alcanzado');
      } else if (response.statusCode == 500) {
        print('   💡 Error 500: Problema del servidor de Groq');
      }
    }
    
  } catch (e) {
    print('   ❌ Error de conectividad: $e');
    print('   💡 Verifica tu conexión a internet');
  }
}
