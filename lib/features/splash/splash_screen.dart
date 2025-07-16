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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Escuchar el servicio de inicialización para navegar cuando esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initService = context.read<InitializationService>();
      initService.addListener(_onInitializationComplete);
      initService.initialize(); // Iniciar la inicialización
    });
  }

  void _onInitializationComplete() {
    final initService = context.read<InitializationService>();
    if (initService.isInitialized && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProfessionalTradingDashboard()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Asegurarse de remover el listener para evitar memory leaks
    if (mounted) {
       context.read<InitializationService>().removeListener(_onInitializationComplete);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observar los cambios en el servicio de inicialización
    final initService = context.watch<InitializationService>();

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                Image.asset(
                  'assets/icons/icon.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 40),
                // Título
                Text(
                  'INVICTUS TRADER PRO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldPrimary,
                    letterSpacing: 2.0,
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
                const Spacer(flex: 2),
                // Estado de inicialización
                if (initService.errorMessage != null)
                  _buildErrorState(initService.errorMessage!)
                else
                  _buildLoadingState(initService.initStatus),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String status) {
    return Column(
      children: [
        Text(
          status,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const LinearProgressIndicator(
          backgroundColor: Colors.white10,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red[400], size: 48),
        const SizedBox(height: 16),
        Text(
          'Initialization Error',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red[400],
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          error,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
