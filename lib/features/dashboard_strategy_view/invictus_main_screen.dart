import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../ui/theme/colors.dart';
import '../../utils/logger.dart';
import '../coin_selector/coin_selector_screen.dart';
import '../strategy_selector/strategy_selector_screen.dart';
import '../../plugins/strategies/base_strategy.dart';
import '../../services/binance_service.dart';
import '../../services/ai_service.dart';

/// Pantalla principal de Invictus Trader Pro con menú orbital
class InvictusMainScreen extends StatefulWidget {
  const InvictusMainScreen({super.key});

  @override
  State<InvictusMainScreen> createState() => _InvictusMainScreenState();
}

class _InvictusMainScreenState extends State<InvictusMainScreen>
    with TickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  
  // Estados del menú orbital
  bool _isMenuOpen = false;
  late AnimationController _menuAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _menuAnimation;
  late Animation<double> _fabAnimation;

  // Estados de la aplicación
  String? _selectedCoin;
  BaseStrategy? _selectedStrategy;
  bool _useAI = true;
  Map<String, dynamic> _strategyConfiguration = {};
  bool _isStrategyRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _menuAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _menuAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _initializeServices() async {
    try {
      final aiService = Provider.of<AIService>(context, listen: false);
      await aiService.initialize();
    } catch (e) {
      _logger.error('Failed to initialize services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Stack(
        children: [
          // Contenido principal
          _buildMainContent(),
          
          // Overlay del menú
          if (_isMenuOpen) _buildMenuOverlay(),
          
          // Botón FAB orbital
          _buildOrbitalFAB(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedStrategy != null && _strategyConfiguration.isNotEmpty) {
      return _selectedStrategy!.buildDashboardWidget(context, _strategyConfiguration);
    }

    return _buildWelcomeScreen();
  }

  Widget _buildWelcomeScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundBlack,
            AppColors.surfaceDark,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildWelcomeContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Logo y título
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.goldPrimary, AppColors.goldDeep],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'INVICTUS TRADER PRO',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Plataforma Profesional de Trading con IA',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Estado de conexión
          Consumer<BinanceService>(
            builder: (context, binanceService, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: binanceService.isAuthenticated
                      ? AppColors.bullish.withOpacity(0.2)
                      : AppColors.bearish.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: binanceService.isAuthenticated
                        ? AppColors.bullish
                        : AppColors.bearish,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: binanceService.isAuthenticated
                            ? AppColors.bullish
                            : AppColors.bearish,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      binanceService.isAuthenticated ? 'CONECTADO' : 'DESCONECTADO',
                      style: TextStyle(
                        color: binanceService.isAuthenticated
                            ? AppColors.bullish
                            : AppColors.bearish,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Widget _buildWelcomeContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Título de bienvenida
          Text(
            'Bienvenido a la Nueva Era del Trading',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Selecciona una criptomoneda y elige tu estrategia de trading profesional con inteligencia artificial',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Botón principal para empezar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _startTradingFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'COMENZAR TRADING',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Características principales
          _buildFeatureCards(),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.psychology,
        'title': 'IA Avanzada',
        'description': 'Análisis predictivo con algoritmos de última generación',
        'color': AppColors.info,
      },
      {
        'icon': Icons.speed,
        'title': 'Estrategias Pro',
        'description': 'Scalping, Swing, Grid y más estrategias profesionales',
        'color': AppColors.bullish,
      },
      {
        'icon': Icons.security,
        'title': 'Seguro y Confiable',
        'description': 'Conexión directa con Binance, sin intermediarios',
        'color': AppColors.goldPrimary,
      },
    ];

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.2 : 3,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (feature['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (feature['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: feature['color'] as Color,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  feature['title'] as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  feature['description'] as String,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuOverlay() {
    return AnimatedBuilder(
      animation: _menuAnimation,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.7 * _menuAnimation.value),
          child: Center(
            child: Transform.scale(
              scale: _menuAnimation.value,
              child: _buildOrbitalMenu(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrbitalMenu() {
    final menuItems = [
      {'icon': Icons.account_balance_wallet, 'label': 'Portfolio', 'onTap': () => _navigateToPortfolio()},
      {'icon': Icons.settings, 'label': 'Configuración', 'onTap': () => _navigateToSettings()},
      {'icon': Icons.analytics, 'label': 'Análisis', 'onTap': () => _navigateToAnalysis()},
      {'icon': Icons.history, 'label': 'Historial', 'onTap': () => _navigateToHistory()},
      {'icon': Icons.notification_important, 'label': 'Alertas', 'onTap': () => _navigateToAlerts()},
      {'icon': Icons.help, 'label': 'Ayuda', 'onTap': () => _navigateToHelp()},
    ];

    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Elementos del menú en círculo
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final angle = (index * 2 * 3.14159) / menuItems.length;
            final radius = 120.0;
            
            return Transform.translate(
              offset: Offset(
                radius * math.cos(angle - 3.14159 / 2),
                radius * math.sin(angle - 3.14159 / 2),
              ),
              child: _buildMenuButton(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                onTap: item['onTap'] as VoidCallback,
              ),
            );
          }).toList(),
          
          // Botón central de cerrar
          GestureDetector(
            onTap: _toggleMenu,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.bearish,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bearish.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _toggleMenu();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitalFAB() {
    return Positioned(
      bottom: 30,
      right: 30,
      child: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabAnimation.value * 0.1),
            child: FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.black,
              elevation: 8,
              child: AnimatedRotation(
                turns: _isMenuOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.menu, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  // Métodos de navegación y acciones

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });

    if (_isMenuOpen) {
      _menuAnimationController.forward();
      _fabAnimationController.forward();
    } else {
      _menuAnimationController.reverse();
      _fabAnimationController.reverse();
    }
  }

  void _startTradingFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoinSelectorScreen(
          onCoinSelected: _onCoinSelected,
        ),
      ),
    );
  }

  void _onCoinSelected(String coin) {
    setState(() {
      _selectedCoin = coin;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrategySelectorScreen(
          selectedCoin: coin,
          onStrategySelected: _onStrategySelected,
        ),
      ),
    );
  }

  void _onStrategySelected(BaseStrategy strategy, bool useAI) {
    setState(() {
      _selectedStrategy = strategy;
      _useAI = useAI;
    });

    // Mostrar configuración de estrategia
    _showStrategyConfiguration(strategy, useAI);
  }

  void _showStrategyConfiguration(BaseStrategy strategy, bool useAI) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(strategy.icon, color: strategy.color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configurar ${strategy.name}',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Para $_selectedCoin${useAI ? ' con IA' : ''}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Configuración
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: strategy.buildConfigurationWidget(
                  context,
                  (configuration) {
                    setState(() {
                      _strategyConfiguration = configuration;
                    });
                    Navigator.pop(context);
                    _initializeStrategy(strategy, useAI, configuration);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeStrategy(
    BaseStrategy strategy,
    bool useAI,
    Map<String, dynamic> configuration,
  ) async {
    try {
      await strategy.initialize(configuration, useAI);
      _logger.info('Strategy ${strategy.name} initialized successfully');
      
      // Actualizar la UI para mostrar el dashboard de la estrategia
      setState(() {});
      
    } catch (e) {
      _logger.error('Failed to initialize strategy: $e');
      _showErrorDialog('Error al inicializar la estrategia: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Error',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.goldPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de navegación del menú orbital

  void _navigateToPortfolio() {
    _logger.info('Navigate to Portfolio');
    // TODO: Implementar navegación al portfolio
  }

  void _navigateToSettings() {
    _logger.info('Navigate to Settings');
    // TODO: Implementar navegación a configuración
  }

  void _navigateToAnalysis() {
    _logger.info('Navigate to Analysis');
    // TODO: Implementar navegación a análisis
  }

  void _navigateToHistory() {
    _logger.info('Navigate to History');
    // TODO: Implementar navegación al historial
  }

  void _navigateToAlerts() {
    _logger.info('Navigate to Alerts');
    // TODO: Implementar navegación a alertas
  }

  void _navigateToHelp() {
    _logger.info('Navigate to Help');
    // TODO: Implementar navegación a ayuda
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }
}
