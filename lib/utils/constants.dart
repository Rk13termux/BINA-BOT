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

  // AdMob Ad Unit IDs (Test IDs - replace with real ones in production)
  static const String adMobBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String adMobBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String adMobInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String adMobInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String adMobRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String adMobRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';

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

  // Configuración de monetización
  static const String adMobAppId =
      'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String adMobBannerId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String adMobInterstitialId =
      'ca-app-pub-3940256099942544/1033173712'; // Test ID

  // Productos de suscripción
  static const Map<String, String> subscriptionProducts = {
    'premium_monthly': 'invictus_premium_monthly',
    'premium_yearly': 'invictus_premium_yearly',
    'pro_monthly': 'invictus_pro_monthly',
    'pro_yearly': 'invictus_pro_yearly',
  };

  // Precios de suscripción (en USD)
  static const Map<String, double> subscriptionPrices = {
    'premium_monthly': 9.99,
    'premium_yearly': 99.99,
    'pro_monthly': 29.99,
    'pro_yearly': 299.99,
  };

  // Características por plan
  static const Map<String, List<String>> planFeatures = {
    'free': [
      'Basic market data',
      'Limited news access',
      'Basic alerts (5 max)',
      'Ads supported',
    ],
    'premium': [
      'Real-time market data',
      'Unlimited news access',
      'Advanced alerts (25 max)',
      'No ads',
      'Email notifications',
      'Basic trading signals',
    ],
    'pro': [
      'Professional trading tools',
      'Advanced analytics',
      'Unlimited alerts',
      'Custom strategies',
      'Plugin system',
      'API access',
      'Priority support',
      'AI-powered insights',
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
