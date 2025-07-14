/// Modelos para manejo de órdenes en Binance
library;

/// Tipos de orden disponibles
enum OrderType {
  limit('LIMIT'),
  market('MARKET'),
  stopLoss('STOP_LOSS'),
  stopLossLimit('STOP_LOSS_LIMIT'),
  takeProfit('TAKE_PROFIT'),
  takeProfitLimit('TAKE_PROFIT_LIMIT'),
  limitMaker('LIMIT_MAKER');

  const OrderType(this.value);
  final String value;

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrderType.market,
    );
  }
}

/// Lado de la orden (compra/venta)
enum OrderSide {
  buy('BUY'),
  sell('SELL');

  const OrderSide(this.value);
  final String value;

  static OrderSide fromString(String value) {
    return OrderSide.values.firstWhere(
      (side) => side.value == value,
      orElse: () => OrderSide.buy,
    );
  }
}

/// Tiempo en vigor de la orden
enum TimeInForce {
  goodTillCanceled('GTC'),
  immediateOrCancel('IOC'),
  fillOrKill('FOK');

  const TimeInForce(this.value);
  final String value;

  static TimeInForce fromString(String value) {
    return TimeInForce.values.firstWhere(
      (tif) => tif.value == value,
      orElse: () => TimeInForce.goodTillCanceled,
    );
  }
}

/// Estado de la orden
enum OrderStatus {
  newOrder('NEW'),
  partiallyFilled('PARTIALLY_FILLED'),
  filled('FILLED'),
  canceled('CANCELED'),
  pendingCancel('PENDING_CANCEL'),
  rejected('REJECTED'),
  expired('EXPIRED'),
  expiredInMatch('EXPIRED_IN_MATCH');

  const OrderStatus(this.value);
  final String value;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.newOrder,
    );
  }
}

/// Request para crear una orden
class OrderRequest {
  final String symbol;
  final OrderSide side;
  final OrderType type;
  final TimeInForce? timeInForce;
  final double? quantity;
  final double? quoteOrderQty;
  final double? price;
  final String? newClientOrderId;
  final double? stopPrice;
  final double? icebergQty;
  final String? newOrderRespType;

  OrderRequest({
    required this.symbol,
    required this.side,
    required this.type,
    this.timeInForce,
    this.quantity,
    this.quoteOrderQty,
    this.price,
    this.newClientOrderId,
    this.stopPrice,
    this.icebergQty,
    this.newOrderRespType,
  });

  /// Validar parámetros de la orden
  bool isValid() {
    // Validaciones básicas
    if (symbol.isEmpty) return false;

    // Para órdenes LIMIT y STOP_LOSS_LIMIT, el precio es requerido
    if ((type == OrderType.limit ||
            type == OrderType.stopLossLimit ||
            type == OrderType.takeProfitLimit) &&
        price == null) {
      return false;
    }

    // Para órdenes STOP_LOSS y STOP_LOSS_LIMIT, stopPrice es requerido
    if ((type == OrderType.stopLoss || type == OrderType.stopLossLimit) &&
        stopPrice == null) {
      return false;
    }

    // Cantidad debe ser especificada (quantity o quoteOrderQty)
    if (quantity == null && quoteOrderQty == null) return false;

    return true;
  }

  /// Convertir a JSON para envío a API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'symbol': symbol.toUpperCase(),
      'side': side.value,
      'type': type.value,
    };

    if (timeInForce != null) json['timeInForce'] = timeInForce!.value;
    if (quantity != null) json['quantity'] = quantity.toString();
    if (quoteOrderQty != null) json['quoteOrderQty'] = quoteOrderQty.toString();
    if (price != null) json['price'] = price.toString();
    if (newClientOrderId != null) json['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) json['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) json['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) json['newOrderRespType'] = newOrderRespType;

    return json;
  }

  /// Crear orden de mercado de compra
  factory OrderRequest.marketBuy({
    required String symbol,
    required double quantity,
    String? clientOrderId,
  }) {
    return OrderRequest(
      symbol: symbol,
      side: OrderSide.buy,
      type: OrderType.market,
      quantity: quantity,
      newClientOrderId: clientOrderId,
    );
  }

  /// Crear orden de mercado de venta
  factory OrderRequest.marketSell({
    required String symbol,
    required double quantity,
    String? clientOrderId,
  }) {
    return OrderRequest(
      symbol: symbol,
      side: OrderSide.sell,
      type: OrderType.market,
      quantity: quantity,
      newClientOrderId: clientOrderId,
    );
  }

  /// Crear orden límite de compra
  factory OrderRequest.limitBuy({
    required String symbol,
    required double quantity,
    required double price,
    TimeInForce timeInForce = TimeInForce.goodTillCanceled,
    String? clientOrderId,
  }) {
    return OrderRequest(
      symbol: symbol,
      side: OrderSide.buy,
      type: OrderType.limit,
      quantity: quantity,
      price: price,
      timeInForce: timeInForce,
      newClientOrderId: clientOrderId,
    );
  }

  /// Crear orden límite de venta
  factory OrderRequest.limitSell({
    required String symbol,
    required double quantity,
    required double price,
    TimeInForce timeInForce = TimeInForce.goodTillCanceled,
    String? clientOrderId,
  }) {
    return OrderRequest(
      symbol: symbol,
      side: OrderSide.sell,
      type: OrderType.limit,
      quantity: quantity,
      price: price,
      timeInForce: timeInForce,
      newClientOrderId: clientOrderId,
    );
  }

  @override
  String toString() {
    return 'OrderRequest(symbol: $symbol, side: ${side.value}, type: ${type.value}, '
        'quantity: $quantity, price: $price)';
  }
}

