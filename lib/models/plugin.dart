/// Tipos de plugin disponibles
enum PluginType {
  strategy,
  indicator,
  alert,
  automation,
}

/// Estados del plugin
enum PluginStatus {
  active,
  inactive,
  error,
  loading,
  available,
  installed,
}

/// Categorías de plugins
enum PluginCategory {
  trading,
  analysis,
  automation,
  alerts,
  indicators,
  strategies,
}

/// Permisos de plugins
enum PluginPermission {
  readMarketData,
  executeTrades,
  accessAPI,
  sendNotifications,
  accessStorage,
}

/// Modelo para plugins de estrategias de trading
class Plugin {
  final String id;
  final String name;
  final String description;
  final String version;
  final PluginType type;
  final PluginStatus status;
  final String author;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> configuration;
  final Map<String, dynamic> metadata;
  final List<String> supportedSymbols;
  final String code;
  final PluginCategory category;
  final List<PluginPermission> permissions;
  final double? successRate;
  final int? executionCount;

  Plugin({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.type,
    this.status = PluginStatus.inactive,
    required this.author,
    required this.createdAt,
    this.updatedAt,
    this.configuration = const {},
    this.metadata = const {},
    this.supportedSymbols = const [],
    required this.code,
    required this.category,
    this.permissions = const [],
    this.successRate,
    this.executionCount,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'type': type.name,
      'status': status.name,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'configuration': configuration,
      'metadata': metadata,
      'supportedSymbols': supportedSymbols,
      'code': code,
      'category': category.name,
      'permissions': permissions.map((p) => p.name).toList(),
      'successRate': successRate,
      'executionCount': executionCount,
    };
  }

  /// Crea desde JSON
  factory Plugin.fromJson(Map<String, dynamic> json) {
    return Plugin(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      version: json['version'] as String,
      type: PluginType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PluginType.strategy,
      ),
      status: PluginStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PluginStatus.inactive,
      ),
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      supportedSymbols: List<String>.from(json['supportedSymbols'] ?? []),
      code: json['code'] as String? ?? '',
      category: PluginCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => PluginCategory.trading,
      ),
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((p) => PluginPermission.values.firstWhere(
                    (perm) => perm.name == p,
                    orElse: () => PluginPermission.readMarketData,
                  ))
              .toList() ??
          [],
      successRate: (json['successRate'] as num?)?.toDouble(),
      executionCount: json['executionCount'] as int?,
    );
  }

  /// Copia con nuevos valores
  Plugin copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    PluginType? type,
    PluginStatus? status,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? configuration,
    Map<String, dynamic>? metadata,
    List<String>? supportedSymbols,
    String? code,
    PluginCategory? category,
    List<PluginPermission>? permissions,
    double? successRate,
    int? executionCount,
  }) {
    return Plugin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      type: type ?? this.type,
      status: status ?? this.status,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      configuration: configuration ?? this.configuration,
      metadata: metadata ?? this.metadata,
      supportedSymbols: supportedSymbols ?? this.supportedSymbols,
      code: code ?? this.code,
      category: category ?? this.category,
      permissions: permissions ?? this.permissions,
      successRate: successRate ?? this.successRate,
      executionCount: executionCount ?? this.executionCount,
    );
  }

  /// Obtiene el icono según el tipo
  String get typeIcon {
    switch (type) {
      case PluginType.strategy:
        return '📈';
      case PluginType.indicator:
        return '📊';
      case PluginType.alert:
        return '🔔';
      case PluginType.automation:
        return '🤖';
    }
  }

  /// Obtiene el color del estado
  String get statusColor {
    switch (status) {
      case PluginStatus.active:
        return '#00FF88';
      case PluginStatus.inactive:
        return '#888888';
      case PluginStatus.error:
        return '#FF4444';
      case PluginStatus.loading:
        return '#FFB800';
      case PluginStatus.available:
        return '#2196F3';
      case PluginStatus.installed:
        return '#4CAF50';
    }
  }

  /// Obtiene la descripción del estado
  String get statusDescription {
    switch (status) {
      case PluginStatus.active:
        return 'Running';
      case PluginStatus.inactive:
        return 'Stopped';
      case PluginStatus.error:
        return 'Error';
      case PluginStatus.loading:
        return 'Loading';
      case PluginStatus.available:
        return 'Available';
      case PluginStatus.installed:
        return 'Installed';
    }
  }

  /// Obtiene el rating basado en el successRate
  int get rating {
    if (successRate == null) return 0;
    if (successRate! >= 80) return 5;
    if (successRate! >= 60) return 4;
    if (successRate! >= 40) return 3;
    if (successRate! >= 20) return 2;
    return 1;
  }

  /// Verifica si el plugin soporta un símbolo específico
  bool supportsSymbol(String symbol) {
    if (supportedSymbols.isEmpty) return true; // Soporta todos por defecto
    return supportedSymbols.contains(symbol.toUpperCase());
  }

  /// Obtiene un valor de configuración
  T? getConfigValue<T>(String key) {
    final value = configuration[key];
    return value is T ? value : null;
  }

  /// Actualiza la configuración
  Plugin updateConfiguration(String key, dynamic value) {
    final newConfig = Map<String, dynamic>.from(configuration);
    newConfig[key] = value;

    return copyWith(
      configuration: newConfig,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Plugin(id: $id, name: $name, type: ${type.name}, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plugin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
