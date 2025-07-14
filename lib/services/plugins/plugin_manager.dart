import 'package:flutter/material.dart';
import 'dart:async';
import 'trading_plugins.dart';
import '../../models/candle.dart';
import '../../models/signal.dart';
import '../../utils/logger.dart';

/// Gestor centralizado de plugins de trading
class PluginManager extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  
  // Plugins registrados
  final Map<String, TradingPlugin> _plugins = {};
  final Map<String, bool> _pluginEnabled = {};
  final Map<String, StreamSubscription?> _pluginSubscriptions = {};
  
  // Resultados de análisis
  final Map<String, List<Signal>> _pluginSignals = {};
  final StreamController<Signal> _signalController = StreamController.broadcast();
  
  // Estado del manager
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  List<Candle> _lastCandles = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isAnalyzing => _isAnalyzing;
  Map<String, TradingPlugin> get plugins => Map.unmodifiable(_plugins);
  Map<String, bool> get pluginEnabled => Map.unmodifiable(_pluginEnabled);
  Map<String, List<Signal>> get pluginSignals => Map.unmodifiable(_pluginSignals);
  Stream<Signal> get signalStream => _signalController.stream;

  /// Inicializar el gestor con plugins por defecto
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('Inicializando Plugin Manager...');

    try {
      // Registrar plugins por defecto
      await _registerDefaultPlugins();
      
      _isInitialized = true;
      _logger.info('Plugin Manager inicializado con ${_plugins.length} plugins');
      notifyListeners();
    } catch (e) {
      _logger.error('Error inicializando Plugin Manager: $e');
      rethrow;
    }
  }

  /// Registrar plugins por defecto
  Future<void> _registerDefaultPlugins() async {
    // Plugin de Scalping Rápido
    await registerPlugin(ScalpingPlugin());
    
    // Plugin de Swing Trading
    await registerPlugin(SwingTradingPlugin());
    
    // Plugin de Liquidity Sniper
    await registerPlugin(LiquiditySniperPlugin());
    
    // Plugin de Grid AI (simulado)
    await registerPlugin(GridAIPlugin());
    
    // Plugin de News Sentiment (simulado)
    await registerPlugin(NewsSentimentPlugin());
  }

  /// Registrar un nuevo plugin
  Future<void> registerPlugin(TradingPlugin plugin) async {
    try {
      await plugin.initialize();
      _plugins[plugin.name] = plugin;
      _pluginEnabled[plugin.name] = true; // Habilitado por defecto
      _pluginSignals[plugin.name] = [];
      
      _logger.info('Plugin registrado: ${plugin.name} v${plugin.version}');
      notifyListeners();
    } catch (e) {
      _logger.error('Error registrando plugin ${plugin.name}: $e');
      rethrow;
    }
  }

  /// Desregistrar un plugin
  Future<void> unregisterPlugin(String pluginName) async {
    if (!_plugins.containsKey(pluginName)) return;

    try {
      _plugins[pluginName]?.dispose();
      _plugins.remove(pluginName);
      _pluginEnabled.remove(pluginName);
      _pluginSignals.remove(pluginName);
      _pluginSubscriptions[pluginName]?.cancel();
      _pluginSubscriptions.remove(pluginName);
      
      _logger.info('Plugin desregistrado: $pluginName');
      notifyListeners();
    } catch (e) {
      _logger.error('Error desregistrando plugin $pluginName: $e');
    }
  }

  /// Habilitar/deshabilitar un plugin
  void setPluginEnabled(String pluginName, bool enabled) {
    if (!_plugins.containsKey(pluginName)) return;

    _pluginEnabled[pluginName] = enabled;
    
    if (!enabled) {
      _pluginSignals[pluginName] = [];
    }
    
    _logger.info('Plugin $pluginName ${enabled ? 'habilitado' : 'deshabilitado'}');
    notifyListeners();
  }

  /// Analizar velas con todos los plugins habilitados
  Future<void> analyzeCandles(List<Candle> candles) async {
    if (!_isInitialized || candles.isEmpty) return;

    _isAnalyzing = true;
    _lastCandles = List.from(candles);
    notifyListeners();

    try {
      // Ejecutar análisis en paralelo para mejor rendimiento
      List<Future<void>> analyses = [];
      
      for (String pluginName in _plugins.keys) {
        if (_pluginEnabled[pluginName] == true) {
          analyses.add(_analyzeWithPlugin(pluginName, candles));
        }
      }
      
      await Future.wait(analyses);
      
      _logger.info('Análisis completado para ${analyses.length} plugins');
    } catch (e) {
      _logger.error('Error en análisis de plugins: $e');
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Analizar con un plugin específico
  Future<void> _analyzeWithPlugin(String pluginName, List<Candle> candles) async {
    try {
      final plugin = _plugins[pluginName];
      if (plugin == null) return;

      final signals = await plugin.analyze(candles);
      _pluginSignals[pluginName] = signals;
      
      // Emitir señales nuevas
      for (final signal in signals) {
        _signalController.add(signal);
      }
      
      _logger.debug('Plugin $pluginName generó ${signals.length} señales');
    } catch (e) {
      _logger.error('Error analizando con plugin $pluginName: $e');
      _pluginSignals[pluginName] = [];
    }
  }

  /// Obtener todas las señales activas
  List<Signal> getAllSignals() {
    List<Signal> allSignals = [];
    
    for (String pluginName in _plugins.keys) {
      if (_pluginEnabled[pluginName] == true) {
        allSignals.addAll(_pluginSignals[pluginName] ?? []);
      }
    }
    
    // Ordenar por timestamp (más recientes primero)
    allSignals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return allSignals;
  }

  /// Obtener señales de un plugin específico
  List<Signal> getPluginSignals(String pluginName) {
    return List.from(_pluginSignals[pluginName] ?? []);
  }

  /// Obtener estadísticas de plugins
  Map<String, PluginStats> getPluginStats() {
    Map<String, PluginStats> stats = {};
    
    for (String pluginName in _plugins.keys) {
      final signals = _pluginSignals[pluginName] ?? [];
      final buySignals = signals.where((s) => s.type == SignalType.buy).length;
      final sellSignals = signals.where((s) => s.type == SignalType.sell).length;
      final avgConfidence = signals.isEmpty 
          ? 0.0 
          : signals.map((s) => _confidenceLevelToDouble(s.confidence)).reduce((a, b) => a + b) / signals.length;
      
      stats[pluginName] = PluginStats(
        pluginName: pluginName,
        isEnabled: _pluginEnabled[pluginName] ?? false,
        totalSignals: signals.length,
        buySignals: buySignals,
        sellSignals: sellSignals,
        averageConfidence: avgConfidence,
        lastAnalysis: signals.isNotEmpty ? signals.last.timestamp : null,
      );
    }
    
    return stats;
  }

  /// Limpiar señales antiguas
  void clearOldSignals({Duration? maxAge}) {
    maxAge ??= const Duration(hours: 24);
    final cutoff = DateTime.now().subtract(maxAge);
    
    for (String pluginName in _pluginSignals.keys) {
      _pluginSignals[pluginName] = _pluginSignals[pluginName]!
          .where((signal) => signal.timestamp.isAfter(cutoff))
          .toList();
    }
    
    notifyListeners();
    _logger.info('Señales antiguas limpiadas (más de ${maxAge.inHours} horas)');
  }

  /// Re-analizar con configuración actualizada
  Future<void> reanalyze() async {
    if (_lastCandles.isNotEmpty) {
      await analyzeCandles(_lastCandles);
    }
  }

  /// Obtener configuración de un plugin
  Widget? getPluginConfiguration(String pluginName) {
    return _plugins[pluginName]?.getConfigurationWidget();
  }

  // ===== MÉTODOS FALTANTES PARA LA UI =====

  /// Lista de plugins activos
  List<TradingPlugin> get activePlugins {
    return _plugins.values.where((plugin) => plugin.isActive).toList();
  }

  /// Lista de todos los plugins
  List<TradingPlugin> get allPlugins {
    return _plugins.values.toList();
  }

  /// Iniciar análisis (método requerido por plugins_screen)
  void startAnalysis() {
    if (!_isInitialized) {
      initialize();
    }
    _isAnalyzing = true;
    notifyListeners();
    
    // Simular análisis en curso
    Timer(const Duration(seconds: 2), () {
      _isAnalyzing = false;
      notifyListeners();
    });
  }

  /// Activar un plugin
  void activatePlugin(String pluginName) {
    final plugin = _plugins[pluginName];
    if (plugin != null) {
      plugin.setActive(true);
      _pluginEnabled[pluginName] = true;
      _logger.info('Plugin $pluginName activated');
      notifyListeners();
    }
  }

  /// Desactivar un plugin
  void deactivatePlugin(String pluginName) {
    final plugin = _plugins[pluginName];
    if (plugin != null) {
      plugin.setActive(false);
      _pluginEnabled[pluginName] = false;
      _logger.info('Plugin $pluginName deactivated');
      notifyListeners();
    }
  }

  /// Obtener estadísticas generales
  Map<String, dynamic> getStatistics() {
    final activeCount = activePlugins.length;
    final totalSignals = getAllSignals().length;
    
    double avgConfidence = 0.0;
    double successRate = 0.0;
    
    if (totalSignals > 0) {
      final signals = getAllSignals();
      avgConfidence = signals.map((s) => s.confidence.index * 25.0).reduce((a, b) => a + b) / signals.length;
      successRate = 75.0; // Mock value
    }

    return {
      'activePlugins': activeCount,
      'totalSignals': totalSignals,
      'successRate': successRate,
      'avgConfidence': avgConfidence,
    };
  }

  /// Convierte ConfidenceLevel a double para cálculos
  double _confidenceLevelToDouble(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.low:
        return 25.0;
      case ConfidenceLevel.medium:
        return 50.0;
      case ConfidenceLevel.high:
        return 75.0;
      case ConfidenceLevel.veryHigh:
        return 95.0;
    }
  }

  @override
  void dispose() {
    // Cancelar suscripciones
    for (var subscription in _pluginSubscriptions.values) {
      subscription?.cancel();
    }
    
    // Limpiar plugins
    for (var plugin in _plugins.values) {
      plugin.dispose();
    }
    
    _signalController.close();
    _logger.info('Plugin Manager disposed');
    super.dispose();
  }
}

