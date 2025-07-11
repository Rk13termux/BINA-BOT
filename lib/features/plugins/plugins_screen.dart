import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../models/plugin.dart';
import '../../services/plugin_service.dart';
import '../../services/auth_service.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final PluginService _pluginService = PluginService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Plugin> _installedPlugins = [];
  List<Plugin> _availablePlugins = [];
  List<Plugin> _filteredInstalled = [];
  List<Plugin> _filteredAvailable = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlugins();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterPlugins();
    });
  }

  void _filterPlugins() {
    if (_searchQuery.isEmpty) {
      _filteredInstalled = _installedPlugins;
      _filteredAvailable = _availablePlugins;
    } else {
      _filteredInstalled = _installedPlugins
          .where((plugin) =>
              plugin.name.toLowerCase().contains(_searchQuery) ||
              plugin.description.toLowerCase().contains(_searchQuery))
          .toList();
      _filteredAvailable = _availablePlugins
          .where((plugin) =>
              plugin.name.toLowerCase().contains(_searchQuery) ||
              plugin.description.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  Future<void> _loadPlugins() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final installed = await _pluginService.getInstalledPlugins();
      final available = _generateAvailablePlugins();
      
      setState(() {
        _installedPlugins = installed;
        _availablePlugins = available;
        _filterPlugins();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plugins: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    }
  }

  List<Plugin> _generateAvailablePlugins() {
    // Simulate available plugins from marketplace
    return [
      Plugin(
        id: 'rsi_strategy',
        name: 'RSI Trading Strategy',
        version: '1.0.0',
        author: 'TradingBot Inc.',
        description: 'Advanced RSI-based trading strategy with customizable parameters',
        code: '',
        status: PluginStatus.available,
        permissions: ['trading', 'market_data'],
        category: 'Trading Strategy',
      ),
      Plugin(
        id: 'macd_indicator',
        name: 'MACD Indicator',
        version: '2.1.0',
        author: 'IndicatorPro',
        description: 'Professional MACD indicator with signal line crossovers',
        code: '',
        status: PluginStatus.available,
        permissions: ['market_data'],
        category: 'Indicator',
      ),
      Plugin(
        id: 'bollinger_bands',
        name: 'Bollinger Bands',
        version: '1.5.2',
        author: 'ChartAnalytics',
        description: 'Classic Bollinger Bands indicator for volatility analysis',
        code: '',
        status: PluginStatus.available,
        permissions: ['market_data'],
        category: 'Indicator',
      ),
      Plugin(
        id: 'fibonacci_retracement',
        name: 'Fibonacci Retracement',
        version: '1.2.1',
        author: 'TechnicalTools',
        description: 'Automatic Fibonacci retracement levels calculator',
        code: '',
        status: PluginStatus.available,
        permissions: ['market_data'],
        category: 'Tool',
      ),
      Plugin(
        id: 'volume_profile',
        name: 'Volume Profile',
        version: '3.0.0',
        author: 'VolumeAnalytics',
        description: 'Advanced volume profile analysis tool',
        code: '',
        status: PluginStatus.available,
        permissions: ['market_data'],
        category: 'Indicator',
      ),
      Plugin(
        id: 'smart_alerts',
        name: 'Smart Alerts System',
        version: '2.5.0',
        author: 'AlertMaster',
        description: 'AI-powered alert system with pattern recognition',
        code: '',
        status: PluginStatus.available,
        permissions: ['notifications', 'market_data'],
        category: 'Alert',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Plugins',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.goldPrimary),
            onPressed: _loadPlugins,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.goldPrimary),
            color: AppColors.surfaceDark,
            onSelected: (value) {
              switch (value) {
                case 'create':
                  _showCreatePluginDialog();
                  break;
                case 'import':
                  _importPlugin();
                  break;
                case 'settings':
                  _showPluginSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'create',
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppColors.goldPrimary),
                    const SizedBox(width: 8),
                    Text('Create Plugin', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: AppColors.goldPrimary),
                    const SizedBox(width: 8),
                    Text('Import Plugin', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.goldPrimary),
                    const SizedBox(width: 8),
                    Text('Plugin Settings', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search plugins...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppColors.goldPrimary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.goldPrimary),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                  ),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.goldPrimary,
                labelColor: AppColors.goldPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: [
                  Tab(text: 'Installed (${_filteredInstalled.length})'),
                  Tab(text: 'Available (${_filteredAvailable.length})'),
                  Tab(text: 'My Plugins'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInstalledTab(),
          _buildAvailableTab(),
          _buildMyPluginsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePluginDialog,
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInstalledTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrimary),
      );
    }

    if (_filteredInstalled.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No plugins installed' : 'No matching plugins',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty 
                  ? 'Browse available plugins to get started'
                  : 'Try a different search term',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredInstalled.length,
      itemBuilder: (context, index) {
        final plugin = _filteredInstalled[index];
        return _buildPluginCard(plugin, isInstalled: true);
      },
    );
  }

  Widget _buildAvailableTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrimary),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAvailable.length,
      itemBuilder: (context, index) {
        final plugin = _filteredAvailable[index];
        return _buildPluginCard(plugin, isInstalled: false);
      },
    );
  }

  Widget _buildMyPluginsTab() {
    final myPlugins = _filteredInstalled.where((p) => p.author == 'You').toList();

    if (myPlugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No custom plugins yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first custom plugin',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showCreatePluginDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create Plugin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPlugins.length,
      itemBuilder: (context, index) {
        final plugin = myPlugins[index];
        return _buildPluginCard(plugin, isInstalled: true, isOwned: true);
      },
    );
  }

  Widget _buildPluginCard(Plugin plugin, {required bool isInstalled, bool isOwned = false}) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(plugin.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(plugin.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              plugin.name,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isInstalled) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: plugin.isActive ? AppColors.success : AppColors.warning,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plugin.isActive ? 'ACTIVE' : 'INACTIVE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'v${plugin.version}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${plugin.author}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              plugin.category,
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plugin.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (plugin.permissions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plugin.permissions.map((permission) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Text(
                      permission,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (isInstalled) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _togglePlugin(plugin),
                      icon: Icon(plugin.isActive ? Icons.pause : Icons.play_arrow),
                      label: Text(plugin.isActive ? 'Deactivate' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plugin.isActive ? AppColors.warning : AppColors.success,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isOwned) ...[
                    IconButton(
                      onPressed: () => _editPlugin(plugin),
                      icon: Icon(Icons.edit, color: AppColors.goldPrimary),
                      tooltip: 'Edit',
                    ),
                  ],
                  IconButton(
                    onPressed: () => _configurePlugin(plugin),
                    icon: Icon(Icons.settings, color: AppColors.goldPrimary),
                    tooltip: 'Configure',
                  ),
                  IconButton(
                    onPressed: () => _uninstallPlugin(plugin),
                    icon: Icon(Icons.delete, color: AppColors.bearish),
                    tooltip: 'Uninstall',
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _installPlugin(plugin),
                      icon: const Icon(Icons.download),
                      label: const Text('Install'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showPluginDetails(plugin),
                    icon: Icon(Icons.info_outline, color: AppColors.goldPrimary),
                    tooltip: 'Details',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trading strategy':
        return AppColors.goldPrimary;
      case 'indicator':
        return AppColors.bullish;
      case 'tool':
        return AppColors.info;
      case 'alert':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'trading strategy':
        return Icons.trending_up;
      case 'indicator':
        return Icons.show_chart;
      case 'tool':
        return Icons.build;
      case 'alert':
        return Icons.notification_important;
      default:
        return Icons.extension;
    }
  }

  Future<void> _installPlugin(Plugin plugin) async {
    try {
      await _pluginService.installPlugin(plugin);
      await _loadPlugins();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.name} installed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install plugin: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    }
  }

  Future<void> _uninstallPlugin(Plugin plugin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Uninstall Plugin',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to uninstall "${plugin.name}"?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Uninstall', style: TextStyle(color: AppColors.bearish)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _pluginService.uninstallPlugin(plugin.id);
        await _loadPlugins();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${plugin.name} uninstalled'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to uninstall plugin: $e'),
              backgroundColor: AppColors.bearish,
            ),
          );
        }
      }
    }
  }

  Future<void> _togglePlugin(Plugin plugin) async {
    try {
      if (plugin.isActive) {
        await _pluginService.deactivatePlugin(plugin.id);
      } else {
        await _pluginService.activatePlugin(plugin.id);
      }
      await _loadPlugins();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle plugin: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    }
  }

  void _configurePlugin(Plugin plugin) {
    // TODO: Show plugin configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration for ${plugin.name} coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _editPlugin(Plugin plugin) {
    // TODO: Show plugin editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plugin editor for ${plugin.name} coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showPluginDetails(Plugin plugin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          plugin.name,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Version: ${plugin.version}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Author: ${plugin.author}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${plugin.category}',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                plugin.description,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (plugin.permissions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Permissions:',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...plugin.permissions.map((permission) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check, color: AppColors.goldPrimary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        permission,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  void _showCreatePluginDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Tool';
    final categories = ['Tool', 'Indicator', 'Trading Strategy', 'Alert'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            'Create New Plugin',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Plugin Name',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldPrimary),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.goldPrimary),
                    ),
                  ),
                  dropdownColor: AppColors.surfaceDark,
                  style: TextStyle(color: AppColors.textPrimary),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
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
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
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
      ),
    );
  }

  Future<void> _createPlugin(String name, String description, String category) async {
    try {
      await _pluginService.createPlugin(
        name: name,
        description: description,
        category: category,
        code: _getTemplateCode(category),
      );
      
      await _loadPlugins();
      
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

  String _getTemplateCode(String category) {
    switch (category.toLowerCase()) {
      case 'indicator':
        return '''
// Custom Indicator Template
class CustomIndicator {
  List<double> calculate(List<double> prices) {
    // Add your indicator calculation logic here
    return prices;
  }
}
''';
      case 'trading strategy':
        return '''
// Trading Strategy Template
class TradingStrategy {
  String generateSignal(Map<String, dynamic> marketData) {
    // Add your trading logic here
    // Return 'BUY', 'SELL', or 'HOLD'
    return 'HOLD';
  }
}
''';
      case 'alert':
        return '''
// Alert Plugin Template
class AlertPlugin {
  bool shouldAlert(Map<String, dynamic> data) {
    // Add your alert condition logic here
    return false;
  }
}
''';
      default:
        return '''
// Plugin Template
class Plugin {
  void execute() {
    // Add your plugin logic here
  }
}
''';
    }
  }

  void _importPlugin() {
    // TODO: Implement plugin import from file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Plugin import feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showPluginSettings() {
    // TODO: Show global plugin settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Plugin settings coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
