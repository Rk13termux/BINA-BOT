/// Tipos de señales de trading
enum SignalType {
  buy,
  sell,
  hold,
  warning,
}

/// Niveles de confianza de la señal
enum ConfidenceLevel {
  low,
  medium,
  high,
  veryHigh,
}

/// Modelo para señales de trading
class Signal {
  final String id;
  final String symbol;
  final SignalType type;
  final double price;
  final ConfidenceLevel confidence;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final String? source; // plugin, TA, AI, manual
  final double? targetPrice;
  final double? stopLoss;

  Signal({
    required this.id,
    required this.symbol,
    required this.type,
    required this.price,
    required this.confidence,
    required this.reason,
    required this.timestamp,
    this.metadata = const {},
    this.source,
    this.targetPrice,
    this.stopLoss,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type.name,
      'price': price,
      'confidence': confidence.name,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'source': source,
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
    };
  }

  /// Crea desde JSON
  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      type: SignalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SignalType.hold,
      ),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      confidence: ConfidenceLevel.values.firstWhere(
        (e) => e.name == json['confidence'],
        orElse: () => ConfidenceLevel.low,
      ),
      reason: json['reason'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      source: json['source'],
      targetPrice: (json['targetPrice'] as num?)?.toDouble(),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
    );
  }

  /// Calcula el potencial de ganancia
  double? get potentialProfit {
    if (targetPrice == null) return null;
    
    switch (type) {
      case SignalType.buy:
        return ((targetPrice! - price) / price) * 100;
      case SignalType.sell:
        return ((price - targetPrice!) / price) * 100;
      default:
        return null;
    }
  }

  /// Calcula el riesgo potencial
  double? get potentialLoss {
    if (stopLoss == null) return null;
    
    switch (type) {
      case SignalType.buy:
        return ((price - stopLoss!) / price) * 100;
      case SignalType.sell:
        return ((stopLoss! - price) / price) * 100;
      default:
        return null;
    }
  }

  /// Calcula la relación riesgo/beneficio
  double? get riskRewardRatio {
    final profit = potentialProfit;
    final loss = potentialLoss;
    
    if (profit == null || loss == null || loss == 0) return null;
    
    return profit / loss;
  }

  /// Verifica si la señal está vencida
  bool get isExpired {
    final now = DateTime.now();
    final ageInHours = now.difference(timestamp).inHours;
    
    // Las señales expiran después de 24 horas por defecto
    return ageInHours > 24;
  }

  /// Obtiene el color asociado al tipo de señal
  String get colorHex {
    switch (type) {
      case SignalType.buy:
        return '#00FF88'; // Verde
      case SignalType.sell:
        return '#FF4444'; // Rojo
      case SignalType.warning:
        return '#FFB800'; // Amarillo/Dorado
      case SignalType.hold:
        return '#888888'; // Gris
    }
  }

  /// Obtiene el icono asociado al tipo de señal
  String get icon {
    switch (type) {
      case SignalType.buy:
        return '📈';
      case SignalType.sell:
        return '📉';
      case SignalType.warning:
        return '⚠️';
      case SignalType.hold:
        return '⏸️';
    }
  }

  /// Crea copia con modificaciones
  Signal copyWith({
    String? id,
    String? symbol,
    SignalType? type,
    double? price,
    ConfidenceLevel? confidence,
    String? reason,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? source,
    double? targetPrice,
    double? stopLoss,
  }) {
    return Signal(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      type: type ?? this.type,
      price: price ?? this.price,
      confidence: confidence ?? this.confidence,
      reason: reason ?? this.reason,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      source: source ?? this.source,
      targetPrice: targetPrice ?? this.targetPrice,
      stopLoss: stopLoss ?? this.stopLoss,
    );
  }

  @override
  String toString() {
    return 'Signal(symbol: $symbol, type: ${type.name}, price: $price, confidence: ${confidence.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Signal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
