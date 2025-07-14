import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Servicio de gestión de suscripciones
class SubscriptionService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  
  // Subscription states
  bool _isSubscribed = false;
  String _subscriptionTier = 'free';
  DateTime? _subscriptionExpiry;
  bool _isInitialized = false;
  
  // Subscription tiers
  static const String freeTier = 'free';
  static const String premiumTier = 'premium';
  static const String proTier = 'pro';
  
  // Feature limits
  final Map<String, Map<String, dynamic>> _tierLimits = {
    freeTier: {
      'alerts_limit': 5,
      'news_sources': 2,
      'real_time_data': false,
      'advanced_charts': false,
      'ai_predictions': false,
      'auto_trading': false,
      'ads_enabled': true,
    },
    premiumTier: {
      'alerts_limit': 25,
      'news_sources': 5,
      'real_time_data': true,
      'advanced_charts': true,
      'ai_predictions': false,
      'auto_trading': false,
      'ads_enabled': false,
    },
    proTier: {
      'alerts_limit': -1, // unlimited
      'news_sources': -1, // unlimited
      'real_time_data': true,
      'advanced_charts': true,
      'ai_predictions': true,
      'auto_trading': true,
      'ads_enabled': false,
    },
  };
  
  // Getters
  bool get isSubscribed => _isSubscribed;
  bool get isInitialized => _isInitialized;
  String get subscriptionTier => _subscriptionTier;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  bool get isPremium => _subscriptionTier == premiumTier || _subscriptionTier == proTier;
  bool get isPro => _subscriptionTier == proTier;
  bool get isFree => _subscriptionTier == freeTier;
  bool get adsEnabled => _tierLimits[_subscriptionTier]?['ads_enabled'] ?? true;
  
  /// Initialize subscription service
  Future<void> initialize() async {
    try {
      _logger.info('Initializing Subscription Service...');
      
      await _loadSubscriptionData();
      _checkSubscriptionExpiry();
      
      _isInitialized = true;
      _logger.info('Subscription Service initialized successfully');
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to initialize Subscription Service: $e');
      rethrow;
    }
  }
  
  /// Load subscription data from storage
  Future<void> _loadSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isSubscribed = prefs.getBool('is_subscribed') ?? false;
      _subscriptionTier = prefs.getString('subscription_tier') ?? freeTier;
      
      final expiryString = prefs.getString('subscription_expiry');
      if (expiryString != null) {
        _subscriptionExpiry = DateTime.tryParse(expiryString);
      }
      
      _logger.info('Loaded subscription data: tier=$_subscriptionTier, subscribed=$_isSubscribed');
    } catch (e) {
      _logger.error('Failed to load subscription data: $e');
      // Default to free tier on error
      _isSubscribed = false;
      _subscriptionTier = freeTier;
      _subscriptionExpiry = null;
    }
  }
  
  /// Save subscription data to storage
  Future<void> _saveSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('is_subscribed', _isSubscribed);
      await prefs.setString('subscription_tier', _subscriptionTier);
      
      if (_subscriptionExpiry != null) {
        await prefs.setString('subscription_expiry', _subscriptionExpiry!.toIso8601String());
      } else {
        await prefs.remove('subscription_expiry');
      }
      
      _logger.info('Saved subscription data');
    } catch (e) {
      _logger.error('Failed to save subscription data: $e');
    }
  }
  
  /// Check if subscription has expired
  void _checkSubscriptionExpiry() {
    if (_isSubscribed && _subscriptionExpiry != null) {
      if (DateTime.now().isAfter(_subscriptionExpiry!)) {
        _logger.info('Subscription expired, reverting to free tier');
        _downgradeToFree();
      }
    }
  }
  
  /// Upgrade to premium subscription
  Future<bool> upgradeToPremium({required Duration duration}) async {
    try {
      _logger.info('Upgrading to Premium subscription...');
      
      // Simulate subscription upgrade
      await Future.delayed(Duration(milliseconds: 500));
      
      _isSubscribed = true;
      _subscriptionTier = premiumTier;
      _subscriptionExpiry = DateTime.now().add(duration);
      
      await _saveSubscriptionData();
      
      _logger.info('Successfully upgraded to Premium');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.error('Failed to upgrade to Premium: $e');
      return false;
    }
  }
  
  /// Upgrade to pro subscription
  Future<bool> upgradeToPro({required Duration duration}) async {
    try {
      _logger.info('Upgrading to Pro subscription...');
      
      // Simulate subscription upgrade
      await Future.delayed(Duration(milliseconds: 500));
      
      _isSubscribed = true;
      _subscriptionTier = proTier;
      _subscriptionExpiry = DateTime.now().add(duration);
      
      await _saveSubscriptionData();
      
      _logger.info('Successfully upgraded to Pro');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.error('Failed to upgrade to Pro: $e');
      return false;
    }
  }
  
  /// Downgrade to free tier
  Future<void> _downgradeToFree() async {
    _isSubscribed = false;
    _subscriptionTier = freeTier;
    _subscriptionExpiry = null;
    
    await _saveSubscriptionData();
    notifyListeners();
  }
  
  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      _logger.info('Cancelling subscription...');
      
      // Simulate cancellation
      await Future.delayed(Duration(milliseconds: 300));
      
      await _downgradeToFree();
      
      _logger.info('Subscription cancelled successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to cancel subscription: $e');
      return false;
    }
  }
  
  /// Check if feature is available in current tier
  bool hasFeature(String feature) {
    final limits = _tierLimits[_subscriptionTier];
    if (limits == null) return false;
    
    return limits[feature] == true;
  }
  
  /// Get feature limit for current tier
  int getFeatureLimit(String feature) {
    final limits = _tierLimits[_subscriptionTier];
    if (limits == null) return 0;
    
    final limit = limits[feature];
    if (limit is int) return limit;
    if (limit is bool) return limit ? -1 : 0; // -1 = unlimited, 0 = disabled
    
    return 0;
  }
  
  /// Get subscription info
  Map<String, dynamic> getSubscriptionInfo() {
    return {
      'isSubscribed': _isSubscribed,
      'tier': _subscriptionTier,
      'expiry': _subscriptionExpiry?.toIso8601String(),
      'daysRemaining': _subscriptionExpiry?.difference(DateTime.now()).inDays,
      'features': _tierLimits[_subscriptionTier],
    };
  }
  
  /// Get subscription pricing
  static Map<String, dynamic> getPricing() {
    return {
      premiumTier: {
        'monthly': 9.99,
        'yearly': 99.99,
        'features': [
          'Real-time market data',
          'Advanced charts',
          'Up to 25 alerts',
          'No ads',
          'Email support',
        ],
      },
      proTier: {
        'monthly': 29.99,
        'yearly': 299.99,
        'features': [
          'Everything in Premium',
          'AI predictions',
          'Auto trading',
          'Unlimited alerts',
          'Priority support',
          'Advanced analytics',
        ],
      },
    };
  }
  
  /// Check if upgrade is needed for feature
  bool needsUpgradeFor(String feature) {
    return !hasFeature(feature);
  }
  
  /// Get recommended tier for feature
  String getRecommendedTierFor(String feature) {
    for (final tier in [proTier, premiumTier]) {
      final limits = _tierLimits[tier];
      if (limits?[feature] == true) {
        return tier;
      }
    }
    return freeTier;
  }
  
  /// Simulate trial subscription (for testing)
  Future<void> startTrialSubscription({String tier = premiumTier}) async {
    try {
      _logger.info('Starting trial subscription: $tier');
      
      _isSubscribed = true;
      _subscriptionTier = tier;
      _subscriptionExpiry = DateTime.now().add(Duration(days: 7)); // 7-day trial
      
      await _saveSubscriptionData();
      
      _logger.info('Trial subscription started');
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to start trial: $e');
    }
  }

  /// Restore purchases (for in-app purchases)
  Future<bool> restorePurchases() async {
    try {
      _logger.info('Restoring purchases...');
      
      // Simulate restore process
      await Future.delayed(Duration(milliseconds: 1000));
      
      // In a real app, this would check with the app store
      // For now, simulate a successful restore to premium
      if (!_isSubscribed) {
        await upgradeToPremium(duration: Duration(days: 30));
      }
      
      _logger.info('Purchases restored successfully');
      return true;
    } catch (e) {
      _logger.error('Failed to restore purchases: $e');
      return false;
    }
  }

  /// Purchase subscription
  Future<bool> purchaseSubscription(String productId) async {
    try {
      _logger.info('Purchasing subscription: $productId');
      
      // Simulate purchase process
      await Future.delayed(Duration(milliseconds: 1500));
      
      // Determine subscription type based on product ID
      if (productId.contains('premium')) {
        return await upgradeToPremium(duration: Duration(days: 30));
      } else if (productId.contains('pro')) {
        return await upgradeToPro(duration: Duration(days: 30));
      }
      
      return false;
    } catch (e) {
      _logger.error('Failed to purchase subscription: $e');
      return false;
    }
  }

  /// Get monthly subscription product ID
  String get monthlySubscriptionId {
    switch (_subscriptionTier) {
      case premiumTier:
        return 'premium_monthly';
      case proTier:
        return 'pro_monthly';
      default:
        return 'premium_monthly';
    }
  }

  /// Get yearly subscription product ID
  String get yearlySubscriptionId {
    switch (_subscriptionTier) {
      case premiumTier:
        return 'premium_yearly';
      case proTier:
        return 'pro_yearly';
      default:
        return 'premium_yearly';
    }
  }

}
