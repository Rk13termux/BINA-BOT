import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../lib/core/api_manager.dart';
import '../lib/core/websocket_manager.dart';
import '../lib/services/groq_service.dart';
import '../lib/models/chat_message.dart';

void main() {
  // Es necesario inicializar el binding de Flutter para que FlutterSecureStorage funcione correctamente en los tests.
  // Esto soluciona el error: "Binding has not yet been initialized".
  TestWidgetsFlutterBinding.ensureInitialized();
  group('API Connectivity Tests', () {
    test('Binance REST API connectivity', () async {
      final apiManager = ApiManager();
      await apiManager.loadCredentials();
      final url = Uri.parse('https://api.binance.com/api/v3/ping');
      final response = await http.get(url);
      expect(response.statusCode, 200);
    });

    test('Binance WebSocket connectivity', () async {
      final wsManager = WebSocketManager();
      final stream = wsManager.subscribeTicker('BTCUSDT');
      bool received = false;
      final sub = stream.listen((data) {
        received = true;
      });
      await Future.delayed(const Duration(seconds: 3));
      await sub.cancel();
      expect(received, true);
    });

    test('Groq API connectivity', () async {
      await dotenv.load();
      final groqService = GroqService();
      final messages = [ChatMessage(role: 'user', content: 'Hola, ¿cómo estás?')];
      String reply = '';
      try {
        reply = await groqService.getChatCompletion(messages: messages);
      } catch (e) {
        reply = '';
      }
      expect(reply.isNotEmpty, true);
    });
  });
}
