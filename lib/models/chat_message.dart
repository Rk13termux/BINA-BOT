/// Representa un único mensaje en una conversación de chat.
class ChatMessage {
  final String role; // 'user', 'assistant', o 'system'
  final String content;

  ChatMessage({required this.role, required this.content});

  /// Convierte el objeto a un mapa JSON, compatible con la API de Groq/OpenAI.
  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}
