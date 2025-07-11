import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Theme imports
import 'ui/theme/app_theme.dart';

// Feature imports
import 'features/dashboard/dashboard_screen.dart';
import 'features/news/news_controller.dart';
import 'features/trading/trading_controller.dart';
import 'features/alerts/alerts_controller.dart';

// Service imports
import 'services/auth_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Hive para almacenamiento local
  await Hive.initFlutter();

  // Configurar orientación de pantalla
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const InvictusTraderApp());
}

class InvictusTraderApp extends StatelessWidget {
  const InvictusTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Controllers
        ChangeNotifierProvider(create: (_) => NewsController()),
        ChangeNotifierProvider(create: (_) => TradingController()),
        ChangeNotifierProvider(create: (_) => AlertsController()),

        // Services
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
      ],
      child: MaterialApp(
        title: 'Invictus Trader Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const DashboardScreen(),

        // Configuración de rutas
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          // TODO: Agregar más rutas cuando las pantallas estén implementadas
          // '/trading': (context) => const TradingScreen(),
          // '/alerts': (context) => const AlertsScreen(),
          // '/plugins': (context) => const PluginsScreen(),
          // '/settings': (context) => const SettingsScreen(),
          // '/news': (context) => const NewsScreen(),
        },

        // Configuración del builder para el tema
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler:
                  const TextScaler.linear(1.0), // Prevenir escalado de texto
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
