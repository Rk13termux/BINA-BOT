import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../services/binance_service.dart';
import '../../services/ai_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../trading/trading_screen.dart';
import '../news/news_screen.dart';
import '../alerts/alerts_screen.dart';
import '../settings/settings_screen.dart';

/// Pantalla principal profesional de INVICTUS TRADER PRO con menú orbital
class InvictusMainScreen extends StatefulWidget {
  const InvictusMainScreen({super.key});

  @override
  State<InvictusMainScreen> createState() => _InvictusMainScreenState();
}

class _InvictusMainScreenState extends State<InvictusMainScreen>
    with TickerProviderStateMixin {
  
  // Controladores de animación
  late AnimationController _orbitalController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  
  // Animaciones
  late Animation<double> _orbitalAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  
  // Estado del menú
  bool _isMenuOpen = false;
  int _selectedIndex = 0;
  
  // Páginas disponibles
  final List<Widget> _pages = [
    const DashboardScreen(),
    const TradingScreen(),
    const NewsScreen(),
    const AlertsScreen(),
    const Center(child: Text('Coin Selector', style: TextStyle(color: Colors.white))),
    const SettingsScreen(),
  ];
  
  // Configuración del menú orbital
  final List<OrbitalMenuItem> _menuItems = [
    OrbitalMenuItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: const Color(0xFFFFD700),
      index: 0,
    ),
    OrbitalMenuItem(
      icon: Icons.trending_up_rounded,
      label: 'Trading',
      color: const Color(0xFF00FF88),
      index: 1,
    ),
    OrbitalMenuItem(
      icon: Icons.article_rounded,
      label: 'Noticias',
      color: const Color(0xFF64B5F6),
      index: 2,
    ),
    OrbitalMenuItem(
      icon: Icons.notifications_active_rounded,
      label: 'Alertas',
      color: const Color(0xFFFF6B6B),
      index: 3,
    ),
    OrbitalMenuItem(
      icon: Icons.currency_bitcoin_rounded,
      label: 'Coins',
      color: const Color(0xFFFF9800),
      index: 4,
    ),
    OrbitalMenuItem(
      icon: Icons.settings_rounded,
      label: 'Config',
      color: const Color(0xFF9C27B0),
      index: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    // Controlador de órbita principal
    _orbitalController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    // Controlador de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador de flotación
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Configurar animaciones
    _orbitalAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _orbitalController,
      curve: Curves.linear,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _floatAnimation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animaciones
    _orbitalController.repeat();
    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
  }
  
  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final binanceService = context.read<BinanceService>();
      final aiService = context.read<AIService>();
      // final wsService = context.read<WebSocketService>(); // Comentado temporalmente
      
      // Inicializar servicios si no están inicializados
      if (!binanceService.isAuthenticated) {
        await binanceService.initialize();
      }
      
      if (!aiService.isInitialized) {
        await aiService.initialize();
      }
      
      // if (!wsService.isConnected) {
      //   await wsService.initialize();
      // }
    });
  }

  @override
  void dispose() {
    _orbitalController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
  
  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      _isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          'INVICTUS TRADER PRO',
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Página actual con efecto de profundidad
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: _pages[_selectedIndex],
          ),
          
          // Efecto de partículas de fondo
          _buildParticlesEffect(),
          
          // Menú orbital de levitación
          _buildOrbitalMenu(),
          
          // Indicador de página actual
          _buildPageIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildParticlesEffect() {
    return AnimatedBuilder(
      animation: _orbitalAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_orbitalAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildOrbitalMenu() {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width - 40;
    final centerY = screenSize.height - 120;
    const radius = 80.0;
    
    return Stack(
      children: [
        // Botón central
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
          builder: (context, child) {
            return Positioned(
              right: 20,
              bottom: 100 + _floatAnimation.value,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFF8C00),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: _toggleMenu,
                      child: Icon(
                        _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Items del menú orbital
        if (_isMenuOpen)
          ...List.generate(_menuItems.length, (index) {
            final angle = (index * 2 * math.pi / _menuItems.length);
            final item = _menuItems[index];
            
            return AnimatedBuilder(
              animation: _orbitalAnimation,
              builder: (context, child) {
                final currentAngle = angle + (_orbitalAnimation.value * 0.5);
                final x = centerX - 40 + (radius * math.cos(currentAngle));
                final y = centerY - 40 + (radius * math.sin(currentAngle));
                
                return Positioned(
                  left: x,
                  top: y,
                  child: _buildOrbitalItem(item),
                );
              },
            );
          }),
      ],
    );
  }
  
  Widget _buildOrbitalItem(OrbitalMenuItem item) {
    final isSelected = _selectedIndex == item.index;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()
        ..scale(isSelected ? 1.2 : 1.0),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.color.withValues(alpha: isSelected ? 1.0 : 0.8),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.6),
              blurRadius: isSelected ? 15 : 10,
              spreadRadius: isSelected ? 3 : 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () => _selectPage(item.index),
            child: Icon(
              item.icon,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageIndicator() {
    return Positioned(
      top: 100,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _menuItems[_selectedIndex].icon,
              color: _menuItems[_selectedIndex].color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _menuItems[_selectedIndex].label,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo para items del menú orbital
class OrbitalMenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final int index;
  
  const OrbitalMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.index,
  });
}

/// Painter para efecto de partículas
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  
  ParticlesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.1 + animationValue * 0.02)) % size.width;
      final y = (size.height * (i * 0.05 + animationValue * 0.01)) % size.height;
      final opacity = (math.sin(animationValue * 2 + i) + 1) / 2 * 0.3;
      
      paint.color = const Color(0xFFFFD700).withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x, y),
        1.0 + math.sin(animationValue + i) * 0.5,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