/// Respuesta de orden de Binance
class OrderResponse {
  final String symbol;
  final int orderId;
  final int orderListId;
  final String clientOrderId;
  final int transactTime;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final OrderStatus status;
  final TimeInForce timeInForce;
  final OrderType type;
  final OrderSide side;
  final double? stopPrice;
  final double? icebergQty;
  final int time;
  final int updateTime;
  final bool isWorking;
  final List<Fill>? fills;

  OrderResponse({
    required this.symbol,
    required this.orderId,
    required this.orderListId,
    required this.clientOrderId,
    required this.transactTime,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.cummulativeQuoteQty,
    required this.status,
    required this.timeInForce,
    required this.type,
    required this.side,
    this.stopPrice,
    this.icebergQty,
    required this.time,
    required this.updateTime,
    required this.isWorking,
    this.fills,
  });

  /// Crear desde JSON de respuesta de Binance
  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      symbol: json['symbol'] ?? '',
      orderId: json['orderId'] ?? 0,
      orderListId: json['orderListId'] ?? -1,
      clientOrderId: json['clientOrderId'] ?? '',
      transactTime: json['transactTime'] ?? json['time'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      origQty: double.tryParse(json['origQty']?.toString() ?? '0') ?? 0.0,
      executedQty:
          double.tryParse(json['executedQty']?.toString() ?? '0') ?? 0.0,
      cummulativeQuoteQty:
          double.tryParse(json['cummulativeQuoteQty']?.toString() ?? '0') ??
              0.0,
      status: OrderStatus.fromString(json['status'] ?? 'NEW'),
      timeInForce: TimeInForce.fromString(json['timeInForce'] ?? 'GTC'),
      type: OrderType.fromString(json['type'] ?? 'MARKET'),
      side: OrderSide.fromString(json['side'] ?? 'BUY'),
      stopPrice: json['stopPrice'] != null
          ? double.tryParse(json['stopPrice'].toString())
          : null,
      icebergQty: json['icebergQty'] != null
          ? double.tryParse(json['icebergQty'].toString())
          : null,
      time: json['time'] ?? json['transactTime'] ?? 0,
      updateTime: json['updateTime'] ?? json['time'] ?? 0,
      isWorking: json['isWorking'] ?? false,
      fills: json['fills'] != null
          ? (json['fills'] as List<dynamic>)
              .map((fill) => Fill.fromJson(fill))
              .toList()
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'orderId': orderId,
      'orderListId': orderListId,
      'clientOrderId': clientOrderId,
      'transactTime': transactTime,
      'price': price.toString(),
      'origQty': origQty.toString(),
      'executedQty': executedQty.toString(),
      'cummulativeQuoteQty': cummulativeQuoteQty.toString(),
      'status': status.value,
      'timeInForce': timeInForce.value,
      'type': type.value,
      'side': side.value,
      if (stopPrice != null) 'stopPrice': stopPrice.toString(),
      if (icebergQty != null) 'icebergQty': icebergQty.toString(),
      'time': time,
      'updateTime': updateTime,
      'isWorking': isWorking,
      if (fills != null) 'fills': fills!.map((fill) => fill.toJson()).toList(),
    };
  }

  /// Verificar si la orden está completamente ejecutada
  bool get isFilled => status == OrderStatus.filled;

  /// Verificar si la orden está parcialmente ejecutada
  bool get isPartiallyFilled => status == OrderStatus.partiallyFilled;

  /// Verificar si la orden está activa
  bool get isActive =>
      status == OrderStatus.newOrder || status == OrderStatus.partiallyFilled;

  /// Verificar si la orden puede ser cancelada
  bool get canBeCanceled => isActive && status != OrderStatus.pendingCancel;

  /// Obtener cantidad restante por ejecutar
  double get remainingQty => origQty - executedQty;

  /// Obtener porcentaje de ejecución
  double get fillPercentage =>
      origQty > 0 ? (executedQty / origQty) * 100 : 0.0;

  /// Obtener precio promedio de ejecución
  double get avgPrice {
    if (executedQty == 0) return 0.0;
    return cummulativeQuoteQty / executedQty;
  }

  @override
  String toString() {
    return 'OrderResponse(orderId: $orderId, symbol: $symbol, side: ${side.value}, '
        'type: ${type.value}, status: ${status.value}, executedQty: $executedQty/$origQty)';
  }
}

/// Información de llenado de orden
class Fill {
  final double price;
  final double qty;
  final double commission;
  final String commissionAsset;
  final int? tradeId;

  Fill({
    required this.price,
    required this.qty,
    required this.commission,
    required this.commissionAsset,
    this.tradeId,
  });

  factory Fill.fromJson(Map<String, dynamic> json) {
    return Fill(
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0.0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
      commissionAsset: json['commissionAsset'] ?? '',
      tradeId: json['tradeId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price.toString(),
      'qty': qty.toString(),
      'commission': commission.toString(),
      'commissionAsset': commissionAsset,
      if (tradeId != null) 'tradeId': tradeId,
    };
  }

  /// Valor total del llenado
  double get value => price * qty;

  @override
  String toString() {
    return 'Fill(price: $price, qty: $qty, commission: $commission $commissionAsset)';
  }
}
