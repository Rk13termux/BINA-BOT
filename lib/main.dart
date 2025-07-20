import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import 'features/onboarding/onboarding_screen.dart';
import 'features/dashboard/quantix_dashboard.dart';
import 'features/settings/settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/plugin_center/plugin_center_screen.dart';
import 'features/news_scraper/news_scraper_screen.dart';
import 'features/subscriptions/subscription_screen.dart';

import 'ui/theme/app_theme.dart';
import 'services/binance_service.dart';
import 'services/groq_service.dart';
import 'services/initialization_service.dart';
import 'services/auth_service.dart';
import 'services/technical_indicator_service.dart';
import 'services/binance_websocket_service.dart';
import 'services/plugin_service.dart';
import 'services/data_stream_service.dart';
import 'core/api_manager.dart';
import 'utils/environment_config.dart';
import 'utils/logger.dart';
import 'services/ai_service_professional.dart';

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger().error('Flutter Error: ${details.exception}');
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await dotenv.load(fileName: ".env");
      await EnvironmentConfig.initialize();
      AppLogger().info('Environment configuration initialized successfully');
      AppLogger().debug('Loaded ${dotenv.env.length} environment variables');
    } catch (e) {
      AppLogger().error('Could not initialize environment configuration: $e');
      AppLogger().warning('Using fallback configuration values');
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    runApp(const QuantixAICoreApp());
  }, (error, stack) {
    AppLogger().error('Unhandled error: $error');
  });
}

class QuantixAICoreApp extends StatelessWidget {
  const QuantixAICoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiManager>(create: (_) => ApiManager()),
        Provider<GroqService>(create: (_) => GroqService()),
        ChangeNotifierProvider(create: (_) => InitializationService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BinanceService()),
        ChangeNotifierProvider(create: (_) => TechnicalIndicatorService()),
        ChangeNotifierProvider(create: (_) => BinanceWebSocketService()),
        Provider<PluginService>(create: (_) => PluginService()),
        ChangeNotifierProvider(
            create: (context) => DataStreamService(
                  binanceService: context.read<BinanceService>(),
                  aiService: context.read<AIService>(),
                )),
      ],
      child: MaterialApp(
        title: 'QUANTIX AI CORE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const OnboardingScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/dashboard': (context) => const QuantixDashboard(),
          '/settings': (context) => const SettingsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/plugins': (context) => const PluginCenterScreen(),
          '/news': (context) => const NewsScraperScreen(),
          '/subscriptions': (context) => const SubscriptionScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const QuantixDashboard(),
          );
        },
      ),
    );
  }
}
