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
      'successRate': successRate,
      'executionCount': executionCount,
    };
  }

  /// Crea desde JSON
  factory Plugin.fromJson(Map<String, dynamic> json) {
    return Plugin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '1.0.0',
      type: PluginType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PluginType.strategy,
      ),
      status: PluginStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PluginStatus.inactive,
      ),
      author: json['author'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      configuration: Map<String, dynamic>.from(json['configuration'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      supportedSymbols: List<String>.from(json['supportedSymbols'] ?? []),
      successRate: (json['successRate'] as num?)?.toDouble(),
      executionCount: json['executionCount'],
    );
  }

  /// Crea desde configuración JSON de estrategia
  factory Plugin.fromStrategyJson(Map<String, dynamic> strategyJson) {
    return Plugin(
      id: strategyJson['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: strategyJson['name'] ?? 'Custom Strategy',
      description: strategyJson['description'] ?? 'User defined strategy',
      version: strategyJson['version'] ?? '1.0.0',
      type: PluginType.strategy,
      author: strategyJson['author'] ?? 'User',
      createdAt: DateTime.now(),
      configuration: strategyJson,
      supportedSymbols: List<String>.from(strategyJson['symbols'] ?? ['BTCUSDT']),
    );
  }

  /// Verifica si el plugin está activo
  bool get isActive => status == PluginStatus.active;

  /// Verifica si el plugin tiene errores
  bool get hasError => status == PluginStatus.error;

  /// Obtiene el icono del tipo de plugin
  String get typeIcon {
    switch (type) {
      case PluginType.strategy:
        return '🎯';
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
    }
  }

  /// Obtiene el rating basado en success rate
  int get rating {
    if (successRate == null) return 0;
    if (successRate! >= 80) return 5;
    if (successRate! >= 60) return 4;
    if (successRate! >= 40) return 3;
    if (successRate! >= 20) return 2;
    return 1;
  }

  /// Verifica si soporta un símbolo específico
  bool supportsSymbol(String symbol) {
    if (supportedSymbols.isEmpty) return true; // Soporta todos por defecto
    return supportedSymbols.contains(symbol.toUpperCase());
  }

  /// Obtiene parámetros de configuración
  T? getConfigValue<T>(String key, [T? defaultValue]) {
    final value = configuration[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Actualiza parámetro de configuración
  Plugin updateConfig(String key, dynamic value) {
    final newConfig = Map<String, dynamic>.from(configuration);
    newConfig[key] = value;
    
    return copyWith(
      configuration: newConfig,
      updatedAt: DateTime.now(),
    );
  }

  /// Crea copia con modificaciones
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
      successRate: successRate ?? this.successRate,
      executionCount: executionCount ?? this.executionCount,
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
