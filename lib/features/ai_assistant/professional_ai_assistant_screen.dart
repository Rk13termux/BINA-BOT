import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../services/professional_ai_service.dart';
import '../../../services/binance_service.dart';
import '../../../utils/logger.dart';

/// Pantalla exclusiva para el asistente de IA profesional
class ProfessionalAIAssistantScreen extends StatefulWidget {
  final String? selectedSymbol;
  final String? selectedTimeframe;
  final List<String>? activeIndicators;

  const ProfessionalAIAssistantScreen({
    super.key,
    this.selectedSymbol,
    this.selectedTimeframe,
    this.activeIndicators,
  });

  @override
  State<ProfessionalAIAssistantScreen> createState() => _ProfessionalAIAssistantScreenState();
}

class _ProfessionalAIAssistantScreenState extends State<ProfessionalAIAssistantScreen>
    with TickerProviderStateMixin {
  static final AppLogger _logger = AppLogger();
  
  late AnimationController _pulseController;
  late AnimationController _messageController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _messageScale;
  
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isAnalyzing = false;
  bool _isChatting = false;
  
  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _messageScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _messageController, curve: Curves.elasticOut),
    );
    
    _initializeAI();
  }

  void _initializeAI() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiService = context.read<ProfessionalAIService>();
      final binanceService = context.read<BinanceService>();
      
      if (!aiService.isConnected) {
        aiService.initialize(binanceService);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF0A0A0A),
              Colors.black,
            ],
          ),
        ),
        child: Consumer<ProfessionalAIService>(
          builder: (context, aiService, _) {
            if (!aiService.isConnected) {
              return _buildNotConnectedView();
            }
            
            return Column(
              children: [
                // Header con estado de la IA
                _buildAIStatusHeader(aiService),
                
                // Sección de análisis automático
                _buildAnalysisSection(aiService),
                
                // Chat conversacional
                Expanded(
                  child: _buildChatSection(aiService),
                ),
                
                // Input de mensajes
                _buildMessageInput(aiService),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.goldPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldPrimary,
                        AppColors.goldPrimary.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INVICTUS AI',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Asistente Profesional',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.goldPrimary),
          onPressed: _refreshAnalysis,
        ),
        IconButton(
          icon: const Icon(Icons.clear_all, color: AppColors.textSecondary),
          onPressed: _clearChat,
        ),
      ],
    );
  }

  Widget _buildNotConnectedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.psychology_outlined,
                color: Colors.red,
                size: 60,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'IA No Configurada',
              style: TextStyle(
                color: AppColors.goldPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Para usar el asistente de IA necesitas configurar tu API key de Groq.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/api-config'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.settings),
              label: const Text('Configurar APIs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIStatusHeader(ProfessionalAIService aiService) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * 0.8 + 0.2,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldPrimary,
                        AppColors.goldPrimary.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invictus AI Assistant',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aiService.isAnalyzing 
                      ? 'Analizando mercado...' 
                      : 'Listo para analizar y motivar',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'CONECTADO',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection(ProfessionalAIService aiService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Análisis Automático',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _performAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: _isAnalyzing 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.play_arrow, size: 18),
                label: Text(_isAnalyzing ? 'Analizando...' : 'Analizar'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (aiService.currentAnalysis != null)
            _buildAnalysisResults(aiService.currentAnalysis!),
          
          if (aiService.currentAnalysis == null && !_isAnalyzing)
            Text(
              'Presiona "Analizar" para obtener un análisis profesional del mercado con motivación personalizada.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(AITradingAnalysis analysis) {
    Color trendColor;
    IconData trendIcon;
    
    switch (analysis.trend) {
      case 'BULLISH':
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case 'BEARISH':
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        break;
      default:
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tendencia y confianza
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: trendColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: trendColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, color: trendColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    analysis.trend,
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.goldPrimary, width: 1),
              ),
              child: Text(
                '${analysis.confidence.toStringAsFixed(1)}% Confianza',
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Análisis técnico
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Análisis Técnico',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.analysis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Motivación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💪 Motivación Personal',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.motivation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Recomendación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎯 Recomendación',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.recommendation,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection(ProfessionalAIService aiService) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header del chat
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat, color: AppColors.goldPrimary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Chat con Invictus AI',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${aiService.conversationHistory.length} mensajes',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: aiService.conversationHistory.length,
              itemBuilder: (context, index) {
                final conversation = aiService.conversationHistory[index];
                return _buildChatMessage(conversation, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(AIConversation conversation, int index) {
    return AnimatedBuilder(
      animation: _messageScale,
      builder: (context, child) {
        return Transform.scale(
          scale: index == context.read<ProfessionalAIService>().conversationHistory.length - 1 
              ? _messageScale.value 
              : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mensaje del usuario
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                    ),
                    child: Text(
                      conversation.message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Respuesta de la IA
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.goldPrimary,
                                    AppColors.goldPrimary.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.black,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Invictus AI',
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          conversation.response,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(ProfessionalAIService aiService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child:            TextField(
              controller: _textController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Pregúntame sobre trading, motivación o análisis...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldPrimary),
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _isChatting ? null : _sendMessage,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary,
                  AppColors.goldPrimary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: (_isChatting || _textController.text.trim().isEmpty) 
                  ? null 
                  : () => _sendMessage(_textController.text),
              icon: _isChatting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de acción
  Future<void> _performAnalysis() async {
    if (_isAnalyzing) return;
    
    setState(() {
      _isAnalyzing = true;
    });
    
    try {
      final aiService = context.read<ProfessionalAIService>();
      
      await aiService.analyzeMarket(
        symbol: widget.selectedSymbol ?? 'BTCUSDT',
        timeframe: widget.selectedTimeframe ?? '1h',
        activeIndicators: widget.activeIndicators ?? ['RSI', 'MACD', 'EMA'],
      );
      
      _logger.info('AI analysis completed');
    } catch (e) {
      _logger.error('Error performing AI analysis: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al realizar análisis: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty || _isChatting) return;
    
    setState(() {
      _isChatting = true;
    });
    
    _textController.clear();
    
    try {
      final aiService = context.read<ProfessionalAIService>();
      
      final response = await aiService.chatWithAssistant(
        message,
        context: 'Symbol: ${widget.selectedSymbol ?? "BTCUSDT"}, Timeframe: ${widget.selectedTimeframe ?? "1h"}',
      );
      
      if (response != null) {
        _messageController.forward();
        
        // Scroll hacia abajo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      _logger.error('Error sending message to AI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar mensaje: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isChatting = false;
      });
    }
  }

  void _refreshAnalysis() {
    _performAnalysis();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Limpiar Chat', style: TextStyle(color: AppColors.goldPrimary)),
        content: const Text(
          '¿Estás seguro de que quieres limpiar todo el historial de conversación?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfessionalAIService>().clearConversationHistory();
              Navigator.pop(context);
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _messageController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
