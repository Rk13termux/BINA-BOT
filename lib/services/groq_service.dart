import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart'; // Asumiremos que tienes un modelo para mensajes
import '../utils/logger.dart';

class GroqService {
  final AppLogger _logger = AppLogger();
  
  // Use getter to handle missing .env gracefully
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  GroqService() {
    try {
      _logger.debug('Initializing GroqService...');
      _logger.debug('dotenv loaded: ${dotenv.env.isNotEmpty}');
      _logger.debug('GROQ_API_KEY available: ${dotenv.env.containsKey('GROQ_API_KEY')}');
      _logger.debug('API Key length: ${_apiKey.length}');
      if (_apiKey.isNotEmpty && _apiKey.length >= 5) {
        _logger.debug('Groq API Key (first 5 chars): ${_apiKey.substring(0, 5)}...');
      } else {
        _logger.warning('Groq API Key is empty or too short');
      }
    } catch (e) {
      _logger.error('Error initializing GroqService: $e');
    }
  }

  static const String _apiBaseUrl = 'https://api.groq.com/openai/v1';

  /// Verifica si el servicio está correctamente configurado
  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'your_groq_api_key_here';

  /// Obtiene el estado de configuración como mensaje
  String get configurationStatus {
    if (_apiKey.isEmpty) {
      return 'La clave API de Groq no está configurada en el archivo .env';
    } else if (_apiKey == 'your_groq_api_key_here') {
      return 'La clave API de Groq usa el valor por defecto. Configura tu clave real.';
    } else {
      return 'Servicio de Groq configurado correctamente';
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
    if (_apiKey.isEmpty || _apiKey == 'your_groq_api_key_here') {
      const errorMsg = 'La clave API de Groq no está configurada. Por favor, configura tu API key en la configuración de la app.';
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
          'Authorization': 'Bearer $_apiKey',
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
