import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Tema y configuración
import 'ui/theme/quantix_theme.dart';

// Pantallas principales
import 'features/auth_api_binance/quantix_onboarding_screen.dart';
import 'features/dashboard/quantix_dashboard.dart';

/// 🚀 QUANTIX AI CORE - Punto de entrada principal
/// "Piensa como fondo, opera como elite."
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno si existe un archivo .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignorar si no hay archivo .env
  }

  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: QuantixTheme.primaryBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Las claves API se configuran de forma segura en el onboarding.
  // Si existe un archivo `.env`, sus valores se usarán como configuración inicial.
  
  runApp(const QuantixAICore());
}

/// Aplicación principal de QUANTIX AI CORE
class QuantixAICore extends StatelessWidget {
  const QuantixAICore({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // TODO: Agregar providers para servicios
        // ChangeNotifierProvider(create: (context) => MarketDataProvider()),
        // ChangeNotifierProvider(create: (context) => AIAnalysisProvider()),
        // ChangeNotifierProvider(create: (context) => SignalEngineProvider()),
      ],
      child: MaterialApp(
        title: 'QUANTIX AI CORE',
        debugShowCheckedModeBanner: false,
        
        // Tema profesional
        theme: QuantixTheme.darkTheme,
        
        // Rutas
        initialRoute: '/',
        routes: {
          '/': (context) => const QuantixSplashScreen(),
          '/onboarding': (context) => const QuantixOnboardingScreen(),
          '/dashboard': (context) => const QuantixDashboard(),
        },
        
        // Configuración adicional
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Evitar escalado de fuentes
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

/// 🎬 Splash Screen de QUANTIX AI CORE
class QuantixSplashScreen extends StatefulWidget {
  const QuantixSplashScreen({super.key});

  @override
  State<QuantixSplashScreen> createState() => _QuantixSplashScreenState();
}

class _QuantixSplashScreenState extends State<QuantixSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    
    // Animaciones
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    
    _startAnimations();
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// Iniciar animaciones
  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
    });
  }

  /// Verificar si el onboarding está completado
  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Mostrar splash por 3 segundos
    
    try {
      final onboardingCompleted = await _secureStorage.read(key: 'onboarding_completed');
      
      if (mounted) {
        if (onboardingCompleted == 'true') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding');
        }
      }
    } catch (e) {
      // Si hay error, ir al onboarding
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              QuantixTheme.primaryBlack,
              QuantixTheme.secondaryBlack,
              QuantixTheme.primaryBlack,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              ScaleTransition(
                scale: _logoAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: QuantixTheme.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: QuantixTheme.primaryGold.withValues(alpha: 0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_graph,
                    size: 60,
                    color: QuantixTheme.primaryBlack,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Texto animado
              FadeTransition(
                opacity: _textAnimation,
                child: Column(
                  children: [
                    // Título principal
                    ShaderMask(
                      shaderCallback: (bounds) => QuantixTheme.goldGradient.createShader(bounds),
                      child: Text(
                        'QUANTIX',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    // Subtítulo
                    Text(
                      'AI CORE',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: QuantixTheme.electricBlue,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Eslogan
                    Text(
                      'Piensa como fondo, opera como elite.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: QuantixTheme.lightGold,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Indicador de carga
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        backgroundColor: QuantixTheme.neutralGray.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(QuantixTheme.primaryGold),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Inicializando sistemas...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: QuantixTheme.neutralGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
