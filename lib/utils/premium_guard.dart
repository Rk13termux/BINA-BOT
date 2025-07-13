import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../models/subscription_plan.dart';

/// Utilidad para controlar el acceso a funciones premium
class PremiumGuard {
  /// Verificar si el usuario tiene acceso premium
  static bool isPremiumUser(BuildContext context) {
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      return subscriptionService.isSubscribed;
    } catch (e) {
      return false;
    }
  }

  /// Verificar si el usuario puede acceder a una función específica
  static bool canAccessFeature(BuildContext context, PremiumFeature feature) {
    if (!isPremiumUser(context)) {
      return _isFreeFeature(feature);
    }
    return true;
  }

  /// Obtener el plan actual del usuario
  static SubscriptionPlan getCurrentPlan(BuildContext context) {
    try {
      final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
      
      if (!subscriptionService.isSubscribed) {
        return SubscriptionPlan.free;
      }

      final activeId = subscriptionService.activeSubscriptionId;
      return SubscriptionPlan.getById(activeId!) ?? SubscriptionPlan.free;
    } catch (e) {
      return SubscriptionPlan.free;
    }
  }

  /// Verificar si una función es gratuita
  static bool _isFreeFeature(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.basicMarketData:
      case PremiumFeature.limitedNews:
      case PremiumFeature.basicAlerts:
      case PremiumFeature.standardPortfolio:
        return true;
      case PremiumFeature.realTimeData:
      case PremiumFeature.unlimitedNews:
      case PremiumFeature.advancedAlerts:
      case PremiumFeature.adFree:
      case PremiumFeature.emailNotifications:
      case PremiumFeature.tradingSignals:
      case PremiumFeature.portfolioTracking:
      case PremiumFeature.technicalIndicators:
      case PremiumFeature.prioritySupport:
      case PremiumFeature.advancedStrategies:
      case PremiumFeature.aiInsights:
      case PremiumFeature.customWatchlists:
      case PremiumFeature.exportData:
      case PremiumFeature.advancedAnalytics:
      case PremiumFeature.betaFeatures:
        return false;
    }
  }

  /// Mostrar diálogo de upgrade si el usuario no tiene acceso
  static void showUpgradeDialog(BuildContext context, {PremiumFeature? feature}) {
    showDialog(
      context: context,
      builder: (context) => _UpgradeDialog(feature: feature),
    );
  }

  /// Widget wrapper para funciones premium
  static Widget requiresPremium({
    required BuildContext context,
    required Widget child,
    required PremiumFeature feature,
    Widget? fallback,
  }) {
    if (canAccessFeature(context, feature)) {
      return child;
    }

    return fallback ?? _PremiumRequired(feature: feature);
  }

  /// Límites para usuarios gratuitos
  static int getFeatureLimit(PremiumFeature feature, bool isPremium) {
    if (isPremium) return -1; // Sin límite

    switch (feature) {
      case PremiumFeature.basicAlerts:
        return 5;
      case PremiumFeature.limitedNews:
        return 5;
      case PremiumFeature.customWatchlists:
        return 1;
      default:
        return 0;
    }
  }
}

/// Enum para las funciones premium
enum PremiumFeature {
  // Funciones gratuitas
  basicMarketData,
  limitedNews,
  basicAlerts,
  standardPortfolio,

  // Funciones premium
  realTimeData,
  unlimitedNews,
  advancedAlerts,
  adFree,
  emailNotifications,
  tradingSignals,
  portfolioTracking,
  technicalIndicators,
  prioritySupport,
  advancedStrategies,
  aiInsights,
  customWatchlists,
  exportData,
  advancedAnalytics,
  betaFeatures,
}

/// Widget que se muestra cuando se requiere premium
class _PremiumRequired extends StatelessWidget {
  final PremiumFeature feature;

  const _PremiumRequired({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium Feature',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getFeatureDescription(feature),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => PremiumGuard.showUpgradeDialog(context, feature: feature),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  String _getFeatureDescription(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.realTimeData:
        return 'Get real-time market data updates';
      case PremiumFeature.unlimitedNews:
        return 'Access unlimited news articles';
      case PremiumFeature.advancedAlerts:
        return 'Create unlimited advanced alerts';
      case PremiumFeature.tradingSignals:
        return 'Receive AI-powered trading signals';
      case PremiumFeature.technicalIndicators:
        return 'Use advanced technical indicators';
      case PremiumFeature.aiInsights:
        return 'Get AI-powered market insights';
      default:
        return 'This feature requires a premium subscription';
    }
  }
}

/// Diálogo de upgrade
class _UpgradeDialog extends StatelessWidget {
  final PremiumFeature? feature;

  const _UpgradeDialog({this.feature});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.star, color: Colors.orange),
          SizedBox(width: 8),
          Text('Upgrade to Premium'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feature != null) ...[
            Text(
              'This feature requires a premium subscription.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Choose your plan:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _PlanOption(plan: SubscriptionPlan.monthly),
          const SizedBox(height: 8),
          _PlanOption(plan: SubscriptionPlan.yearly, isRecommended: true),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Maybe Later'),
        ),
      ],
    );
  }
}

/// Opción de plan en el diálogo
class _PlanOption extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isRecommended;

  const _PlanOption({
    required this.plan,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? Colors.orange : Colors.grey,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(plan.name),
            if (isRecommended) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.displayPrice),
            if (plan.savings.isNotEmpty)
              Text(
                plan.savings,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () async {
          Navigator.of(context).pop();
          // Navegar a pantalla de suscripción
          Navigator.of(context).pushNamed('/subscription');
        },
      ),
    );
  }
}
