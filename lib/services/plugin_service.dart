import 'dart:async';
import 'dart:io';
import 'package:dart_eval/dart_eval.dart';
import 'package:path_provider/path_provider.dart';
import '../models/plugin.dart';
import '../models/signal.dart';
import '../utils/logger.dart';

class PluginService {
  static final PluginService _instance = PluginService._internal();
  static final AppLogger _logger = AppLogger();

  factory PluginService() => _instance;

  PluginService._internal();

  final Map<String, Plugin> _loadedPlugins = {};
  final Map<String, Runtime> _runtimes = {};
  bool _isInitialized = false;

  /// Initialize plugin service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _createPluginDirectories();
      await _loadInstalledPlugins();
      _isInitialized = true;
      _logger.info('Plugin service initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize plugin service: $e');
    }
  }

  /// Create necessary plugin directories
  Future<void> _createPluginDirectories() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pluginDir = Directory('${appDir.path}/plugins');

    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
      _logger.info('Plugin directory created');
    }
  }

  /// Load all installed plugins
  Future<void> _loadInstalledPlugins() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pluginDir = Directory('${appDir.path}/plugins');

      if (!await pluginDir.exists()) return;

      await for (final entity in pluginDir.list()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _loadPlugin(entity);
        }
      }

      _logger.info('Loaded ${_loadedPlugins.length} plugins');
    } catch (e) {
      _logger.error('Failed to load plugins: $e');
    }
  }

  /// Load a single plugin file
  Future<void> _loadPlugin(File pluginFile) async {
    try {
      final pluginCode = await pluginFile.readAsString();
      final pluginName = _extractPluginName(pluginFile.path);

      // For demo purposes, we'll skip runtime creation for now
      // final runtime = Runtime.ofCode(pluginCode);

      // Basic plugin validation
      if (_validatePluginCode(pluginCode)) {
        final plugin = Plugin(
          id: pluginName,
          name: pluginName,
          version: '1.0.0',
          description: 'Custom trading plugin',
          author: 'User',
          type: PluginType.strategy,
          createdAt: DateTime.now(),
          code: pluginCode,
          category: PluginCategory.trading,
          configuration: {'code': pluginCode, 'filePath': pluginFile.path},
        );

        _loadedPlugins[pluginName] = plugin;
        // _runtimes[pluginName] = runtime;

        _logger.info('Plugin loaded: $pluginName');
      } else {
        _logger.warning('Invalid plugin code: $pluginName');
      }
    } catch (e) {
      _logger.error('Failed to load plugin ${pluginFile.path}: $e');
    }
  }

  /// Extract plugin name from file path
  String _extractPluginName(String filePath) {
    return filePath.split('/').last.replaceAll('.dart', '');
  }

  /// Basic validation of plugin code
  bool _validatePluginCode(String code) {
    // Basic checks for security and structure
    final forbiddenKeywords = [
      'import \'dart:io\'',
      'import \'dart:ffi\'',
      'Process.run'
    ];

    for (final keyword in forbiddenKeywords) {
      if (code.contains(keyword)) {
        return false;
      }
    }

    // Should contain basic plugin structure
    return code.contains('analyzeMarket') || code.contains('generateSignal');
  }

  /// Install a new plugin
  Future<bool> installPlugin({
    required String name,
    required String code,
    required String description,
    required String author,
  }) async {
    try {
      if (!_validatePluginCode(code)) {
        _logger.error('Plugin validation failed: $name');
        return false;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final pluginFile = File('${appDir.path}/plugins/$name.dart');

      await pluginFile.writeAsString(code);

      final plugin = Plugin(
        id: name,
        name: name,
        version: '1.0.0',
        description: description,
        author: author,
        type: PluginType.strategy,
        createdAt: DateTime.now(),
        code: code,
        category: PluginCategory.trading,
        configuration: {'code': code, 'filePath': pluginFile.path},
      );

      _loadedPlugins[name] = plugin;

      // Create runtime for the new plugin (disabled for demo)
      // try {
      //   final runtime = Runtime.ofFile(pluginFile);
      //   _runtimes[name] = runtime;
      // } catch (e) {
      //   _logger.warning('Failed to create runtime for plugin $name: $e');
      // }

      _logger.info('Plugin installed: $name');
      return true;
    } catch (e) {
      _logger.error('Failed to install plugin $name: $e');
      return false;
    }
  }

  /// Remove a plugin
  Future<bool> removePlugin(String pluginId) async {
    try {
      final plugin = _loadedPlugins[pluginId];
      if (plugin == null) return false;

      // Remove file
      final filePath = plugin.configuration['filePath'] as String?;
      if (filePath == null) return false;

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Remove from memory
      _loadedPlugins.remove(pluginId);
      _runtimes.remove(pluginId);

      _logger.info('Plugin removed: $pluginId');
      return true;
    } catch (e) {
      _logger.error('Failed to remove plugin $pluginId: $e');
      return false;
    }
  }

  /// Enable/disable a plugin
  Future<void> togglePlugin(String pluginId, bool enabled) async {
    final plugin = _loadedPlugins[pluginId];
    if (plugin != null) {
      _loadedPlugins[pluginId] = plugin.copyWith(
          status: enabled ? PluginStatus.active : PluginStatus.inactive);
      _logger.info('Plugin $pluginId ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// Execute plugin analysis
  Future<List<Signal>> executePluginAnalysis(
      String symbol, Map<String, dynamic> marketData) async {
    final signals = <Signal>[];

    for (final entry in _loadedPlugins.entries) {
      final plugin = entry.value;
      if (plugin.status != PluginStatus.active) continue;

      try {
        final runtime = _runtimes[entry.key];
        if (runtime == null) continue;

        // Execute plugin code safely
        final result = await _executePluginSafely(runtime, symbol, marketData);
        if (result != null) {
          signals.addAll(result);
        }
      } catch (e) {
        _logger.error('Plugin ${plugin.name} execution failed: $e');
      }
    }

    return signals;
  }

  /// Safely execute plugin code
  Future<List<Signal>?> _executePluginSafely(
      Runtime runtime, String symbol, Map<String, dynamic> marketData) async {
    try {
      // This is a simplified version - in practice, you'd need more sophisticated
      // sandboxing and error handling

      // Create a mock signal for demonstration
      final signal = Signal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        type: SignalType.hold, // Default to hold
        price: marketData['price']?.toDouble() ?? 0.0,
        confidence: ConfidenceLevel.medium,
        reason: 'Plugin analysis',
        timestamp: DateTime.now(),
        metadata: marketData,
        source: 'plugin',
      );

      return [signal];
    } catch (e) {
      _logger.error('Plugin execution error: $e');
      return null;
    }
  }

  /// Get all loaded plugins
  List<Plugin> getLoadedPlugins() {
    return _loadedPlugins.values.toList();
  }

  /// Get enabled plugins
  List<Plugin> getEnabledPlugins() {
    return _loadedPlugins.values
        .where((plugin) => plugin.status == PluginStatus.active)
        .toList();
  }

  /// Get plugin by ID
  Plugin? getPlugin(String pluginId) {
    return _loadedPlugins[pluginId];
  }

  /// Get all installed plugins
  Future<List<Plugin>> getInstalledPlugins() async {
    if (!_isInitialized) await initialize();
    return _loadedPlugins.values.toList();
  }

  /// Install a plugin from Plugin object
  Future<bool> installPluginFromObject(Plugin plugin) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pluginFile = File('${appDir.path}/plugins/${plugin.id}.json');
      await pluginFile.writeAsString(plugin.toJson().toString());

      _loadedPlugins[plugin.id] = plugin;
      _logger.info('Plugin ${plugin.name} installed successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to install plugin ${plugin.name}: $e');
      return false;
    }
  }

  /// Uninstall a plugin
  Future<bool> uninstallPlugin(String pluginId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final pluginFile = File('${appDir.path}/plugins/$pluginId.json');

      if (await pluginFile.exists()) {
        await pluginFile.delete();
      }

      _loadedPlugins.remove(pluginId);
      _runtimes.remove(pluginId);

      _logger.info('Plugin $pluginId uninstalled successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to uninstall plugin $pluginId: $e');
      return false;
    }
  }

  /// Activate a plugin
  Future<bool> activatePlugin(String pluginId) async {
    try {
      final plugin = _loadedPlugins[pluginId];
      if (plugin == null) return false;

      final updatedPlugin = plugin.copyWith(status: PluginStatus.active);
      _loadedPlugins[pluginId] = updatedPlugin;

      _logger.info('Plugin ${plugin.name} activated');
      return true;
    } catch (e) {
      _logger.error('Failed to activate plugin $pluginId: $e');
      return false;
    }
  }

  /// Deactivate a plugin
  Future<bool> deactivatePlugin(String pluginId) async {
    try {
      final plugin = _loadedPlugins[pluginId];
      if (plugin == null) return false;

      final updatedPlugin = plugin.copyWith(status: PluginStatus.inactive);
      _loadedPlugins[pluginId] = updatedPlugin;

      _logger.info('Plugin ${plugin.name} deactivated');
      return true;
    } catch (e) {
      _logger.error('Failed to deactivate plugin $pluginId: $e');
      return false;
    }
  }

  /// Create a new plugin
  Future<Plugin> createPlugin(
      String name, String description, String code, PluginType type) async {
    final plugin = Plugin(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      version: '1.0.0',
      type: type,
      author: 'User',
      createdAt: DateTime.now(),
      code: code,
      category: PluginCategory.trading,
      permissions: [PluginPermission.readMarketData],
    );

    await installPluginFromObject(plugin);
    return plugin;
  }

  /// Create a sample plugin template
  String getPluginTemplate() {
    return '''
/// Sample Trading Plugin
/// This plugin analyzes market data and generates trading signals

class SampleTradingPlugin {
  
  /// Analyze market data and generate signals
  List<Map<String, dynamic>> analyzeMarket(String symbol, Map<String, dynamic> data) {
    final signals = <Map<String, dynamic>>[];
    
    try {
      final price = data['price'] as double;
      final volume = data['volume'] as double;
      final rsi = data['rsi'] as double?;
      
      // Simple RSI-based signal
      if (rsi != null) {
        if (rsi < 30) {
          signals.add({
            'type': 'buy',
            'confidence': 'high',
            'reason': 'RSI oversold (< 30)',
            'price': price,
          });
        } else if (rsi > 70) {
          signals.add({
            'type': 'sell',
            'confidence': 'high',
            'reason': 'RSI overbought (> 70)',
            'price': price,
          });
        }
      }
      
      // Volume analysis
      if (volume > 1000000) {
        signals.add({
          'type': 'warning',
          'confidence': 'medium',
          'reason': 'High volume detected',
          'price': price,
        });
      }
      
    } catch (e) {
      print('Plugin error: \$e');
    }
    
    return signals;
  }
}
''';
  }

  /// Validate plugin before installation
  bool validatePlugin(String code) {
    return _validatePluginCode(code);
  }

  /// Get plugin statistics
  Map<String, dynamic> getPluginStats() {
    final totalPlugins = _loadedPlugins.length;
    final enabledPlugins = _loadedPlugins.values
        .where((p) => p.status == PluginStatus.active)
        .length;

    return {
      'total': totalPlugins,
      'enabled': enabledPlugins,
      'disabled': totalPlugins - enabledPlugins,
    };
  }
}
