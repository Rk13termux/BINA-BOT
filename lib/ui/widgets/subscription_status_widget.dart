import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';
import '../../utils/premium_guard.dart';

/// Widget que muestra el estado de suscripción del usuario
class SubscriptionStatusWidget extends StatelessWidget {
  final bool showUpgradeButton;
  final EdgeInsets padding;

  const SubscriptionStatusWidget({
    super.key,
    this.showUpgradeButton = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        if (subscriptionService.isLoading) {
          return Container(
            padding: padding,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentPlan = PremiumGuard.getCurrentPlan(context);
        final isSubscribed = subscriptionService.isSubscribed;

        return Container(
          margin: const EdgeInsets.all(8),
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSubscribed
                  ? [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.2)]
                  : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSubscribed ? Colors.orange : Colors.grey,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    isSubscribed ? Icons.stars : Icons.star_border,
                    color: isSubscribed ? Colors.orange : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSubscribed ? 'Premium Active' : 'Free Plan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSubscribed ? Colors.orange : Colors.grey[300],
                          ),
                        ),
                        Text(
                          currentPlan.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isSubscribed && showUpgradeButton)
                    _buildUpgradeButton(context),
                ],
              ),
              
              if (isSubscribed) ...[
                const SizedBox(height: 12),
                _buildSubscriptionDetails(subscriptionService),
              ],

              if (!isSubscribed) ...[
                const SizedBox(height: 12),
                _buildFreeUserBenefits(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pushNamed('/subscription'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: const Text(
        'Upgrade',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSubscriptionDetails(SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[400],
            ),
            const SizedBox(width: 4),
            Text(
              subscriptionService.daysRemaining > 0
                  ? '${subscriptionService.daysRemaining} days remaining'
                  : 'Subscription expires soon',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildFeatureChip('Real-time data', true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFeatureChip('Unlimited alerts', true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFreeUserBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureChip('5 alerts max', false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFeatureChip('Basic data', false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upgrade for unlimited alerts, real-time data, and more!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.orange.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.orange.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: isActive ? Colors.orange : Colors.grey[400],
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Widget compacto para mostrar solo el estado premium
class PremiumBadge extends StatelessWidget {
  final bool showText;
  
  const PremiumBadge({super.key, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, child) {
        if (!subscriptionService.isSubscribed) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.deepOrange],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.stars,
                size: 16,
                color: Colors.white,
              ),
              if (showText) ...[
                const SizedBox(width: 4),
                const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Widget que requiere premium para mostrar contenido
class PremiumContentWrapper extends StatelessWidget {
  final Widget child;
  final Widget? fallback;
  final PremiumFeature feature;

  const PremiumContentWrapper({
    super.key,
    required this.child,
    required this.feature,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumGuard.requiresPremium(
      context: context,
      child: child,
      feature: feature,
      fallback: fallback,
    );
  }
}
