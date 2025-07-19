import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/ai_analysis.dart';
import '../models/candle.dart';
import '../services/binance_service.dart';
import '../services/groq_service.dart';
import '../utils/logger.dart';

class AIAssistantService extends ChangeNotifier {
  final AppLogger _logger = AppLogger();
  final GroqService _groqService;
  final BinanceService _binanceService;

  final List<ChatMessage> _conversationHistory = [];
  AIAnalysis? _currentMarketAnalysis;

  AIAssistantService({
    required GroqService groqService,
    required BinanceService binanceService,
  })  : _groqService = groqService,
        _binanceService = binanceService {
    _initializeSystemPrompt();
  }

  /// Obtiene el historial de la conversación.
  List<ChatMessage> get history => _conversationHistory;
  AIAnalysis? get currentMarketAnalysis => _currentMarketAnalysis;

  /// Inicializa la conversación con las instrucciones del sistema.
  void _initializeSystemPrompt() {
    const systemMessage = '''
    Eres 'Invictus AI', un asistente de trading experto, analítico y motivador. 
    Tu especialidad es el análisis de portafolios de criptomonedas y el análisis técnico de mercado. 
    Tu tono debe ser profesional pero accesible. 
    NUNCA des consejos financieros directos como "compra X" o "vende Y". 
    En su lugar, ofrece análisis, resalta riesgos, muestra oportunidades potenciales y educa al usuario. 
    Siempre debes recordarle al usuario que el trading conlleva riesgos y que debe hacer su propia investigación.
    ''';
    _conversationHistory.add(ChatMessage(role: 'system', content: systemMessage));
  }

  /// Envía un mensaje del usuario y obtiene una respuesta del asistente.
  Future<String> sendMessage(String userMessage) async {
    _logger.info('AI Assistant: Received user message.');
    try {
      // 1. Añadir el mensaje del usuario al historial
      _conversationHistory.add(ChatMessage(content: userMessage, role: 'user'));

      // 2. Recopilar contexto del portafolio
      final portfolioContext = await _getPortfolioContext();
      
      // 3. Crear una lista de mensajes para enviar a Groq (incluyendo el contexto)
      final messagesForApi = [
        _conversationHistory.first, // System prompt
        ChatMessage(role: 'system', content: '[DATOS DEL PORTAFOLIO DEL USUARIO - EN TIEMPO REAL]\n$portfolioContext'),
        ..._conversationHistory.where((msg) => msg.role == 'user' || msg.role != 'user') // Historial de chat
      ];

      // 4. Llamar a Groq
      final assistantResponse = await _groqService.getChatCompletion(messages: messagesForApi);

      // 5. Añadir la respuesta del asistente al historial
      _conversationHistory.add(ChatMessage(content: assistantResponse, role: 'assistant'));

      _logger.info('AI Assistant: Successfully generated and stored response.');
      return assistantResponse;

    } catch (e) {
      _logger.error('AI Assistant Error: $e');
      // Si falla, elimina el último mensaje del usuario para que pueda intentarlo de nuevo
      _conversationHistory.removeLast();
      rethrow; // Lanza el error para que la UI pueda mostrarlo
    }
  }

  /// Recopila y formatea los datos del portafolio del usuario.
  Future<String> _getPortfolioContext() async {
    _logger.info('Fetching portfolio context for AI...');
    try {
      final accountInfo = await _binanceService.getAccountInfo();
      final balances = accountInfo.balances.where((b) => b.free > 0).toList();
      final openOrders = await _binanceService.getOpenOrders();
      final totalBalanceUSDT = await _binanceService.getTotalBalanceUSDT();

      if (balances.isEmpty) {
        return 'El usuario no tiene actualmente ningún activo en su billetera.';
      }

      final portfolioSummary = StringBuffer();
      portfolioSummary.writeln('Saldo Total Estimado en USDT: ${totalBalanceUSDT.toStringAsFixed(2)}');
      portfolioSummary.writeln('Asignación del Portafolio:');
      for (var balance in balances) {
        portfolioSummary.writeln('- ${balance.asset}: ${balance.free.toStringAsFixed(6)}');
      }

      if (openOrders.isNotEmpty) {
        portfolioSummary.writeln('\nÓrdenes Abiertas:');
        for (var order in openOrders) {
          portfolioSummary.writeln('- ${order.side} ${order.symbol}: ${order.origQty} @ ${order.price}');
        }
      }

      return portfolioSummary.toString();
    } catch (e) {
      _logger.warning('Could not fetch full portfolio context: $e');
      return 'No se pudo obtener el contexto completo del portafolio. La información puede ser limitada.';
    }
  }

