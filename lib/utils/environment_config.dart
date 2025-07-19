import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
    } catch (e) {
      // Si no se puede cargar el archivo .env, usar valores por defecto
      _setDefaultValues();
      _isInitialized = true;
    }
  }

  static void _setDefaultValues() {
    final defaultEnv = <String, String>{
      'GROQ_API_KEY': 'your_groq_api_key_here',
      'GROQ_BASE_URL': 'https://api.groq.com/openai/v1/chat/completions',
      'GROQ_MODEL': 'mistral-7b-8k',
      'GROQ_MAX_TOKENS': '512',
      'GROQ_TEMPERATURE': '0.5',
      'BINANCE_API_KEY': 'your_binance_api_key_here',
      'BINANCE_SECRET_KEY': 'your_binance_secret_key_here',
      'BINANCE_BASE_URL': 'https://api.binance.com',
      'BINANCE_WS_URL': 'wss://stream.binance.com:9443/ws',
      'APP_NAME': 'Invictus Trader Pro',
      'APP_VERSION': '1.0.0',
      'DEBUG_MODE': 'true',
      'ENABLE_AI_ANALYSIS': 'true',
    };
    for (final entry in defaultEnv.entries) {
      dotenv.env[entry.key] = entry.value;
    }
  }
}