/// Estadísticas de un plugin
class PluginStats {
  final String pluginName;
  final bool isEnabled;
  final int totalSignals;
  final int buySignals;
  final int sellSignals;
  final double averageConfidence;
  final DateTime? lastAnalysis;

  PluginStats({
    required this.pluginName,
    required this.isEnabled,
    required this.totalSignals,
    required this.buySignals,
    required this.sellSignals,
    required this.averageConfidence,
    this.lastAnalysis,
  });

  double get buyRatio => totalSignals == 0 ? 0.0 : buySignals / totalSignals;
  double get sellRatio => totalSignals == 0 ? 0.0 : sellSignals / totalSignals;
}

/// Plugins adicionales simulados para completar el conjunto

/// Plugin de Grid AI
class GridAIPlugin extends TradingPlugin {
  @override
  String get name => 'Grid AI';

  @override
  String get description => 'Trading automático con grillas inteligentes y IA';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.grid_on;

  @override
  Color get color => const Color(0xFF2196F3);

  @override
  Map<String, dynamic> get parameters => {
    'gridLevels': 10,
    'gridSpacing': 0.5,
    'aiOptimization': true,
  };

  @override
  Future<void> initialize() async {
    AppLogger().info('Inicializando Grid AI Plugin v$version');
  }

  @override
  Future<List<Signal>> analyze(List<Candle> candles) async {
    // Simulación de análisis de grilla
    if (candles.length < 10) return [];
    
    List<Signal> signals = [];
    final latest = candles.last;
    
    // Simular señales de grilla cada cierto tiempo
    if (DateTime.now().millisecond % 100 < 10) {
      signals.add(Signal(
        id: 'grid_${latest.openTime.millisecondsSinceEpoch}',
        symbol: 'BTCUSDT',
        type: latest.close > latest.open ? SignalType.sell : SignalType.buy,
        price: latest.close,
        timestamp: latest.openTime,
        confidence: ConfidenceLevel.medium,
        reason: 'Grid AI strategy signal detected',
        source: name,
        metadata: {
          'grid_level': (latest.close / 1000).floor(),
          'ai_confidence': 0.75,
          'timeframe': '15m',
        },
      ));
    }
    
    return signals;
  }

