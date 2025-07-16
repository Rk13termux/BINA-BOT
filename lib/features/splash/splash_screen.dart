import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/initialization_service.dart';
import '../dashboard/screens/professional_trading_dashboard.dart';
import '../../ui/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoScale;
  late Animation<double> _progressAnimation;
  
  String _currentStatus = 'Iniciando aplicación...';

  @override
  void initState() {
    super.initState();

    // Controlador de animación del logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Controlador de animación del progreso
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animaciones del logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Animación del progreso
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _startInitialization();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    // Iniciar animación del logo
    _logoController.forward();
    
    setState(() {
      _currentStatus = 'Cargando recursos...';
    });
    
    // Esperar un momento para que se vea la animación
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _currentStatus = 'Preparando dashboard...';
    });
    
    // Iniciar animación del progreso
    _progressController.forward();
    
    try {
      setState(() {
        _currentStatus = 'Configurando aplicación...';
      });
      
      // Inicialización básica y segura
      await _performBasicInitialization();
      
      setState(() {
        _currentStatus = 'Iniciando dashboard profesional...';
      });
      
      // Esperar que las animaciones terminen
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfessionalTradingDashboard()),
        );
      }
      
    } catch (e) {
      setState(() {
        _currentStatus = 'Continuando al dashboard...';
      });
      
      // En caso de error, navegar al dashboard para configuración manual
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ProfessionalTradingDashboard()),
          );
        }
      }
    }
  }

  /// Inicialización básica y segura que no puede fallar
  Future<void> _performBasicInitialization() async {
    try {
      // Solo operaciones básicas que no pueden fallar
      setState(() {
        _currentStatus = 'Verificando tema...';
      });
      await Future.delayed(const Duration(milliseconds: 200));
      
      setState(() {
        _currentStatus = 'Cargando configuración...';
      });
      await Future.delayed(const Duration(milliseconds: 200));
      
      setState(() {
        _currentStatus = 'Preparando servicios...';
      });
      await Future.delayed(const Duration(milliseconds: 200));
      
    } catch (e) {
      // Log the error but don't fail
      print('Basic initialization warning: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Negro puro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Negro puro
              Color(0xFF0A0A0A), // Negro muy oscuro
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo principal
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.goldPrimary,
                              AppColors.goldPrimary.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.goldPrimary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.auto_graph,
                              size: 80,
                                  color: AppColors.primaryDark,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Título de la aplicación
                    AnimatedBuilder(
                      animation: _logoScale,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoScale.value,
                          child: Column(
                            children: [
                              Text(
                                'INVICTUS TRADER PRO',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldPrimary,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: AppColors.goldPrimary.withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Professional Trading Platform',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Estado de inicialización
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _progressAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                initService.initStatus.isNotEmpty 
                                    ? initService.initStatus 
                                    : _currentStatus,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              
                              // Barra de progreso
                              Container(
                                width: double.infinity,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.goldPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Mensaje de error si existe
                              if (initService.errorMessage != null)
                                Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[400],
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error de inicialización',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red[400],
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      initService.errorMessage ?? 'Error desconocido',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navegar directamente al dashboard en caso de error persistente
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(builder: (_) => const ProfessionalTradingDashboard()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.goldPrimary,
                                        foregroundColor: AppColors.primaryDark,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Continuar al Dashboard'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const Spacer(flex: 3),
                    
                    // Versión y copyright
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _progressAnimation.value * 0.6,
                          child: Column(
                            children: [
                              Text(
                                'Versión 1.0.0',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2025 Invictus Trading Solutions',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
