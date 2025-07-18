import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/groq_service.dart';
import '../../services/binance_service.dart';
import '../../models/chat_message.dart';
import '../../ui/theme/quantix_theme.dart';
import '../../utils/logger.dart';

/// 🤖 QUANTIX AI Chat - Asistente Inteligente
/// Integra Groq AI + Binance para análisis completo
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>
    with TickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  
  // Animaciones
  late AnimationController _typingAnimationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    // Eliminada animación typing no utilizada
    
    // Mensaje inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addInitialMessage();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  /// 🎬 Agregar mensaje inicial de QUANTIX
  Future<void> _addInitialMessage() async {
    try {
      final groqService = Provider.of<GroqService>(context, listen: false);
      final binanceService = Provider.of<BinanceService>(context, listen: false);
      
      final groqConfigured = await groqService.isConfigured;
      final binanceConfigured = await binanceService.isConfigured;
      
      String initialMessage;
      
      if (!groqConfigured && !binanceConfigured) {
        initialMessage = '''🔐 **QUANTIX AI CORE**

⚠️ **APIs no configuradas**

Para usar el asistente inteligente:
1. Configura tu **Groq API** (IA GRATIS)
2. Configura tu **Binance API** (datos de mercado)

Ve a **Configuración → API Keys** o reinicia la app para el onboarding.''';
      } else if (!groqConfigured) {
        initialMessage = '''🤖 **QUANTIX AI**

⚠️ **Groq AI no configurado**

Necesitas configurar tu API de Groq para análisis inteligente.
• Gratuito con 70B parámetros
• Análisis de mercado avanzado

Ve a **Configuración → API Keys**.''';
      } else if (!binanceConfigured) {
        initialMessage = '''📈 **QUANTIX TRADING**

⚠️ **Binance no configurado**

Configura Binance para:
• Datos de mercado en tiempo real
• Análisis de portfolio
• Precios y volúmenes

Ve a **Configuración → API Keys**.''';
      } else {
        initialMessage = '''🚀 **QUANTIX AI CORE ACTIVO**

¡Hola! Soy tu asistente de trading profesional.

💡 **Puedo ayudarte con:**
• 📊 Análisis de mercado y tendencias
• 💰 Evaluación de tu portfolio
• 🔍 Investigación de criptomonedas
• 📈 Estrategias de trading
• 📰 Análisis de noticias crypto

**¿En qué puedo asistirte hoy?**''';
      }
      
      setState(() {
        _messages.add(ChatMessage(
          content: initialMessage,
          role: 'assistant',
        ));
      });
      
    } catch (e) {
      _logger.error('Error en mensaje inicial: $e');
      setState(() {
        _messages.add(ChatMessage(
          content: '⚠️ Error inicializando QUANTIX AI. Verifica la configuración.',
          role: 'assistant',
        ));
      });
    }
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
      final binanceService = Provider.of<BinanceService>(context, listen: false);
      
      // Verificar si el servicio está configurado
      final groqConfigured = await groqService.isConfigured;
      if (!groqConfigured) {
        setState(() {
          _messages.add(ChatMessage(
            content: '''⚠️ **Groq AI no configurado**

Para usar el asistente inteligente necesitas configurar tu API de Groq.

Ve a **Configuración → API Keys** para configurar.''',
            role: 'assistant',
          ));
        });
        return;
      }

      // Construir contexto mejorado con datos de Binance si está disponible
      String enhancedPrompt = text;
      final binanceConfigured = await binanceService.isConfigured;
      
      if (binanceConfigured && binanceService.isAuthenticated) {
        try {
          // Obtener información de la cuenta para contexto
          final accountInfo = binanceService.accountInfo;
          if (accountInfo != null) {
            enhancedPrompt = '''CONTEXTO DE USUARIO:
Portfolio: ${accountInfo.balances.where((b) => b.free > 0).map((b) => '${b.asset}: ${b.free}').join(', ')}

CONSULTA DEL USUARIO: $text

Por favor, proporciona un análisis contextualizado basado en su portfolio actual y las condiciones del mercado.''';
          }
        } catch (e) {
          _logger.error('Error obteniendo datos de Binance: $e');
        }
      }

      final response = await groqService.getChatCompletion(messages: [
        ..._messages.where((m) => m.role != 'assistant' || !m.content.contains('⚠️')),
        ChatMessage(content: enhancedPrompt, role: 'user'),
      ]);

      setState(() {
        _messages.add(ChatMessage(content: response, role: 'assistant'));
      });
      
      // Scroll automático
      _scrollToBottom();
      
    } catch (e) {
      _logger.error('Error sending message to AI: $e');
      setState(() {
        _messages.add(ChatMessage(
          content: '''❌ **Error de Comunicación**
          
Hubo un problema al procesar tu consulta:
• Verifica tu conexión a internet
• Revisa la configuración de tu API de Groq
• Intenta nuevamente en unos momentos

Si el problema persiste, verifica que tu API key sea válida.''',
          role: 'assistant',
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Scroll automático al final
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuantixTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: QuantixTheme.secondaryBlack,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, color: QuantixTheme.primaryGold),
            const SizedBox(width: 8),
            Text(
              'QUANTIX AI',
              style: TextStyle(color: QuantixTheme.primaryGold, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
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
