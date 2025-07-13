import 'package:flutter/material.dart';

/// Constantes globales de la aplicación Invictus Trader Pro
class AppConstants {
  // Información de la aplicación
  static const String appName = 'Invictus Trader Pro';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Professional Cryptocurrency Trading Platform';

  // URLs de API
  static const String binanceApiUrl = 'https://api.binance.com';
  static const String binanceTestnetUrl = 'https://testnet.binance.vision';
  static const String binanceWsUrl = 'wss://stream.binance.com:9443/ws/';
  static const String binanceTestnetWsUrl = 'wss://testnet.binance.vision/ws/';

  // Suscripciones - IDs de productos
  static const String monthlySubscriptionId = 'invictus_monthly_5usd';
  static const String yearlySubscriptionId = 'invictus_yearly_99usd';

  // Intervalos de tiempo para gráficos
  static const Map<String, String> timeIntervals = {
    '1m': '1m',
    '3m': '3m',
    '5m': '5m',
    '15m': '15m',
    '30m': '30m',
    '1h': '1h',
    '2h': '2h',
    '4h': '4h',
    '6h': '6h',
    '8h': '8h',
    '12h': '12h',
    '1d': '1d',
    '3d': '3d',
    '1w': '1w',
    '1M': '1M',
  };

  // Principales pares de trading
  static const List<String> majorPairs = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'SOLUSDT',
    'XRPUSDT',
    'DOTUSDT',
    'LINKUSDT',
    'LTCUSDT',
    'BCHUSDT',
  ];

  // Configuración de indicadores técnicos
  static const Map<String, int> technicalIndicators = {
    'rsiPeriod': 14,
    'emaShortPeriod': 12,
    'emaLongPeriod': 26,
    'smaShortPeriod': 20,
    'smaLongPeriod': 50,
    'macdSignalPeriod': 9,
    'bbPeriod': 20,
    'volumePeriod': 20,
  };

  // Límites de la aplicación
  static const int maxNewsArticles = 100;
  static const int maxCandlesInChart = 1000;
  static const int maxAlertsPerUser = 50;
  static const int maxPluginsPerUser = 10;

  // Configuración de scraping
  static const Map<String, String> newsSources = {
    'coindesk': 'https://www.coindesk.com/tag/markets/',
    'cointelegraph': 'https://cointelegraph.com/tags/markets',
    'cryptonews': 'https://cryptonews.com/news/',
    'decrypt': 'https://decrypt.co/news',
  };

  // Configuración de notificaciones
  static const String notificationChannelId = 'trading_alerts';
  static const String notificationChannelName = 'Trading Alerts';
  static const String notificationChannelDescription =
      'Notifications for trading signals and alerts';

  // Configuración de almacenamiento
  static const String hiveBoxName = 'invictus_trader';
  static const String userPreferencesKey = 'user_preferences';
  static const String tradingHistoryKey = 'trading_history';
  static const String alertsKey = 'alerts';
  static const String pluginsKey = 'plugins';
  static const String newsKey = 'news';

  // Configuración de seguridad
  static const String encryptionKey = 'invictus_trader_encryption_key';
  static const int sessionTimeoutMinutes = 30;

  // Configuración de suscripciones (Solo sistema premium)
  static const Map<String, String> subscriptionProducts = {
    'monthly_premium': 'invictus_monthly_5usd',
    'yearly_premium': 'invictus_yearly_99usd',
  };

  // Precios de suscripción (en USD)
  static const Map<String, double> subscriptionPrices = {
    'monthly_premium': 5.0,
    'yearly_premium': 99.0,
  };

  // Características por plan (simplificado para 2 planes)
  static const Map<String, List<String>> planFeatures = {
    'free': [
      'Basic market data',
      'Limited news access (5 articles/day)',
      'Basic alerts (5 max)',
      'Standard portfolio tracking',
    ],
    'premium': [
      'Real-time market data',
      'Unlimited news access',
      'Advanced alerts (unlimited)',
      'Ad-free experience',
      'Email notifications',
      'Trading signals',
      'Portfolio tracking',
      'Technical indicators',
      'Priority support (yearly only)',
      'AI-powered insights (yearly only)',
      'Custom watchlists',
      'Export data functionality',
      'Advanced portfolio analytics',
      'Beta features access',
    ],
  };

  // Configuración de validación
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Configuración de red
  static const int httpTimeoutSeconds = 30;
  static const int websocketTimeoutSeconds = 10;
  static const int retryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Configuración de caché
  static const Duration cacheExpirationTime = Duration(minutes: 5);
  static const Duration newsCacheTime = Duration(minutes: 30);
  static const Duration priceCacheTime = Duration(seconds: 30);

  // Configuración de gráficos
  static const int defaultCandleCount = 100;
  static const double chartMinZoom = 0.5;
  static const double chartMaxZoom = 5.0;

  // Configuración de trading
  static const double minTradeAmount = 10.0; // USD
  static const double maxTradeAmount = 100000.0; // USD
  static const double defaultStopLossPercentage = 2.0;
  static const double defaultTakeProfitPercentage = 4.0;

  // User Agent para web scraping
  static const String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';

  // Configuración de logs
  static const int maxLogEntries = 1000;
  static const Duration logRetentionPeriod = Duration(days: 7);

  // Configuración de backup
  static const Duration backupInterval = Duration(hours: 24);
  static const int maxBackupFiles = 7;
}

// Colores de la aplicación
class AppColors {
  // Colores principales
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color goldPrimary = Color(0xFFFFD700);

  // Colores de trading
  static const Color bullishGreen = Color(0xFF00FF88);
  static const Color bearishRed = Color(0xFFFF4444);

  // Colores de superficie
  static const Color surfaceDark = Color(0xFF2A2A2A);
  static const Color cardDark = Color(0xFF212121);

  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF808080);

  // Colores de estado
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Colores de gradiente
  static const List<Color> goldGradient = [
    Color(0xFFFFD700),
    Color(0xFFFFA500),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF1A1A1A),
    Color(0xFF2A2A2A),
  ];
}

/// Claves para almacenamiento seguro
class StorageKeys {
  static const String binanceApiKey = 'binance_api_key';
  static const String binanceSecretKey = 'binance_secret_key';
  static const String userSettings = 'user_settings';
  static const String watchlist = 'watchlist';
  static const String alerts = 'alerts';
  static const String tradingHistory = 'trading_history';
  static const String portfolioData = 'portfolio_data';
  static const String userPreferences = 'user_preferences';
  static const String subscriptionData = 'subscription_data';
  static const String darkModeEnabled = 'dark_mode_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String autoTradingEnabled = 'auto_trading_enabled';
  static const String riskManagementSettings = 'risk_management_settings';
}
