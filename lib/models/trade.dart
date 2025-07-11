/// Estados posibles de una orden de trading
enum TradeStatus {
  pending,
  filled,
  partiallyFilled,
  cancelled,
  rejected,
  expired,
}

/// Tipos de orden
enum OrderType {
  market,
  limit,
  stopLoss,
  stopLossLimit,
  takeProfit,
  takeProfitLimit,
}

/// Lado de la orden (compra o venta)
enum OrderSide {
  buy,
  sell,
}

/// Modelo para operaciones de trading
class Trade {
  final String id;
  final String symbol;
  final OrderSide side;
  final OrderType type;
  final double quantity;
  final double? price;
  final double? stopPrice;
  final TradeStatus status;
  final DateTime createdAt;
  final DateTime? filledAt;
  final double? filledPrice;
  final double? filledQuantity;
  final double? commission;
  final String? commissionAsset;
  final Map<String, dynamic> metadata;

  Trade({
    required this.id,
    required this.symbol,
    required this.side,
    required this.type,
    required this.quantity,
    this.price,
    this.stopPrice,
    required this.status,
    required this.createdAt,
    this.filledAt,
    this.filledPrice,
    this.filledQuantity,
    this.commission,
    this.commissionAsset,
    this.metadata = const {},
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side.name,
      'type': type.name,
      'quantity': quantity,
      'price': price,
      'stopPrice': stopPrice,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'filledAt': filledAt?.toIso8601String(),
      'filledPrice': filledPrice,
      'filledQuantity': filledQuantity,
      'commission': commission,
      'commissionAsset': commissionAsset,
      'metadata': metadata,
    };
  }

  /// Crea desde JSON
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      side: OrderSide.values.firstWhere(
        (e) => e.name == json['side'],
        orElse: () => OrderSide.buy,
      ),
      type: OrderType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderType.market,
      ),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num?)?.toDouble(),
      stopPrice: (json['stopPrice'] as num?)?.toDouble(),
      status: TradeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TradeStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      filledAt: json['filledAt'] != null ? DateTime.parse(json['filledAt']) : null,
      filledPrice: (json['filledPrice'] as num?)?.toDouble(),
      filledQuantity: (json['filledQuantity'] as num?)?.toDouble(),
      commission: (json['commission'] as num?)?.toDouble(),
      commissionAsset: json['commissionAsset'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Crea desde respuesta de Binance API
  factory Trade.fromBinanceOrder(Map<String, dynamic> order) {
    return Trade(
      id: order['orderId'].toString(),
      symbol: order['symbol'] ?? '',
      side: order['side']?.toString().toLowerCase() == 'buy' 
          ? OrderSide.buy 
          : OrderSide.sell,
      type: _parseOrderType(order['type']?.toString()),
      quantity: double.parse(order['origQty']?.toString() ?? '0'),
      price: order['price'] != null ? double.parse(order['price'].toString()) : null,
      stopPrice: order['stopPrice'] != null ? double.parse(order['stopPrice'].toString()) : null,
      status: _parseTradeStatus(order['status']?.toString()),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(order['time']?.toString() ?? '0')
      ),
      filledAt: order['updateTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(order['updateTime'].toString()))
          : null,
      filledPrice: order['cummulativeQuoteQty'] != null && order['executedQty'] != null
          ? double.parse(order['cummulativeQuoteQty'].toString()) / 
            double.parse(order['executedQty'].toString())
          : null,
      filledQuantity: order['executedQty'] != null 
          ? double.parse(order['executedQty'].toString()) 
          : null,
      commission: 0.0, // Se calculará por separado
      commissionAsset: null,
    );
  }

  /// Parsea el tipo de orden desde Binance
  static OrderType _parseOrderType(String? type) {
    switch (type?.toUpperCase()) {
      case 'MARKET':
        return OrderType.market;
      case 'LIMIT':
        return OrderType.limit;
      case 'STOP_LOSS':
        return OrderType.stopLoss;
      case 'STOP_LOSS_LIMIT':
        return OrderType.stopLossLimit;
      case 'TAKE_PROFIT':
        return OrderType.takeProfit;
      case 'TAKE_PROFIT_LIMIT':
        return OrderType.takeProfitLimit;
      default:
        return OrderType.market;
    }
  }

  /// Parsea el estado del trade desde Binance
  static TradeStatus _parseTradeStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'NEW':
        return TradeStatus.pending;
      case 'PARTIALLY_FILLED':
        return TradeStatus.partiallyFilled;
      case 'FILLED':
        return TradeStatus.filled;
      case 'CANCELED':
        return TradeStatus.cancelled;
      case 'REJECTED':
        return TradeStatus.rejected;
      case 'EXPIRED':
        return TradeStatus.expired;
      default:
        return TradeStatus.pending;
    }
  }

  /// Verifica si la orden está completada
  bool get isCompleted => status == TradeStatus.filled;

  /// Verifica si la orden está activa
  bool get isActive => status == TradeStatus.pending || status == TradeStatus.partiallyFilled;

  /// Calcula el valor total de la orden
  double? get totalValue {
    if (price == null) return null;
    return quantity * price!;
  }

  /// Calcula el valor ejecutado
  double? get executedValue {
    if (filledPrice == null || filledQuantity == null) return null;
    return filledQuantity! * filledPrice!;
  }

  /// Calcula el porcentaje ejecutado
  double get fillPercentage {
    if (filledQuantity == null) return 0.0;
    return (filledQuantity! / quantity) * 100;
  }

  /// Obtiene el color asociado al lado de la orden
  String get colorHex {
    switch (side) {
      case OrderSide.buy:
        return '#00FF88'; // Verde
      case OrderSide.sell:
        return '#FF4444'; // Rojo
    }
  }

  /// Obtiene el icono asociado al estado
  String get statusIcon {
    switch (status) {
      case TradeStatus.pending:
        return '⏳';
      case TradeStatus.filled:
        return '✅';
      case TradeStatus.partiallyFilled:
        return '🔄';
      case TradeStatus.cancelled:
        return '❌';
      case TradeStatus.rejected:
        return '⛔';
      case TradeStatus.expired:
        return '⏰';
    }
  }

  /// Crea copia con modificaciones
  Trade copyWith({
    String? id,
    String? symbol,
    OrderSide? side,
    OrderType? type,
    double? quantity,
    double? price,
    double? stopPrice,
    TradeStatus? status,
    DateTime? createdAt,
    DateTime? filledAt,
    double? filledPrice,
    double? filledQuantity,
    double? commission,
    String? commissionAsset,
    Map<String, dynamic>? metadata,
  }) {
    return Trade(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      stopPrice: stopPrice ?? this.stopPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      filledAt: filledAt ?? this.filledAt,
      filledPrice: filledPrice ?? this.filledPrice,
      filledQuantity: filledQuantity ?? this.filledQuantity,
      commission: commission ?? this.commission,
      commissionAsset: commissionAsset ?? this.commissionAsset,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Trade(id: $id, symbol: $symbol, side: ${side.name}, type: ${type.name}, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Trade && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
