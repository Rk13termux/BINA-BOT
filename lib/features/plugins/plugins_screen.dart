import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/plugins/plugin_manager.dart';
import '../../services/plugins/trading_plugins.dart';
import '../../models/signal.dart';
import '../../ui/theme/colors.dart';

/// Pantalla de gestión de plugins de trading
class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _loadingController;
  late Animation<double> _rotationAnimation;
  
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializePluginManager();
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));

    _loadingController.repeat();
  }

  void _initializePluginManager() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pluginManager = Provider.of<PluginManager>(context, listen: false);
      pluginManager.startAnalysis();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPluginsTab(),
                _buildSignalsTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'PLUGIN MANAGER',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            _showOnlyActive ? Icons.visibility : Icons.visibility_off,
            color: AppColors.goldPrimary,
          ),
          onPressed: () {
            setState(() {
              _showOnlyActive = !_showOnlyActive;
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.goldPrimary),
          onSelected: (value) {
            switch (value) {
              case 'import':
                _importPlugin();
                break;
              case 'settings':
                _showPluginSettings();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.file_upload, color: AppColors.goldPrimary),
                  SizedBox(width: 8),
                  Text('Import Plugin'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.goldPrimary),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.goldPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'PLUGINS'),
          Tab(text: 'SIGNALS'),
          Tab(text: 'STATS'),
        ],
      ),
    );
  }

  Widget _buildPluginsTab() {
    return Consumer<PluginManager>(
      builder: (context, pluginManager, child) {
        if (pluginManager.isAnalyzing) {
          return _buildLoadingWidget();
        }

        final plugins = _showOnlyActive 
            ? pluginManager.activePlugins 
            : pluginManager.allPlugins;

        if (plugins.isEmpty) {
          return _buildEmptyState('No plugins available');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plugins.length,
          itemBuilder: (context, index) {
            final plugin = plugins[index];
            return _buildPluginCard(plugin);
          },
        );
      },
    );
  }

  Widget _buildSignalsTab() {
    return Consumer<PluginManager>(
      builder: (context, pluginManager, child) {
        final signals = pluginManager.getAllSignals();
        
        if (signals.isEmpty) {
          return _buildEmptyState('No signals generated yet');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: signals.length,
          itemBuilder: (context, index) {
            final signal = signals[index];
            return _buildSignalCard(signal);
          },
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<PluginManager>(
      builder: (context, pluginManager, child) {
        final stats = pluginManager.getStatistics();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatCard('Active Plugins', '${stats['activePlugins'] ?? 0}', Icons.extension),
              _buildStatCard('Total Signals', '${stats['totalSignals'] ?? 0}', Icons.show_chart),
              _buildStatCard('Success Rate', '${(stats['successRate'] ?? 0).toStringAsFixed(1)}%', Icons.trending_up),
              _buildStatCard('Average Confidence', '${(stats['avgConfidence'] ?? 0).toStringAsFixed(1)}%', Icons.psychology),
              const SizedBox(height: 20),
              _buildPerformanceChart(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPluginCard(TradingPlugin plugin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: plugin.isActive ? AppColors.bullish : AppColors.bearish,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPluginIcon(plugin.runtimeType.toString()),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plugin.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        plugin.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: plugin.isActive,
                  onChanged: (value) {
                    final pluginManager = Provider.of<PluginManager>(context, listen: false);
                    if (value) {
                      pluginManager.activatePlugin(plugin.name);
                    } else {
                      pluginManager.deactivatePlugin(plugin.name);
                    }
                  },
                  activeColor: AppColors.goldPrimary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildPluginMetric('Signals', '${plugin.totalSignals}'),
                _buildPluginMetric('Success', '${plugin.successRate.toStringAsFixed(1)}%'),
                _buildPluginMetric('Confidence', '${plugin.avgConfidence.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Config'),
                  onPressed: () => _configurePlugin(plugin),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.bar_chart, size: 16),
                  label: const Text('Stats'),
                  onPressed: () => _showPluginStats(plugin),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(Signal signal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSignalColor(signal.type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getSignalTypeText(signal.type),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  signal.symbol,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _getConfidenceText(signal.confidence),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getConfidenceColor(_getConfidenceString(signal.confidence)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              signal.reason,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Source: ${signal.source}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(signal.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.goldPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.goldPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Chart will be implemented with fl_chart',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPluginMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.goldPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value,
                child: const Icon(
                  Icons.refresh,
                  size: 48,
                  color: AppColors.goldPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Analyzing market data...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.extension_off,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCreatePluginDialog,
      backgroundColor: AppColors.goldPrimary,
      foregroundColor: AppColors.primaryDark,
      child: const Icon(Icons.add),
    );
  }

  // ===== MÉTODOS AUXILIARES =====

  IconData _getPluginIcon(String pluginType) {
    switch (pluginType) {
      case 'ScalpingPlugin':
        return Icons.flash_on;
      case 'SwingTradingPlugin':
        return Icons.trending_up;
      case 'LiquiditySniperPlugin':
        return Icons.gps_fixed;
      case 'GridAIPlugin':
        return Icons.grid_on;
      case 'NewsSentimentPlugin':
        return Icons.newspaper;
      default:
        return Icons.extension;
    }
  }

  // ===== MÉTODOS AUXILIARES ADICIONALES =====

  String _getSignalTypeText(SignalType signalType) {
    switch (signalType) {
      case SignalType.buy:
        return 'BUY';
      case SignalType.sell:
        return 'SELL';
      case SignalType.hold:
        return 'HOLD';
      case SignalType.warning:
        return 'WARNING';
    }
  }

  String _getConfidenceText(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.low:
        return '25%';
      case ConfidenceLevel.medium:
        return '50%';
      case ConfidenceLevel.high:
        return '75%';
      case ConfidenceLevel.veryHigh:
        return '95%';
    }
  }

  String _getConfidenceString(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.low:
        return 'low';
      case ConfidenceLevel.medium:
        return 'medium';
      case ConfidenceLevel.high:
        return 'high';
      case ConfidenceLevel.veryHigh:
        return 'veryhigh';
    }
  }

  Color _getSignalColor(SignalType signalType) {
    switch (signalType) {
      case SignalType.buy:
        return AppColors.bullish;
      case SignalType.sell:
        return AppColors.bearish;
      case SignalType.hold:
        return AppColors.neutral;
      case SignalType.warning:
        return AppColors.warning;
    }
  }

  void _configurePlugin(TradingPlugin plugin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${plugin.name}'),
        content: const Text('Plugin configuration coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPluginStats(TradingPlugin plugin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${plugin.name} Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total Signals', '${plugin.totalSignals}'),
            _buildStatRow('Success Rate', '${plugin.successRate.toStringAsFixed(1)}%'),
            _buildStatRow('Avg Confidence', '${plugin.avgConfidence.toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showCreatePluginDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Trading Strategy';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Plugin'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Plugin Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ['Trading Strategy', 'Indicator', 'Signal Processor']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty) {
                Navigator.pop(context);
                await _createPlugin(
                  nameController.text,
                  descriptionController.text,
                  selectedCategory,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlugin(
      String name, String description, String category) async {
    try {
      // Mock plugin creation - in real app would integrate with plugin service
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plugin "$name" created successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create plugin: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    }
  }

  void _importPlugin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plugin import feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showPluginSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plugin settings coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
