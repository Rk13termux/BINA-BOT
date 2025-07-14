import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_stream_service.dart';
import '../../services/plugins/plugin_manager.dart';
import '../../utils/logger.dart';

/// Pantalla principal simplificada de Invictus Trader Pro
class MainScreenSimple extends StatefulWidget {
  const MainScreenSimple({super.key});

  @override
  State<MainScreenSimple> createState() => _MainScreenSimpleState();
}

class _MainScreenSimpleState extends State<MainScreenSimple> {
  static final _logger = AppLogger();
  
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final dataStreamService = context.read<DataStreamService?>();
        final pluginManager = context.read<PluginManager?>();
        
        dataStreamService?.initialize();
        pluginManager?.initialize();
        
        _logger.info('Services initialized successfully');
      } catch (e) {
        _logger.error('Error initializing services: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'INVICTUS TRADER PRO',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildMainContent(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildTradingPage();
      case 2:
        return _buildAlertsPage();
      case 3:
        return _buildSettingsPage();
      default:
        return _buildDashboardPage();
    }
  }

  Widget _buildDashboardPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Dashboard Principal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.circle,
                  color: Color(0xFF4CAF50),
                  size: 12,
                ),
                SizedBox(width: 8),
                Text(
                  'ACTIVO',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          Expanded(
            child: Consumer2<DataStreamService, PluginManager>(
              builder: (context, dataService, pluginManager, _) {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatsCard(
                      title: 'Precio BTC',
                      value: '\$${dataService.currentPrice.toStringAsFixed(2)}',
                      icon: Icons.currency_bitcoin,
                      color: const Color(0xFFFFD700),
                    ),
                    _buildStatsCard(
                      title: 'Señales Activas',
                      value: '${pluginManager.getAllSignals().length}',
                      icon: Icons.show_chart,
                      color: const Color(0xFF4CAF50),
                    ),
                    _buildStatsCard(
                      title: 'Plugins Activos',
                      value: '${pluginManager.pluginEnabled.values.where((enabled) => enabled).length}',
                      icon: Icons.extension,
                      color: const Color(0xFF2196F3),
                    ),
                    _buildStatsCard(
                      title: 'Estado Stream',
                      value: dataService.isRunning ? 'CONECTADO' : 'DESCONECTADO',
                      icon: Icons.stream,
                      color: dataService.isRunning 
                          ? const Color(0xFF4CAF50) 
                          : const Color(0xFFFF5722),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTradingPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 64,
            color: Color(0xFF4CAF50),
          ),
          SizedBox(height: 16),
          Text(
            'Panel de Trading',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications,
            size: 64,
            color: Color(0xFFFF9800),
          ),
          SizedBox(height: 16),
          Text(
            'Sistema de Alertas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Próximamente disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          ListTile(
            leading: const Icon(Icons.api, color: Color(0xFFFFD700)),
            title: const Text(
              'Configurar APIs',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Binance y Groq AI',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // TODO: Navigate to API config
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.extension, color: Color(0xFF2196F3)),
            title: const Text(
              'Gestionar Plugins',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Activar/desactivar estrategias',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              // TODO: Navigate to plugins
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF9C27B0)),
            title: const Text(
              'Acerca de',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Invictus Trader Pro v1.0.0',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF2A2A2A),
      selectedItemColor: const Color(0xFFFFD700),
      unselectedItemColor: Colors.white70,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Trading',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Alertas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Config',
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Invictus Trader Pro',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Text(
          'Plataforma profesional de trading de criptomonedas con IA integrada.\n\nVersión: 1.0.0\nDesarrollado por: Invictus Team',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
