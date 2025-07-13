import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription_plan.dart';
import '../../utils/premium_guard.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SubscriptionService>(
        builder: (context, subscriptionService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(subscriptionService),
                const SizedBox(height: 32),

                // Current Status
                if (subscriptionService.isSubscribed) ...[
                  _buildCurrentPlan(subscriptionService),
                  const SizedBox(height: 24),
                ],

                // Plan Options
                _buildPlanOptions(subscriptionService),
                const SizedBox(height: 24),

                // Features Comparison
                _buildFeaturesComparison(),
                const SizedBox(height: 24),

                // Restore Purchases Button
                _buildRestorePurchasesButton(subscriptionService),
                const SizedBox(height: 16),

                // Terms and Privacy
                _buildTermsAndPrivacy(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SubscriptionService subscriptionService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.stars,
              color: Colors.orange,
              size: 32,
            ),
            SizedBox(width: 12),
            Text(
              'Unlock Premium Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Get full access to professional trading tools and real-time market data',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPlan(SubscriptionService subscriptionService) {
    final currentPlan = PremiumGuard.getCurrentPlan(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Plan: ${currentPlan.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (subscriptionService.daysRemaining > 0)
                  Text(
                    '${subscriptionService.daysRemaining} days remaining',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions(SubscriptionService subscriptionService) {
    return Column(
      children: [
        // Free Plan
        _buildPlanCard(
          plan: SubscriptionPlan.free,
          isCurrentPlan: !subscriptionService.isSubscribed,
          onTap: null, // Free plan is already active
        ),
        const SizedBox(height: 16),

        // Monthly Plan
        _buildPlanCard(
          plan: SubscriptionPlan.monthly,
          isCurrentPlan: subscriptionService.activeSubscriptionId == SubscriptionPlan.monthly.id,
          onTap: () => _purchasePlan(SubscriptionPlan.monthly, subscriptionService),
        ),
        const SizedBox(height: 16),

        // Yearly Plan (Recommended)
        _buildPlanCard(
          plan: SubscriptionPlan.yearly,
          isCurrentPlan: subscriptionService.activeSubscriptionId == SubscriptionPlan.yearly.id,
          isRecommended: true,
          onTap: () => _purchasePlan(SubscriptionPlan.yearly, subscriptionService),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required bool isCurrentPlan,
    bool isRecommended = false,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null && !isCurrentPlan && !_isLoading;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border.all(
          color: isRecommended
              ? Colors.orange
              : isCurrentPlan
                  ? Colors.green
                  : Colors.grey[700]!,
          width: isRecommended || isCurrentPlan ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Recommended Badge
          if (isRecommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'BEST VALUE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Current Plan Badge
          if (isCurrentPlan)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name and Price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.displayPrice,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (plan.savings.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              plan.savings,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),

                // Features (show first 4)
                ...plan.features.take(4).map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: plan.isPremium ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                if (plan.features.length > 4) ...[
                  Text(
                    '+${plan.features.length - 4} more features',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Button
                if (onTap != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isEnabled ? onTap : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended ? Colors.orange : Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isCurrentPlan ? 'Current Plan' : 'Choose Plan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildFeatureRow('Real-time market data', false, true, true),
              _buildFeatureRow('News articles', '5/day', 'Unlimited', 'Unlimited'),
              _buildFeatureRow('Alerts', '5 max', 'Unlimited', 'Unlimited'),
              _buildFeatureRow('Ad-free experience', false, true, true),
              _buildFeatureRow('Trading signals', false, true, true),
              _buildFeatureRow('Priority support', false, false, true),
              _buildFeatureRow('AI insights', false, false, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String feature, dynamic free, dynamic monthly, dynamic yearly) {
    Widget buildCell(dynamic value) {
      if (value is bool) {
        return Icon(
          value ? Icons.check : Icons.close,
          color: value ? Colors.green : Colors.red,
          size: 16,
        );
      }
      return Text(
        value.toString(),
        style: TextStyle(color: Colors.grey[300], fontSize: 12),
        textAlign: TextAlign.center,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
          ),
          Expanded(child: buildCell(free)),
          Expanded(child: buildCell(monthly)),
          Expanded(child: buildCell(yearly)),
        ],
      ),
    );
  }

  Widget _buildRestorePurchasesButton(SubscriptionService subscriptionService) {
    return Center(
      child: TextButton(
        onPressed: subscriptionService.isLoading
            ? null
            : () async {
                setState(() => _isLoading = true);
                try {
                  await subscriptionService.restorePurchases();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Purchases restored successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to restore purchases: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
        child: const Text(
          'Restore Purchases',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'By subscribing, you agree to our ',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Open terms of service
            },
            child: const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            ' and ',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Open privacy policy
            },
            child: const Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePlan(SubscriptionPlan plan, SubscriptionService subscriptionService) async {
    setState(() => _isLoading = true);

    try {
      final success = await subscriptionService.purchaseSubscription(plan.id);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully subscribed to ${plan.name}!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or to dashboard
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
