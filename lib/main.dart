import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Theme imports
import 'ui/theme/app_theme.dart';

// Feature imports
import 'features/splash/splash_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/bina_bot_pro_main_dashboard.dart';
import 'features/subscription/subscription_screen.dart';
import 'features/news/news_controller.dart';
import 'features/trading/trading_controller.dart';
import 'features/alerts/alerts_controller.dart';

// Service imports
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/initialization_service.dart';
import 'services/binance_websocket_service.dart';
import 'services/free_crypto_service.dart';
import 'core/api_manager.dart';

// Utils
import 'utils/logger.dart';

void main() async {
  // Configurar manejo de errores global
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger().error('Flutter Error: ${details.exception}');
    AppLogger().error('Stack trace: ${details.stack}');
  };

  // Configurar manejo de errores en Zone
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

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

    runApp(const BinaBotProApp());
  }, (error, stack) {
    AppLogger().error('Zone Error: $error');
    AppLogger().error('Zone Stack: $stack');
  });
}

class BinaBotProApp extends StatelessWidget {
  const BinaBotProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initialization Service (debe ser el primero)
        ChangeNotifierProvider(create: (_) => InitializationService()),
        
        // Controllers
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => TradingController()),
        ChangeNotifierProvider(create: (_) => AlertsController()),

        // Services
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => BinanceWebSocketService()),
        Provider(create: (_) => FreeCryptoService()),
        Provider(create: (_) => ApiManager()),
      ],
      child: MaterialApp(
        title: 'BINA-BOT PRO',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        
        // Iniciar con el nuevo dashboard principal
        home: const BinaBotProMainDashboard(),

        // Configuración de rutas actualizadas
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/dashboard': (context) => const BinaBotProMainDashboard(),
          '/legacy-dashboard': (context) => const DashboardScreen(),
          '/subscription': (context) => const SubscriptionScreen(),
          // TODO: Agregar más rutas cuando las pantallas estén implementadas
          // '/trading': (context) => const TradingScreen(),
          // '/alerts': (context) => const AlertsScreen(),
          // '/plugins': (context) => const PluginsScreen(),
          // '/settings': (context) => const SettingsScreen(),
          // '/news': (context) => const NewsScreen(),
        },

        // Configuración del builder para el tema negro
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0), // Prevenir escalado de texto
            ),
            child: Container(
              color: const Color(0xFF000000), // Fondo negro garantizado
              child: child!,
            ),
          );
        },
        
        // Manejar rutas desconocidas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const BinaBotProMainDashboard(),
          );
        },
      ),
    );
  }
}
