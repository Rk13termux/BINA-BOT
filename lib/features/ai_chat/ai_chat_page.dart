import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/groq_service.dart';
import '../../models/chat_message.dart';
import '../../ui/theme/app_theme.dart';
import '../../utils/logger.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final AppLogger _logger = AppLogger();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    _messages.add(ChatMessage(
      content: '¡Hola! Soy tu asistente de IA para análisis de mercado. ¿En qué puedo ayudarte hoy?',
      role: 'assistant',
    ));
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, role: 'user'));
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final groqService = Provider.of<GroqService>(context, listen: false);
      final response = await groqService.getChatCompletion(messages: _messages);

      setState(() {
        _messages.add(ChatMessage(content: response, role: 'assistant'));
      });
    } catch (e) {
      _logger.error('Error sending message to AI: $e');
      setState(() {
        _messages.add(ChatMessage(
          content: 'Lo siento, hubo un error al procesar tu solicitud: $e',
          role: 'assistant',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Asistente de IA para Mercado',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.role == 'user' ? Colors.blueAccent : Colors.grey[800],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe tu mensaje...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10.0),
          FloatingActionButton(
            onPressed: _isLoading ? null : _sendMessage,
            backgroundColor: const Color(0xFFFFD700),
            mini: true,
            child: _isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    strokeWidth: 2,
                  )
                : const Icon(Icons.send, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
