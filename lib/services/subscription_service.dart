import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/logger.dart';

class SubscriptionService extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final AppLogger _logger = AppLogger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Subscription product IDs - Dos planes únicos
  static const String monthlySubscriptionId = 'invictus_monthly_5usd';
  static const String yearlySubscriptionId = 'invictus_yearly_100usd';

  static const Set<String> _kProductIds = {
    monthlySubscriptionId,
    yearlySubscriptionId,
  };

  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _loading = false;
  bool _isSubscribed = false;
  String? _activeSubscriptionId;
  DateTime? _subscriptionExpiry;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _loading;
  bool get isSubscribed => _isSubscribed;
  String? get activeSubscriptionId => _activeSubscriptionId;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  
  // Pricing information
  String get monthlyPrice => '\$5.00/month';
  String get yearlyPrice => '\$100.00/year';
  String get yearlySavings => 'Save \$60 (50% off)';
  String get monthlyDescription => 'Full access to all premium features';
  String get yearlyDescription => 'Best value! All premium features + priority support';

  // Initialize subscription service
  Future<void> initialize() async {
    try {
      _loading = true;
      notifyListeners();

      // Initialize In-App Purchase
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (_isAvailable) {
        await _loadProducts();
        await _loadPurchases();
        await _checkSubscriptionStatus();
      }

      _loading = false;
      notifyListeners();
      _logger.info('Subscription service initialized successfully');
    } catch (e) {
      _loading = false;
      notifyListeners();
      _logger.error('Failed to initialize subscription service: $e');
    }
  }

  // Load available products
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_kProductIds);

      if (response.notFoundIDs.isNotEmpty) {
        _logger.warning('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      _logger.info('Loaded ${_products.length} products');
    } catch (e) {
      _logger.error('Failed to load products: $e');
    }
  }

  // Load existing purchases
  Future<void> _loadPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      // Note: Purchase updates are received through the purchaseStream
      _logger.info('Restore purchases initiated');
    } catch (e) {
      _logger.error('Failed to load purchases: $e');
    }
  }

  // Check subscription status
  Future<void> _checkSubscriptionStatus() async {
    try {
      // Check stored subscription data
      final storedSubscription = await _secureStorage.read(key: 'active_subscription');
      final storedExpiry = await _secureStorage.read(key: 'subscription_expiry');
      
      if (storedSubscription != null && storedExpiry != null) {
        _activeSubscriptionId = storedSubscription;
        _subscriptionExpiry = DateTime.parse(storedExpiry);
        
        // Check if subscription is still valid
        if (_subscriptionExpiry!.isAfter(DateTime.now())) {
          _isSubscribed = true;
        } else {
          // Subscription expired
          await _clearSubscriptionData();
        }
      }

      // Also check active purchases
      for (final purchase in _purchases) {
        if (purchase.status == PurchaseStatus.purchased && 
            _kProductIds.contains(purchase.productID)) {
          _isSubscribed = true;
          _activeSubscriptionId = purchase.productID;
          await _saveSubscriptionData(purchase.productID);
          break;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to check subscription status: $e');
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    try {
      if (!_isAvailable) {
        _logger.error('In-app purchases not available');
        return false;
      }

      final ProductDetails? productDetails = _products
          .cast<ProductDetails?>()
          .firstWhere(
            (product) => product?.id == productId,
            orElse: () => null,
          );

      if (productDetails == null) {
        _logger.error('Product not found: $productId');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      _loading = true;
      notifyListeners();

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      _loading = false;
      notifyListeners();

      if (success) {
        _logger.info('Purchase initiated for: $productId');
        return true;
      } else {
        _logger.error('Failed to initiate purchase for: $productId');
        return false;
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      _logger.error('Purchase failed: $e');
      return false;
    }
  }

  // Save subscription data securely
  Future<void> _saveSubscriptionData(String subscriptionId) async {
    try {
      await _secureStorage.write(key: 'active_subscription', value: subscriptionId);
      
      // Calculate expiry date
      DateTime expiry;
      if (subscriptionId == monthlySubscriptionId) {
        expiry = DateTime.now().add(const Duration(days: 30));
      } else {
        expiry = DateTime.now().add(const Duration(days: 365));
      }
      
      await _secureStorage.write(key: 'subscription_expiry', value: expiry.toIso8601String());
      _subscriptionExpiry = expiry;
      _activeSubscriptionId = subscriptionId;
      _isSubscribed = true;
      
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to save subscription data: $e');
    }
  }

  // Clear subscription data
  Future<void> _clearSubscriptionData() async {
    try {
      await _secureStorage.delete(key: 'active_subscription');
      await _secureStorage.delete(key: 'subscription_expiry');
      _activeSubscriptionId = null;
      _subscriptionExpiry = null;
      _isSubscribed = false;
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to clear subscription data: $e');
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      _loading = true;
      notifyListeners();

      await _inAppPurchase.restorePurchases();
      await _loadPurchases();
      await _checkSubscriptionStatus();

      _loading = false;
      notifyListeners();
      
      _logger.info('Purchases restored successfully');
      return true;
    } catch (e) {
      _loading = false;
      notifyListeners();
      _logger.error('Failed to restore purchases: $e');
      return false;
    }
  }

  // Get product details by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Check if user has premium features
  bool get hasPremiumFeatures => _isSubscribed;

  // Get subscription type
  String get subscriptionType {
    if (!_isSubscribed) return 'Free';
    if (_activeSubscriptionId == monthlySubscriptionId) return 'Monthly Premium';
    if (_activeSubscriptionId == yearlySubscriptionId) return 'Yearly Premium';
    return 'Premium';
  }

  // Get days remaining
  int get daysRemaining {
    if (!_isSubscribed || _subscriptionExpiry == null) return 0;
    final difference = _subscriptionExpiry!.difference(DateTime.now());
    return difference.inDays.clamp(0, 365);
  }
}
