import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart'; // Asumiremos que tienes un modelo para mensajes
import '../utils/logger.dart';

class GroqService {
  final AppLogger _logger = AppLogger();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // 🔐 SEGURIDAD: Obtener API key de almacenamiento seguro
  Future<String> get _apiKey async {
    try {
      // Primero intentar obtener de secure storage (configurada por usuario)
      final secureKey = await _secureStorage.read(key: 'groq_api_key');
      if (secureKey != null && secureKey.isNotEmpty && secureKey != 'your_groq_api_key_here') {
        return secureKey;
      }
      
      // Fallback a dotenv (solo para desarrollo - se puede quitar)
      try {
        final envKey = dotenv.env['GROQ_API_KEY'] ?? '';
        if (envKey.isNotEmpty && envKey != 'your_groq_api_key_here') {
          return envKey;
        }
      } catch (e) {
        // Ignorar errores de dotenv si no existe .env
        _logger.debug('Dotenv no disponible: $e');
      }
      
      return '';
    } catch (e) {
      _logger.error('Error obteniendo Groq API key: $e');
      return '';
    }
  }

  GroqService() {
    _logger.debug('Initializing GroqService with secure storage...');
  }

  static const String _apiBaseUrl = 'https://api.groq.com/openai/v1';

  /// Verifica si el servicio está correctamente configurado
  Future<bool> get isConfigured async {
    final apiKey = await _apiKey;
    return apiKey.isNotEmpty && apiKey != 'your_groq_api_key_here';
  }

  /// Obtiene el estado de configuración como mensaje
  Future<String> get configurationStatus async {
    final apiKey = await _apiKey;
    if (apiKey.isEmpty) {
      return 'La clave API de Groq no está configurada. Configúrala en el onboarding.';
    } else if (apiKey == 'your_groq_api_key_here') {
      return 'La clave API de Groq usa el valor por defecto. Configura tu clave real.';
    } else {
      return 'Servicio de Groq configurado correctamente';
    }
  }

  /// 🔐 Configurar API key de forma segura
  Future<void> setApiKey(String apiKey) async {
    try {
      await _secureStorage.write(key: 'groq_api_key', value: apiKey);
      _logger.info('Groq API key configurada de forma segura');
    } catch (e) {
      _logger.error('Error guardando Groq API key: $e');
      throw Exception('Error configurando clave API: $e');
    }
  }

  /// 🗑️ Eliminar API key
  Future<void> clearApiKey() async {
    try {
      await _secureStorage.delete(key: 'groq_api_key');
      _logger.info('Groq API key eliminada');
    } catch (e) {
      _logger.error('Error eliminando Groq API key: $e');
    }
  }

  /// Obtiene una respuesta de chat de la API de Groq.
  ///
  /// [messages] es el historial de la conversación.
  /// [model] es el modelo a utilizar (ej. 'llama-3.3-70b-versatile').
  Future<String> getChatCompletion({
    required List<ChatMessage> messages,
    String model = 'llama-3.3-70b-versatile',
  }) async {
    final apiKey = await _apiKey;
    if (apiKey.isEmpty || apiKey == 'your_groq_api_key_here') {
      const errorMsg = 'La clave API de Groq no está configurada. Por favor, configura tu API key en el onboarding de QUANTIX.';
      _logger.error(errorMsg);
      throw Exception(errorMsg);
    }

    _logger.info('Sending request to Groq with model $model...');

    final body = jsonEncode({
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'model': model,
    });

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data['choices'][0]['message']['content'] as String;
        _logger.info('Successfully received response from Groq.');
        return content.trim();
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMsg = 'Groq API Error: ${response.statusCode} - ${errorBody['error']['message']}';
        _logger.error(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e) {
      _logger.error('Failed to connect to Groq service: $e');
      throw Exception('Failed to connect to the AI assistant. Please check your network connection.');
    }
  }
}