  /// Analiza el mercado para un símbolo y período de tiempo dados.
  Future<AIAnalysis?> analyzeMarket({
    required String symbol,
    required String interval,
    int limit = 100,
  }) async {
    _logger.info('AI Assistant: Analyzing market for $symbol ($interval)...');
    try {
      // Obtener datos de velas
      final List<Candle> candles = await _binanceService.getCandles(
        symbol: symbol,
        interval: interval,
        limit: limit,
      );

      if (candles.isEmpty) {
        _logger.warning('No candle data available for $symbol ($interval).');
        return null;
      }

      // Obtener estadísticas de 24h
      final Map<String, dynamic> ticker24hr = await _binanceService.get24hrTicker(symbol);

      // Recopilar contexto del portafolio
      final portfolioContext = await _getPortfolioContext();

      // Construir el prompt para el análisis de mercado
      final marketAnalysisPrompt = _buildMarketAnalysisPrompt(
        symbol,
        interval,
        candles,
        ticker24hr,
        portfolioContext,
      );

      // Enviar a Groq para análisis
      final List<ChatMessage> messages = [
        ChatMessage(role: 'system', content: _getMarketAnalysisSystemPrompt()),
        ChatMessage(role: 'user', content: marketAnalysisPrompt),
      ];

      final String rawAIResponse = await _groqService.getChatCompletion(messages: messages);

      // Parsear la respuesta de la IA
      _currentMarketAnalysis = _parseAIAnalysisResponse(rawAIResponse, symbol, interval);
      _logger.info('AI market analysis completed for $symbol.');
      return _currentMarketAnalysis;
    } catch (e) {
      _logger.error('Error during AI market analysis: $e');
      return null;
    }
  }

