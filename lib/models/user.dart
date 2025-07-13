/// Modelo básico de usuario para la aplicación
class User {
  final String id;
  final String email;
  final String? displayName;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    this.displayName,
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
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(
          json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      isEmailVerified: json['isEmailVerified'] ?? false,
    );
  }

  /// Todas las funciones están disponibles gratuitamente
  bool get hasActiveSubscription => true;
  bool get isPremium => true;
  bool get isPro => true;

  /// Obtiene el límite de alertas (sin límite ahora)
  int get alertLimit => -1; // Ilimitado para todos

  /// Verifica si puede usar plugins
  bool get canUsePlugins => true; // Todos pueden usar plugins

  /// Verifica si puede acceder a AI features
  bool get canUseAI => true; // Todos pueden usar AI

  /// Crea copia con modificaciones
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