  @override
  bool validateParameters(Map<String, dynamic> params) {
    return params.containsKey('gridLevels') && params['gridLevels'] > 0;
  }

  @override
  Widget getConfigurationWidget() {
    return const Text('Grid AI Config (En desarrollo)', 
        style: TextStyle(color: Colors.white70));
  }

  @override
  void dispose() {
    AppLogger().info('Disposing Grid AI Plugin');
  }
}

/// Plugin de News Sentiment
class NewsSentimentPlugin extends TradingPlugin {
  @override
  String get name => 'News Sentiment';

  @override
  String get description => 'Análisis de sentimiento de noticias crypto';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.sentiment_very_satisfied;

  @override
  Color get color => const Color(0xFF9C27B0);

  @override
  Map<String, dynamic> get parameters => {
    'sentimentThreshold': 0.7,
    'newsTimeout': 3600, // 1 hora
    'sources': ['coindesk', 'cointelegraph', 'bitcoinmagazine'],
  };

  @override
  Future<void> initialize() async {
    AppLogger().info('Inicializando News Sentiment Plugin v$version');
  }

  @override
  Future<List<Signal>> analyze(List<Candle> candles) async {
    // Simulación de análisis de sentimiento
    if (candles.length < 5) return [];
    
    List<Signal> signals = [];
    final latest = candles.last;
    
    // Simular señales basadas en sentimiento
    if (DateTime.now().second % 30 == 0) {
      final sentiment = (DateTime.now().millisecond / 1000); // 0-1
      
      if (sentiment > 0.7) {
        signals.add(Signal(
          id: 'sentiment_bullish_${latest.openTime.millisecondsSinceEpoch}',
          symbol: 'BTCUSDT',
          type: SignalType.buy,
          price: latest.close,
          timestamp: latest.openTime,
          confidence: doubleToConfidenceLevel(sentiment * 100),
          reason: 'Bullish news sentiment detected (${(sentiment * 100).toStringAsFixed(1)}%)',
          source: name,
          metadata: {
            'sentiment_score': sentiment,
            'news_count': 15,
            'bullish_ratio': 0.8,
            'timeframe': '1h',
          },
        ));
      } else if (sentiment < 0.3) {
        signals.add(Signal(
          id: 'sentiment_bearish_${latest.openTime.millisecondsSinceEpoch}',
          symbol: 'BTCUSDT',
          type: SignalType.sell,
          price: latest.close,
          timestamp: latest.openTime,
          confidence: doubleToConfidenceLevel((1 - sentiment) * 100),
          reason: 'Bearish news sentiment detected (${((1 - sentiment) * 100).toStringAsFixed(1)}%)',
          source: name,
          metadata: {
            'sentiment_score': sentiment,
            'news_count': 12,
            'bearish_ratio': 0.75,
            'timeframe': '1h',
          },
        ));
      }
    }
    
    return signals;
  }

  @override
  bool validateParameters(Map<String, dynamic> params) {
    return params.containsKey('sentimentThreshold') && 
           params['sentimentThreshold'] >= 0 && 
           params['sentimentThreshold'] <= 1;
  }

  @override
  Widget getConfigurationWidget() {
    return const Text('News Sentiment Config (En desarrollo)', 
        style: TextStyle(color: Colors.white70));
  }

  @override
  void dispose() {
    AppLogger().info('Disposing News Sentiment Plugin');
  }
}


