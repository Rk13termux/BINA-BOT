import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/initialization_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../../ui/theme/colors.dart';

/// Pantalla de carga que maneja la inicialización de la aplicación
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
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
    
    // Esperar un momento para que se vea la animación
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Iniciar animación del progreso
    _progressController.forward();
    
    // Inicializar la aplicación
    final initService = context.read<InitializationService>();
    final success = await initService.initialize();
    
    if (success && mounted) {
      // Navegar al dashboard después de una pequeña pausa
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Consumer<InitializationService>(
          builder: (context, initService, child) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  
                  // Logo animado
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.goldPrimary,
                                AppColors.goldPrimary.withOpacity(0.8),
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
                          child: const Icon(
                            Icons.trending_up,
                            size: 60,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Título
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'INVICTUS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldPrimary,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: AppColors.goldPrimary.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'TRADER PRO',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Estado de inicialización
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _progressAnimation.value,
                        child: Column(
                          children: [
                            // Barra de progreso
                            Container(
                              width: double.infinity,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: initService.isInitialized
                                    ? double.infinity
                                    : MediaQuery.of(context).size.width * 0.7,
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.goldPrimary,
                                      AppColors.goldPrimary.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Texto de estado
                            Text(
                              initService.initStatus,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Mensaje de error si existe
                            if (initService.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red.shade300,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      initService.errorMessage!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade300,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => initService.retry(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.goldPrimary,
                                        foregroundColor: AppColors.primaryDark,
                                      ),
                                      child: const Text('Reintentar'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
            );
          },
        ),
      ),
    );
  }
}