  /// Construye el prompt para el análisis de mercado.
  String _buildMarketAnalysisPrompt(
    String symbol,
    String interval,
    List<Candle> candles,
    Map<String, dynamic> ticker24hr,
    String portfolioContext,
  ) {
    final StringBuffer prompt = StringBuffer();
    prompt.writeln('Realiza un análisis técnico y fundamental exhaustivo para $symbol en el intervalo de $interval.');
    prompt.writeln('Considera los siguientes datos de velas (últimas ${candles.length}):');
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];
      prompt.writeln('  Candle ${i + 1}: Open=${candle.open}, High=${candle.high}, Low=${candle.low}, Close=${candle.close}, Volume=${candle.volume}');
    }
    prompt.writeln('\nEstadísticas de 24 horas:');
    ticker24hr.forEach((key, value) {
      prompt.writeln('  $key: $value');
    });
    prompt.writeln('\nContexto del Portafolio del Usuario:\n$portfolioContext');
    prompt.writeln('\nBasado en estos datos, proporciona:');
    prompt.writeln('1. Una recomendación clara (COMPRAR FUERTE, COMPRAR, MANTENER, VENDER, VENDER FUERTE).');
    prompt.writeln('2. Un nivel de confianza para tu recomendación (en porcentaje).');
    prompt.writeln('3. Un resumen breve del análisis.');
    prompt.writeln('4. Un razonamiento completo que justifique tu recomendación, incluyendo factores técnicos y fundamentales.');
    prompt.writeln('5. Factores clave que influyen en tu análisis.');
    prompt.writeln('6. Un precio objetivo estimado y un nivel de stop-loss sugerido.');
    prompt.writeln('7. El modelo de IA utilizado (llama3-8b-8192).');
    prompt.writeln('8. Un mensaje motivacional personalizado para el usuario.');
    prompt.writeln('\nFormato de respuesta JSON requerido:');
    prompt.writeln('''
{
  "recommendation": "[COMPRAR FUERTE|COMPRAR|MANTENER|VENDER|VENDER FUERTE]",
  "confidence": [0-100],
  "briefSummary": "[Resumen breve]",
  "fullReasoning": "[Razonamiento completo]",
  "keyFactors": ["Factor 1", "Factor 2"],
  "estimatedPriceTarget": [precio],
  "stopLossLevel": [precio],
  "motivation": "[Mensaje motivacional]",
  "model": "llama3-8b-8192"
}
''');
    return prompt.toString();
  }

  /// Prompt del sistema para análisis de mercado.
  String _getMarketAnalysisSystemPrompt() {
    return '''
    Eres 'Invictus AI', un asistente de trading experto, analítico y motivador. 
    Tu especialidad es el análisis de portafolios de criptomonedas y el análisis técnico de mercado. 
    Tu tono debe ser profesional pero accesible. 
    NUNCA des consejos financieros directos como "compra X" o "vende Y". 
    En su lugar, ofrece análisis, resalta riesgos, muestra oportunidades potenciales y educa al usuario. 
    Siempre debes recordarle al usuario que el trading conlleva riesgos y que debe hacer su propia investigación.
    Debes responder estrictamente en el formato JSON especificado por el usuario.
    ''';
  }

  /// Parsea la respuesta JSON de la IA en un objeto AIAnalysis.
  AIAnalysis _parseAIAnalysisResponse(String rawResponse, String symbol, String interval) {
    try {
      final jsonStart = rawResponse.indexOf('{');
      final jsonEnd = rawResponse.lastIndexOf('}') + 1;
      String jsonString = rawResponse;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        jsonString = rawResponse.substring(jsonStart, jsonEnd);
      }

      final Map<String, dynamic> data = json.decode(jsonString);

      return AIAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        recommendation: AIRecommendation.values.firstWhere(
          (e) => e.displayName == data['recommendation'],
          orElse: () => AIRecommendation.hold,
        ),
        confidence: ConfidenceLevel.values.firstWhere(
          (e) => e.level == (data['confidence'] as num).toInt() ~/ 20 + 1, // Convert 0-100 to 1-5 stars
          orElse: () => ConfidenceLevel.medium,
        ),
        briefSummary: data['briefSummary'] ?? '',
        fullReasoning: data['fullReasoning'] ?? '',
        keyFactors: List<String>.from(data['keyFactors'] ?? []),
        technicalData: {},
        estimatedPriceTarget: (data['estimatedPriceTarget'] as num?)?.toDouble() ?? 0.0,
        stopLossLevel: (data['stopLossLevel'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
        analysisTime: Duration.zero, // Placeholder
        model: data['model'] ?? 'llama3-8b-8192',
      );
    } catch (e) {
      _logger.error('Error parsing AI analysis response: $e');
      return AIAnalysis(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        recommendation: AIRecommendation.hold,
        confidence: ConfidenceLevel.medium,
        briefSummary: 'Error al analizar la respuesta de la IA.',
        fullReasoning: 'Hubo un problema al procesar la respuesta del modelo de IA. Por favor, inténtalo de nuevo.',
        keyFactors: [],
        technicalData: {},
        estimatedPriceTarget: 0.0,
        stopLossLevel: 0.0,
        timestamp: DateTime.now(),
        analysisTime: Duration.zero,
        model: 'llama3-8b-8192',
      );
    }
  }

  /// Limpia el historial de la conversación.
  void clearConversation() {
    _logger.info('Clearing AI conversation history.');
    _conversationHistory.clear();
    _initializeSystemPrompt();
  }
}