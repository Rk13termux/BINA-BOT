import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import '../models/chat_message.dart'; // Asumiremos que tienes un modelo para mensajes
import '../utils/logger.dart';

class GroqService {
  final AppLogger _logger = AppLogger();
  
  // Use getter to handle missing .env gracefully
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  GroqService() {
    _logger.debug('Groq API Key (first 5 chars): ${_apiKey.substring(0, min(5, _apiKey.length))}');
  }

  static const String _apiBaseUrl = 'https://api.groq.com/openai/v1';

  /// Obtiene una respuesta de chat de la API de Groq.
  ///
  /// [messages] es el historial de la conversación.
  /// [model] es el modelo a utilizar (ej. 'llama3-8b-8192').
  Future<String> getChatCompletion({
    required List<ChatMessage> messages,
    String model = 'llama3-8b-8192',
  }) async {
    if (_apiKey.isEmpty) {
      const errorMsg = 'Groq API key is not set in .env file.';
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
