import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../services/ai_assistant_service.dart';

enum NotifierState { initial, loading, loaded, error }

class AIAssistantController extends ChangeNotifier {
  final AIAssistantService _aiAssistantService;

  AIAssistantController({required AIAssistantService aiAssistantService})
      : _aiAssistantService = aiAssistantService;

  NotifierState _state = NotifierState.initial;
  String _errorMessage = '';
  List<ChatMessage> _messages = [];

  NotifierState get state => _state;
  String get errorMessage => _errorMessage;
  List<ChatMessage> get messages => _messages;

  /// Envía un mensaje a la IA y actualiza el estado.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Añade el mensaje del usuario a la UI inmediatamente
    _messages.add(ChatMessage(role: 'user', content: text));
    _state = NotifierState.loading; // Muestra el indicador de "pensando..."
    notifyListeners();

    try {
      await _aiAssistantService.sendMessage(text);
      _messages = List.from(_aiAssistantService.history);
      _state = NotifierState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = NotifierState.error;
      // Si hay un error, elimina el último mensaje del usuario para que pueda reintentar
      _messages.removeLast(); 
    } finally {
      notifyListeners();
    }
  }

  /// Limpia la conversación.
  void clearChat() {
    _aiAssistantService.clearConversation();
    _messages = [];
    _state = NotifierState.initial;
    notifyListeners();
  }
}
