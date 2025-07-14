/// Modelo básico de usuario para la aplicación
class User {
  final String id;
  final String email;
  final String? displayName;
  final String subscriptionTier; // 'free', 'premium', 'pro'
  final DateTime? subscriptionExpiry;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.subscriptionTier = 'free',
    this.subscriptionExpiry,
    this.preferences = const {},
    required this.createdAt,
    required this.lastLoginAt,
    this.isEmailVerified = false,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'subscriptionTier': subscriptionTier,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Crea desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      subscriptionTier: json['subscriptionTier'] ?? 'free',
      subscriptionExpiry: json['subscriptionExpiry'] != null
          ? DateTime.parse(json['subscriptionExpiry'])
          : null,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(
          json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  /// Verifica si el usuario tiene suscripción activa
  bool get hasActiveSubscription {
    if (subscriptionTier == 'free') return false;
    if (subscriptionExpiry == null) return false;
    return DateTime.now().isBefore(subscriptionExpiry!);
  }

  /// Verifica si el usuario es premium
  bool get isPremium => subscriptionTier == 'premium' && hasActiveSubscription;

  /// Verifica si el usuario es pro
  bool get isPro => subscriptionTier == 'pro' && hasActiveSubscription;

  /// Obtiene el límite de alertas según el plan
  int get alertLimit {
    switch (subscriptionTier) {
      case 'premium':
        return 25;
      case 'pro':
        return -1; // Ilimitado
      default:
        return 5;
    }
  }

  /// Verifica si puede usar plugins
  bool get canUsePlugins => isPro;

  /// Verifica si puede acceder a AI features
  bool get canUseAI => isPremium || isPro;

  /// Crea copia con modificaciones
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? subscriptionTier,
    DateTime? subscriptionExpiry,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, tier: $subscriptionTier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
