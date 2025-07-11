import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/signal.dart';
import '../utils/logger.dart';
import '../ui/theme/colors.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final AppLogger _logger = AppLogger();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      final permissionStatus = await _requestPermissions();
      if (!permissionStatus) {
        _logger.warning('Notification permissions not granted');
        return;
      }

      // Android initialization
      const androidInitialization = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization
      const iosInitialization = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      // Initialize
      const initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization,
      );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      _logger.info('Notification service initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize notification service: $e');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      final status = await Permission.notification.status;
      
      if (status == PermissionStatus.granted) {
        return true;
      }
      
      if (status == PermissionStatus.denied) {
        final result = await Permission.notification.request();
        return result == PermissionStatus.granted;
      }
      
      return false;
    } catch (e) {
      _logger.error('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    _logger.info('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific screen
  }

  /// Show price alert notification
  Future<void> showPriceAlert({
    required String symbol,
    required double currentPrice,
    required double targetPrice,
    required String condition, // 'above' or 'below'
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const channelId = 'price_alerts';
      const channelName = 'Price Alerts';
      const channelDescription = 'Notifications for price alerts';

      final title = 'Price Alert: $symbol';
      final body = '$symbol is now ${condition == 'above' ? 'above' : 'below'} \$${targetPrice.toStringAsFixed(2)}';
      final payload = 'price_alert:$symbol:$currentPrice';

      await _notifications.show(
        _generateNotificationId(),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: AppColors.goldPrimary,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: payload,
      );

      _logger.info('Price alert notification sent for $symbol');
    } catch (e) {
      _logger.error('Failed to show price alert notification: $e');
    }
  }

  /// Show trading signal notification
  Future<void> showTradingSignal(Signal signal) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const channelId = 'trading_signals';
      const channelName = 'Trading Signals';
      const channelDescription = 'Notifications for trading signals';

      final title = 'Trading Signal: ${signal.symbol}';
      final body = '${signal.type.name.toUpperCase()} signal generated for ${signal.symbol}';
      final payload = 'trading_signal:${signal.symbol}:${signal.type}';

      await _notifications.show(
        _generateNotificationId(),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: signal.type == SignalType.buy ? AppColors.bullish : AppColors.bearish,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: payload,
      );

      _logger.info('Trading signal notification sent for ${signal.symbol}');
    } catch (e) {
      _logger.error('Failed to show trading signal notification: $e');
    }
  }

  /// Show news notification
  Future<void> showNewsAlert({
    required String title,
    required String summary,
    required String source,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const channelId = 'news_alerts';
      const channelName = 'News Alerts';
      const channelDescription = 'Notifications for crypto news';

      final notificationTitle = 'Crypto News';
      final body = '$title - $source';
      final payload = 'news:$source';

      await _notifications.show(
        _generateNotificationId(),
        notificationTitle,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: AppColors.goldPrimary,
            playSound: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: false,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: payload,
      );

      _logger.info('News notification sent: $title');
    } catch (e) {
      _logger.error('Failed to show news notification: $e');
    }
  }

  /// Show portfolio update notification
  Future<void> showPortfolioUpdate({
    required double totalValue,
    required double changePercent,
    required String period,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const channelId = 'portfolio_updates';
      const channelName = 'Portfolio Updates';
      const channelDescription = 'Notifications for portfolio changes';

      final title = 'Portfolio Update';
      final changeSymbol = changePercent >= 0 ? '+' : '';
      final body = 'Your portfolio is worth \$${totalValue.toStringAsFixed(2)} ($changeSymbol${changePercent.toStringAsFixed(2)}% $period)';
      final payload = 'portfolio:$totalValue:$changePercent';

      await _notifications.show(
        _generateNotificationId(),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            icon: '@mipmap/ic_launcher',
            color: changePercent >= 0 ? AppColors.bullish : AppColors.bearish,
            playSound: false,
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: false,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: payload,
      );

      _logger.info('Portfolio update notification sent');
    } catch (e) {
      _logger.error('Failed to show portfolio update notification: $e');
    }
  }

  /// Show connection status notification
  Future<void> showConnectionAlert({
    required bool isConnected,
    required String service,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const channelId = 'connection_alerts';
      const channelName = 'Connection Alerts';
      const channelDescription = 'Notifications for connection status';

      final title = isConnected ? 'Connected' : 'Connection Lost';
      final body = isConnected 
          ? '$service connection restored'
          : 'Lost connection to $service';
      final payload = 'connection:$service:$isConnected';

      await _notifications.show(
        _generateNotificationId(),
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: isConnected ? AppColors.bullish : AppColors.bearish,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        ),
        payload: payload,
      );

      _logger.info('Connection alert notification sent for $service');
    } catch (e) {
      _logger.error('Failed to show connection alert notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.info('All notifications cancelled');
    } catch (e) {
      _logger.error('Failed to cancel notifications: $e');
    }
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      _logger.info('Notification $id cancelled');
    } catch (e) {
      _logger.error('Failed to cancel notification $id: $e');
    }
  }

  /// Schedule periodic portfolio updates
  Future<void> schedulePeriodicUpdate({
    required Duration interval,
    required String timeOfDay,
  }) async {
    // This would implement scheduled notifications
    // For now, just log the intent
    _logger.info('Portfolio update scheduled for every ${interval.inHours} hours at $timeOfDay');
  }

  /// Generate unique notification ID
  int _generateNotificationId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      _logger.error('Failed to check notification status: $e');
      return false;
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      _logger.error('Failed to get pending notifications: $e');
      return [];
    }
  }
}
