import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';

/// Widget que demuestra la integración del servicio de IA
class AIServiceDemo extends StatefulWidget {
  const AIServiceDemo({super.key});

  @override
  State<AIServiceDemo> createState() => _AIServiceDemoState();
}

class _AIServiceDemoState extends State<AIServiceDemo> {
  final TextEditingController _apiKeyController = TextEditingController();
  AIMarketAnalysis? _lastAnalysis;
  AITradingSignal? _lastSignal;
  AISentimentAnalysis? _lastSentiment;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    final aiService = Provider.of<AIService>(context, listen: false);
    await aiService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIService>(
      builder: (context, aiService, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          appBar: AppBar(
            title: const Text('IA - Mistral 7B'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(
                  aiService.isAvailable ? Icons.smart_toy : Icons.smart_toy_outlined,
                  color: aiService.isAvailable ? Colors.green : Colors.grey,
                ),
                onPressed: () => _showServiceStatus(aiService),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceStatus(aiService),
                const SizedBox(height: 24),
                
                if (!aiService.isAvailable) ...[
                  _buildApiKeySetup(aiService),
                  const SizedBox(height: 24),
                ],
                
                // Demo de funciones de IA
                if (aiService.isAvailable) ...[
                  _buildAIFunctions(aiService),
                  const SizedBox(height: 24),
                  
                  // Resultados
                  if (_lastAnalysis != null) _buildAnalysisResult(),
                  if (_lastSignal != null) _buildSignalResult(),
                  if (_lastSentiment != null) _buildSentimentResult(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceStatus(AIService aiService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            aiService.isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: aiService.isAvailable ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                aiService.isAvailable ? Icons.check_circle : Icons.error,
                color: aiService.isAvailable ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aiService.isAvailable ? 'IA Operativa' : 'IA No Disponible',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      aiService.isAvailable 
                          ? 'Mistral 7B conectado via Groq Cloud'
                          : 'Configure su API key de Groq para activar',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Info del plan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Plan PRO - Acceso completo a IA sin límites',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeySetup(AIService aiService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔑 Configurar API Key de Groq',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Obtenga su API key gratuita en: https://console.groq.com',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _apiKeyController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ingrese su API key de Groq...',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              prefixIcon: const Icon(Icons.key, color: Colors.amber),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _configureApiKey(aiService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Configurar API Key',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFunctions(AIService aiService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Funciones de IA Disponibles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Análisis de Mercado
        _buildAIFunctionCard(
          title: '📊 Análisis de Mercado',
          description: 'Análisis técnico avanzado con IA',
          isEnabled: true,
          onTap: () => _performMarketAnalysis(aiService),
        ),
        
        const SizedBox(height: 12),
        
        // Señales de Trading
        _buildAIFunctionCard(
          title: '🎯 Generación de Señales',
          description: 'Señales de trading basadas en IA',
          isEnabled: true,
          onTap: () => _generateTradingSignal(aiService),
        ),
        
        const SizedBox(height: 12),
        
        // Análisis de Sentiment
        _buildAIFunctionCard(
          title: '📰 Análisis de Sentiment',
          description: 'Análisis de noticias y sentiment',
          isEnabled: true,
          onTap: () => _analyzeNewsSentiment(aiService),
        ),
      ],
    );
  }

  Widget _buildAIFunctionCard({
    required String title,
    required String description,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFF1A1A1A) : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Colors.amber.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isEnabled ? Colors.white : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: isEnabled ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (_isAnalyzing)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.amber),
                ),
              )
            else
              Icon(
                isEnabled ? Icons.play_arrow : Icons.lock,
                color: isEnabled ? Colors.amber : Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Análisis de Mercado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Símbolo: ${_lastAnalysis!.symbol}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Tendencia: ${_lastAnalysis!.trend.toUpperCase()}',
            style: TextStyle(
              color: _getTrendColor(_lastAnalysis!.trend),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Fuerza: ${_lastAnalysis!.strength.toStringAsFixed(1)}/10',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Confianza: ${_lastAnalysis!.confidence.toStringAsFixed(1)}/10',
            style: const TextStyle(color: Colors.white70),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _lastAnalysis!.summary,
            style: const TextStyle(
              color: Colors.amber,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalResult() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.track_changes, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Señal de Trading',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Símbolo: ${_lastSignal!.symbol}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Acción: ${_lastSignal!.action.toUpperCase()}',
            style: TextStyle(
              color: _getActionColor(_lastSignal!.action),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            'Precio entrada: \$${_lastSignal!.entryPrice.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Stop Loss: \$${_lastSignal!.stopLoss.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.red),
          ),
          Text(
            'Confianza: ${_lastSignal!.confidence.toStringAsFixed(1)}/10',
            style: const TextStyle(color: Colors.white70),
          ),
          
          if (_lastSignal!.warning != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '⚠️ ${_lastSignal!.warning}',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentimentResult() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sentiment_very_satisfied, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Análisis de Sentiment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Símbolo: ${_lastSentiment!.symbol}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Sentiment: ${_lastSentiment!.overallSentiment.toUpperCase()}',
            style: TextStyle(
              color: _getSentimentColor(_lastSentiment!.overallSentiment),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Score: ${_lastSentiment!.sentimentScore.toStringAsFixed(1)}/10',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Impacto: ${_lastSentiment!.marketImpact.toUpperCase()}',
            style: const TextStyle(color: Colors.white70),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _lastSentiment!.summary,
            style: const TextStyle(
              color: Colors.purple,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de manejo de eventos
  Future<void> _configureApiKey(AIService aiService) async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showErrorSnackBar('Por favor ingrese una API key válida');
      return;
    }

    final success = await aiService.setApiKey(_apiKeyController.text.trim());
    
    if (success) {
      _showSuccessSnackBar('API key configurada correctamente');
      _apiKeyController.clear();
      setState(() {});
    } else {
      _showErrorSnackBar('Error al configurar API key. Verifique que sea válida.');
    }
  }

  Future<void> _performMarketAnalysis(AIService aiService) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Datos de ejemplo para demostración
      final priceData = [
        {'close': 43250.0, 'volume': 1234567, 'timestamp': DateTime.now().millisecondsSinceEpoch},
        {'close': 43180.0, 'volume': 1345678, 'timestamp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch},
      ];
      
      final technicalIndicators = {
        'rsi': 67.5,
        'macd': 125.3,
        'bollinger_upper': 44000.0,
        'bollinger_lower': 42500.0,
      };

      final analysis = await aiService.analyzeMarket(
        symbol: 'BTC/USDT',
        priceData: priceData,
        technicalIndicators: technicalIndicators,
        additionalContext: 'Análisis demo desde BINA-BOT PRO',
      );

      setState(() {
        _lastAnalysis = analysis;
        _isAnalyzing = false;
      });

      if (analysis == null) {
        _showErrorSnackBar('Error al realizar análisis de mercado');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _generateTradingSignal(AIService aiService) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final marketData = {
        'price': 43250.0,
        'volume': 1234567.0,
        'rsi': 67.5,
        'macd': 125.3,
        'trend': 'alcista',
      };

      final signal = await aiService.generateTradingSignal(
        symbol: 'BTC/USDT',
        marketData: marketData,
        timeframe: '1h',
        riskTolerance: 7.0,
      );

      setState(() {
        _lastSignal = signal;
        _isAnalyzing = false;
      });

      if (signal == null) {
        _showErrorSnackBar('Error al generar señal de trading');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _analyzeNewsSentiment(AIService aiService) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final newsArticles = [
        'Bitcoin alcanza nuevos máximos históricos tras adopción institucional',
        'Tesla anuncia inversión adicional en Bitcoin',
        'Reguladores aprueban ETF de Bitcoin en varios países',
      ];

      final sentiment = await aiService.analyzeNewsSentiment(
        newsArticles: newsArticles,
        symbol: 'BTC',
      );

      setState(() {
        _lastSentiment = sentiment;
        _isAnalyzing = false;
      });

      if (sentiment == null) {
        _showErrorSnackBar('Error al analizar sentiment de noticias');
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showServiceStatus(AIService aiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Estado del Servicio de IA', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado: ${aiService.isAvailable ? "✅ Operativo" : "❌ No disponible"}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              'Modelo: Mistral 8x7B (Groq Cloud)',
              style: TextStyle(color: Colors.white70),
            ),
            const Text(
              'Proveedor: Groq Inc.',
              style: TextStyle(color: Colors.white70),
            ),
            const Text(
              'Latencia: ~100-500ms',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Métodos helper para colores
  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'alcista':
        return Colors.green;
      case 'bajista':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getActionColor(String action) {
    switch (action.toLowerCase()) {
      case 'buy':
        return Colors.green;
      case 'sell':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'muy_positivo':
      case 'positivo':
        return Colors.green;
      case 'muy_negativo':
      case 'negativo':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
