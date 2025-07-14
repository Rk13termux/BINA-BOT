import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/main_dashboard/indicators_board.dart';
import '../../features/api_config/api_config_screen.dart';
import '../../features/plugins/plugins_screen.dart';
import '../../ui/widgets/orbital_menu.dart';
import '../../services/data_stream_service.dart';
import '../../services/plugins/plugin_manager.dart';
import '../../utils/logger.dart';

/// Pantalla principal de Invictus Trader Pro
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  
  static final _logger = AppLogger();
  
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  int _selectedIndex = 0;
  bool _showOrbitalMenu = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));
    
    _backgroundController.repeat();
  }

  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Inicializar servicios
        final dataStreamService = context.read<DataStreamService?>();
        final pluginManager = context.read<PluginManager?>();
        
        dataStreamService?.initialize();
        pluginManager?.initialize();
      } catch (e) {
        _logger.error('Error initializing services: $e');
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Fondo animado
          _buildAnimatedBackground(),
          
          // Contenido principal
          _buildMainContent(),
          
          // Menú orbital flotante
          if (_showOrbitalMenu) _buildOrbitalMenu(),
          
          // Barra de estado superior
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.5 + 0.3 * _backgroundAnimation.value,
                0.5 + 0.2 * _backgroundAnimation.value,
              ),
              radius: 1.5,
              colors: [
                const Color(0xFFFFD700).withValues(alpha: 0.05),
                const Color(0xFF1A1A1A).withValues(alpha: 0.95),
                Colors.black,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardPage(),
          _buildTradingPage(),
          _buildAlertsPage(),
          _buildNewsPage(),
          _buildSettingsPage(),
        ],
      ),
    );
  }

  Widget _buildDashboardPage() {
    return const IndicatorsBoard();
  }

  Widget _buildTradingPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up,
            size: 80,
            color: const Color(0xFF4CAF50).withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          const Text(
            'MÓDULO DE TRADING',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente: Trading en tiempo real con Binance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToApiConfig(),
            icon: const Icon(Icons.settings),
            label: const Text('CONFIGURAR APIS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active,
            size: 80,
            color: const Color(0xFFFF9800).withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          const Text(
            'SISTEMA DE ALERTAS',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente: Alertas inteligentes con IA',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Consumer<PluginManager>(
            builder: (context, manager, _) {
              final signals = manager.getAllSignals();
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${signals.length}',
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Señales Activas',
                      style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 80,
            color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          const Text(
            'NOTICIAS CRYPTO',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Próximamente: Análisis de sentimiento de noticias',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildNewsPreview(),
        ],
      ),
    );
  }

  Widget _buildNewsPreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Bitcoin alcanza nuevo máximo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Regulación crypto en discusión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nuevas adopciones institucionales',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'CONFIGURACIÓN',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          _buildSettingsSection(
            'APIs y Conexiones',
            [
              _buildSettingsItem(
                'Configurar APIs',
                'Binance, Groq AI y otros servicios',
                Icons.api,
                () => _navigateToApiConfig(),
              ),
              _buildSettingsItem(
                'Estado de Conexiones',
                'Verificar conectividad',
                Icons.wifi,
                () => _showConnectionStatus(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsSection(
            'Plugins y Estrategias',
            [
              _buildSettingsItem(
                'Gestionar Plugins',
                'Activar/desactivar estrategias',
                Icons.extension,
                () => _navigateToPlugins(),
              ),
              _buildSettingsItem(
                'Crear Plugin',
                'Desarrollar estrategia personalizada',
                Icons.code,
                () => _createCustomPlugin(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsSection(
            'Interfaz',
            [
              _buildSettingsItem(
                'Menú Orbital',
                'Mostrar/ocultar menú flotante',
                Icons.radio_button_checked,
                () => _toggleOrbitalMenu(),
                trailing: Switch(
                  value: _showOrbitalMenu,
                  onChanged: (value) => _toggleOrbitalMenu(),
                  activeColor: const Color(0xFFFFD700),
                ),
              ),
              _buildSettingsItem(
                'Tema',
                'Personalizar colores y apariencia',
                Icons.palette,
                () => _showThemeSettings(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _buildSettingsSection(
            'Acerca de',
            [
              _buildSettingsItem(
                'Invictus Trader Pro',
                'Versión 1.0.0 - Professional',
                Icons.info,
                () => _showAbout(),
              ),
              _buildSettingsItem(
                'Soporte',
                'Documentación y ayuda',
                Icons.help,
                () => _showSupport(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: Color(0xFFFFD700),
      ),
      onTap: onTap,
    );
  }

  Widget _buildOrbitalMenu() {
    return Positioned(
      right: 20,
      bottom: 100,
      child: InvictusOrbitalMenu.create(
        onItemTap: (index) => _handleOrbitalMenuTap(index),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              const Text(
                'INVICTUS TRADER PRO',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Consumer<DataStreamService>(
                builder: (context, service, _) {
                  return Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: service.isRunning 
                              ? const Color(0xFF4CAF50) 
                              : const Color(0xFFFF5722),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        service.isRunning ? 'CONECTADO' : 'DESCONECTADO',
                        style: TextStyle(
                          color: service.isRunning 
                              ? const Color(0xFF4CAF50) 
                              : const Color(0xFFFF5722),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === MÉTODOS DE NAVEGACIÓN Y FUNCIONALIDAD ===

  void _handleOrbitalMenuTap(int index) {
    switch (index) {
      case 0: // Dashboard
        setState(() => _selectedIndex = 0);
        break;
      case 1: // Trading
        setState(() => _selectedIndex = 1);
        break;
      case 2: // Alertas
        setState(() => _selectedIndex = 2);
        break;
      case 3: // Noticias
        setState(() => _selectedIndex = 3);
        break;
      case 4: // Plugins
        _navigateToPlugins();
        break;
      case 5: // Configuración
        setState(() => _selectedIndex = 4);
        break;
    }
  }

  void _navigateToApiConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ApiConfigScreen()),
    );
  }

  void _navigateToPlugins() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PluginsScreen()),
    );
  }

  void _toggleOrbitalMenu() {
    setState(() {
      _showOrbitalMenu = !_showOrbitalMenu;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menú orbital ${_showOrbitalMenu ? 'activado' : 'desactivado'}',
        ),
        backgroundColor: const Color(0xFFFFD700),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showConnectionStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Estado de Conexiones',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: Consumer2<DataStreamService, PluginManager>(
          builder: (context, dataService, pluginManager, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildConnectionStatusItem(
                  'Servicio de Datos',
                  dataService.isRunning,
                ),
                _buildConnectionStatusItem(
                  'Plugins Manager',
                  pluginManager.isInitialized,
                ),
                _buildConnectionStatusItem(
                  'Análisis en Tiempo Real',
                  dataService.isRunning,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatusItem(String name, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isConnected 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF5722),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          Text(
            isConnected ? 'ACTIVO' : 'INACTIVO',
            style: TextStyle(
              color: isConnected 
                  ? const Color(0xFF4CAF50) 
                  : const Color(0xFFFF5722),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _createCustomPlugin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Editor de plugins próximamente'),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }

  void _showThemeSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de tema próximamente'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Invictus Trader Pro',
          style: TextStyle(color: Color(0xFFFFD700)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión: 1.0.0 Professional',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Plataforma profesional de trading con IA',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              'Características:',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('• 30+ Indicadores técnicos', style: TextStyle(color: Colors.white70)),
            Text('• Análisis IA con Groq Mistral 7B', style: TextStyle(color: Colors.white70)),
            Text('• Sistema de plugins', style: TextStyle(color: Colors.white70)),
            Text('• Datos en tiempo real', style: TextStyle(color: Colors.white70)),
            Text('• Menú orbital flotante', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documentación y soporte próximamente'),
        backgroundColor: Color(0xFF607D8B),
      ),
    );
  }
}
