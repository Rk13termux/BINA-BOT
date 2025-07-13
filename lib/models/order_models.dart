/// Modelo para solicitud de orden
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
  final OrderResponseType? newOrderRespType;
  final int? recvWindow;

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
    this.recvWindow,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'symbol': symbol,
      'side': side.toString().split('.').last,
      'type': type.toString().split('.').last,
    };

    if (timeInForce != null) {
      data['timeInForce'] = timeInForce.toString().split('.').last;
    }
    if (quantity != null) data['quantity'] = quantity.toString();
    if (quoteOrderQty != null) data['quoteOrderQty'] = quoteOrderQty.toString();
    if (price != null) data['price'] = price.toString();
    if (newClientOrderId != null) data['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) data['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) data['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) {
      data['newOrderRespType'] = newOrderRespType.toString().split('.').last;
    }
    if (recvWindow != null) data['recvWindow'] = recvWindow.toString();

    return data;
  }
}

/// Modelo para respuesta de orden
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
  final List<Fill> fills;

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
    required this.fills,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      symbol: json['symbol'] ?? '',
      orderId: json['orderId'] ?? 0,
      orderListId: json['orderListId'] ?? -1,
      clientOrderId: json['clientOrderId'] ?? '',
      transactTime: json['transactTime'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      origQty: double.tryParse(json['origQty']?.toString() ?? '0') ?? 0.0,
      executedQty: double.tryParse(json['executedQty']?.toString() ?? '0') ?? 0.0,
      cummulativeQuoteQty: double.tryParse(json['cummulativeQuoteQty']?.toString() ?? '0') ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.NEW,
      ),
      timeInForce: TimeInForce.values.firstWhere(
        (e) => e.toString().split('.').last == json['timeInForce'],
        orElse: () => TimeInForce.GTC,
      ),
      type: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => OrderType.MARKET,
      ),
      side: OrderSide.values.firstWhere(
        (e) => e.toString().split('.').last == json['side'],
        orElse: () => OrderSide.BUY,
      ),
      fills: (json['fills'] as List<dynamic>?)
          ?.map((fill) => Fill.fromJson(fill))
          .toList() ?? [],
    );
  }

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
      'status': status.toString().split('.').last,
      'timeInForce': timeInForce.toString().split('.').last,
      'type': type.toString().split('.').last,
      'side': side.toString().split('.').last,
      'fills': fills.map((fill) => fill.toJson()).toList(),
    };
  }
}

/// Modelo para fill de orden
class Fill {
  final double price;
  final double qty;
  final double commission;
  final String commissionAsset;
  final int tradeId;

  Fill({
    required this.price,
    required this.qty,
    required this.commission,
    required this.commissionAsset,
    required this.tradeId,
  });

  factory Fill.fromJson(Map<String, dynamic> json) {
    return Fill(
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      qty: double.tryParse(json['qty']?.toString() ?? '0') ?? 0.0,
      commission: double.tryParse(json['commission']?.toString() ?? '0') ?? 0.0,
      commissionAsset: json['commissionAsset'] ?? '',
      tradeId: json['tradeId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price.toString(),
      'qty': qty.toString(),
      'commission': commission.toString(),
      'commissionAsset': commissionAsset,
      'tradeId': tradeId,
    };
  }
}

/// Enums para órdenes
enum OrderSide { BUY, SELL }
enum OrderType { LIMIT, MARKET, STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, TAKE_PROFIT_LIMIT, LIMIT_MAKER }
enum TimeInForce { GTC, IOC, FOK }
enum OrderStatus { NEW, PARTIALLY_FILLED, FILLED, CANCELED, PENDING_CANCEL, REJECTED, EXPIRED }
enum OrderResponseType { ACK, RESULT, FULL }
