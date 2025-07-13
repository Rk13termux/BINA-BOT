/// Modelo para manejar los planes de suscripción
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final Duration duration;
  final String displayPrice;
  final String savings;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.displayPrice,
    this.savings = '',
    required this.features,
    this.isPopular = false,
  });

  /// Plan mensual de $5 USD
  static const SubscriptionPlan monthly = SubscriptionPlan(
    id: 'invictus_monthly_5usd',
    name: 'Monthly Premium',
    description: 'Full access to all premium features',
    price: 5.0,
    duration: Duration(days: 30),
    displayPrice: '\$5.00/month',
    features: [
      'Real-time market data',
      'Unlimited news access',
      'Advanced alerts (unlimited)',
      'Ad-free experience',
      'Email notifications',
      'Basic trading signals',
      'Portfolio tracking',
      'Technical indicators',
    ],
  );

  /// Plan anual de $99 USD (ahorro de $1)
  static const SubscriptionPlan yearly = SubscriptionPlan(
    id: 'invictus_yearly_99usd',
    name: 'Yearly Premium',
    description: 'Best value! All premium features + priority support',
    price: 99.0,
    duration: Duration(days: 365),
    displayPrice: '\$99.00/year',
    savings: 'Save \$1 vs Monthly',
    isPopular: true,
    features: [
      'Everything in Monthly Premium',
      'Priority customer support',
      'Advanced trading strategies',
      'AI-powered insights',
      'Custom watchlists',
      'Export data functionality',
      'Advanced portfolio analytics',
      'Beta features access',
    ],
  );

  /// Plan gratuito
  static const SubscriptionPlan free = SubscriptionPlan(
    id: 'free',
    name: 'Free',
    description: 'Basic trading features',
    price: 0.0,
    duration: Duration(days: 365 * 100), // Prácticamente infinito
    displayPrice: 'Free',
    features: [
      'Basic market data',
      'Limited news access (5 articles/day)',
      'Basic alerts (5 max)',
      'Standard portfolio tracking',
    ],
  );

  /// Lista de todos los planes disponibles
  static const List<SubscriptionPlan> allPlans = [
    free,
    monthly,
    yearly,
  ];

  /// Obtener plan por ID
  static SubscriptionPlan? getById(String id) {
    try {
      return allPlans.firstWhere((plan) => plan.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Calcular precio mensual equivalente
  double get monthlyEquivalentPrice {
    if (duration.inDays <= 30) {
      return price;
    } else {
      return price / (duration.inDays / 30);
    }
  }

  /// Verificar si es un plan premium
  bool get isPremium => price > 0;

  /// Descripción del ahorro anual
  String get yearlyEquivalentSavings {
    if (duration.inDays >= 365) return '';
    
    final yearlyPrice = price * 12;
    final actualYearlyPrice = yearly.price;
    final savings = yearlyPrice - actualYearlyPrice;
    
    return savings > 0 ? 'Save \$${savings.toStringAsFixed(0)} with yearly plan' : '';
  }

  @override
  String toString() {
    return 'SubscriptionPlan(id: $id, name: $name, price: $price, duration: ${duration.inDays} days)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionPlan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
