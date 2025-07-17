import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

// Theme imports
import 'ui/theme/app_theme.dart';

// Service imports
import 'services/auth_service.dart';
import 'services/technical_indicator_service.dart';
import 'services/data_stream_service.dart';
import 'services/plugins/plugin_manager.dart';
import 'services/initialization_service.dart';
import 'services/binance_service.dart';
import 'services/binance_websocket_service.dart';
import 'services/groq_service.dart';
import 'services/ai_assistant_service.dart';
import 'services/ai_service_professional.dart' as ai_professional;
import 'core/api_manager.dart';

// Feature imports
import 'features/splash/splash_screen.dart';
import 'features/main/main_screen.dart';
import 'features/dashboard/screens/ultra_professional_dashboard.dart';
import 'features/dashboard/screens/professional_trading_dashboard.dart';
import 'features/trading/trading_screen.dart';
import 'features/alerts/alerts_screen.dart';
import 'features/news/news_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/news/news_controller.dart';
import 'features/trading/trading_controller.dart';
import 'features/alerts/alerts_controller.dart';
import 'features/ai_assistant/ai_assistant_controller.dart';
import 'features/ai_chat/ai_chat_page.dart';

// Utils
import 'utils/logger.dart';

void main() async {
  // Configurar manejo de errores global
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger().error('Flutter Error: ${details.exception}');
  };

  // Configurar manejo de errores en Zone
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Cargar variables de entorno
    try {
      await dotenv.load(fileName: ".env");
      AppLogger().info('Environment variables loaded successfully');
    } catch (e) {
      AppLogger().warning('Could not load .env file: $e');
    }

    // Configurar orientación de pantalla
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Configurar barra de estado para tema negro
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000), // Negro puro
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    runApp(const InvictusTraderApp());
  }, (error, stack) {
    AppLogger().error('Unhandled error: $error');
  });
}

class InvictusTraderApp extends StatelessWidget {
  const InvictusTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core Services (Singleton)
        Provider<ApiManager>(create: (_) => ApiManager()),
        Provider<GroqService>(create: (_) => GroqService()),
        ChangeNotifierProvider(create: (_) => InitializationService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BinanceService()),
        ChangeNotifierProvider(create: (_) => TechnicalIndicatorService()),
        ChangeNotifierProvider(create: (_) => BinanceWebSocketService()),
        Provider<PluginManager>(create: (_) => PluginManager()),

        // AI Services
        ChangeNotifierProvider<ai_professional.AIService>(create: (_) => ai_professional.AIService()),

        // AI Assistant Service (depende de Groq y Binance)
        ProxyProvider2<GroqService, BinanceService, AIAssistantService>(
          update: (context, groqService, binanceService, previous) =>
              AIAssistantService(
                  groqService: groqService, binanceService: binanceService),
        ),

        // Data Stream Service
        ChangeNotifierProvider(create: (context) => DataStreamService(
          binanceService: context.read<BinanceService>(),
          aiService: context.read<ai_professional.AIService>(),
        )),

        // Controllers (UI-specific state)
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => TradingController()),
        ChangeNotifierProvider(create: (_) => AlertsController()),
        ChangeNotifierProxyProvider<AIAssistantService, AIAssistantController>(
          create: (context) => AIAssistantController(aiAssistantService: context.read<AIAssistantService>()),
          update: (context, aiAssistantService, previous) => AIAssistantController(aiAssistantService: aiAssistantService),
        ),
      ],
      child: MaterialApp(
        title: 'INVICTUS TRADER PRO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,

        // Iniciar con SplashScreen que redirige al dashboard profesional
        home: const SplashScreen(),

        // Configuración de rutas
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/main': (context) => const MainScreen(),
          '/dashboard': (context) => const ProfessionalTradingDashboard(),
          '/dashboard-ultra': (context) => const UltraProfessionalDashboard(),
          '/trading': (context) => const TradingScreen(),
          '/alerts': (context) => const AlertsScreen(),
          '/news': (context) => const NewsScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/ai-chat': (context) => const AIChatPage(),
        },

        // Configuración del builder para el tema
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Prevenir escalado de texto
            ),
            child: child!,
          );
        },

        // Manejar rutas desconocidas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const MainScreen(),
          );
        },
      ),
    );
  }
}
