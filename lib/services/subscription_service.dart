import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import '../utils/logger.dart';
import '../utils/constants.dart';

class SubscriptionService extends ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final AppLogger _logger = AppLogger();
  
  // Subscription product IDs (these should match your Play Store/App Store IDs)
  static const String premiumMonthlyId = 'invictus_premium_monthly';
  static const String premiumYearlyId = 'invictus_premium_yearly';
  static const String proMonthlyId = 'invictus_pro_monthly';
  static const String proYearlyId = 'invictus_pro_yearly';
  
  static const Set<String> _kProductIds = {
    premiumMonthlyId,
    premiumYearlyId,
    proMonthlyId,
    proYearlyId,
  };

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _isAvailable = false;
  bool _loading = false;

  // AdMob
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _loading;
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;

  // Initialize subscription service
  Future<void> initialize() async {
    try {
      _loading = true;
      
      // Initialize In-App Purchase
      _isAvailable = await _inAppPurchase.isAvailable();
      if (_isAvailable) {
        await _loadProducts();
        await _loadPurchases();
      }
      
      // Initialize AdMob
      await _initializeAdMob();
      
      _loading = false;
      _logger.info('Subscription service initialized successfully');
    } catch (e) {
      _loading = false;
      _logger.error('Failed to initialize subscription service: $e');
    }
  }

  // Load available products
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kProductIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        _logger.warning('Products not found: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      _logger.info('Loaded ${_products.length} products');
    } catch (e) {
      _logger.error('Failed to load products: $e');
    }
  }

  // Load existing purchases (simplified for demo)
  Future<void> _loadPurchases() async {
    try {
      // For demo purposes, we'll simulate past purchases
      // In a real app, you would query actual purchase history
      _purchases = [];
      _logger.info('Loaded ${_purchases.length} past purchases');
    } catch (e) {
      _logger.error('Failed to load purchases: $e');
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

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (success) {
        _logger.info('Purchase initiated for: $productId');
      }

      return success;
    } catch (e) {
      _logger.error('Purchase failed: $e');
      return false;
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      await _loadPurchases();
      _logger.info('Purchases restored');
    } catch (e) {
      _logger.error('Failed to restore purchases: $e');
    }
  }

  // Check if user has active subscription
  bool hasActiveSubscription(String tier) {
    for (final purchase in _purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        switch (tier) {
          case 'premium':
            return purchase.productID == premiumMonthlyId || 
                   purchase.productID == premiumYearlyId;
          case 'pro':
            return purchase.productID == proMonthlyId || 
                   purchase.productID == proYearlyId;
        }
      }
    }
    return false;
  }

  // Get subscription expiry date (simplified - in real app you'd need server verification)
  DateTime? getSubscriptionExpiry(String tier) {
    for (final purchase in _purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        bool isCorrectTier = false;
        bool isYearly = false;
        
        switch (tier) {
          case 'premium':
            isCorrectTier = purchase.productID == premiumMonthlyId || 
                           purchase.productID == premiumYearlyId;
            isYearly = purchase.productID == premiumYearlyId;
            break;
          case 'pro':
            isCorrectTier = purchase.productID == proMonthlyId || 
                           purchase.productID == proYearlyId;
            isYearly = purchase.productID == proYearlyId;
            break;
        }
        
        if (isCorrectTier) {
          // In a real app, you'd get this from receipt verification
          final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(purchase.transactionDate ?? '0') ?? 0
          );
          
          return isYearly 
              ? purchaseDate.add(const Duration(days: 365))
              : purchaseDate.add(const Duration(days: 30));
        }
      }
    }
    return null;
  }

  // AdMob methods
  Future<void> _initializeAdMob() async {
    try {
      await MobileAds.instance.initialize();
      await _loadBannerAd();
      await _loadInterstitialAd();
      await _loadRewardedAd();
      
      _logger.info('AdMob initialized successfully');
    } catch (e) {
      _logger.error('Failed to initialize AdMob: $e');
    }
  }

  Future<void> _loadBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? AppConstants.adMobBannerAndroid
          : AppConstants.adMobBannerIOS,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
          _logger.info('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, err) {
          _logger.error('Banner ad failed to load: $err');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    await _bannerAd!.load();
  }

  Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? AppConstants.adMobInterstitialAndroid
          : AppConstants.adMobInterstitialIOS,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _logger.info('Interstitial ad loaded');
          
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _logger.error('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: Platform.isAndroid
          ? AppConstants.adMobRewardedAndroid
          : AppConstants.adMobRewardedIOS,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _logger.info('Rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _logger.error('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          _logger.error('Interstitial ad failed to show: $error');
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      
      _interstitialAd!.show();
      _isInterstitialAdReady = false;
    }
  }

  void showRewardedAd({required Function(AdWithoutView, RewardItem) onRewarded}) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          _logger.error('Rewarded ad failed to show: $error');
          ad.dispose();
          _loadRewardedAd();
        },
      );
      
      _rewardedAd!.show(onUserEarnedReward: onRewarded);
      _isRewardedAdReady = false;
    }
  }

  // Dispose resources
  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
