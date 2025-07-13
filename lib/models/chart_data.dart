/// Modelo para datos de candlestick/velas profesional
class CandleData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int trades;
  final String symbol;
  
  const CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteVolume,
    required this.trades,
    required this.symbol,
  });
  
  /// Crear desde datos de kline de Binance
  factory CandleData.fromBinanceKline(Map<String, dynamic> kline, String symbol) {
    return CandleData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(kline['openTime']),
      open: kline['open']?.toDouble() ?? 0.0,
      high: kline['high']?.toDouble() ?? 0.0,
      low: kline['low']?.toDouble() ?? 0.0,
      close: kline['close']?.toDouble() ?? 0.0,
      volume: kline['volume']?.toDouble() ?? 0.0,
      quoteVolume: kline['quoteAssetVolume']?.toDouble() ?? 0.0,
      trades: kline['numberOfTrades'] ?? 0,
      symbol: symbol,
    );
  }
  
  /// Crear desde JSON
  factory CandleData.fromJson(Map<String, dynamic> json) {
    return CandleData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      open: json['open']?.toDouble() ?? 0.0,
      high: json['high']?.toDouble() ?? 0.0,
      low: json['low']?.toDouble() ?? 0.0,
      close: json['close']?.toDouble() ?? 0.0,
      volume: json['volume']?.toDouble() ?? 0.0,
      quoteVolume: json['quoteVolume']?.toDouble() ?? 0.0,
      trades: json['trades'] ?? 0,
      symbol: json['symbol'] ?? '',
    );
  }
  
  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'quoteVolume': quoteVolume,
      'trades': trades,
      'symbol': symbol,
    };
  }
  
  /// Verificar si es vela alcista
  bool get isBullish => close > open;
  
  /// Verificar si es vela bajista
  bool get isBearish => close < open;
  
  /// Obtener cambio de precio
  double get priceChange => close - open;
  
  /// Obtener cambio porcentual
  double get percentChange => open != 0 ? ((close - open) / open) * 100 : 0;
  
  /// Obtener rango de precio (high - low)
  double get priceRange => high - low;
  
  /// Obtener cuerpo de la vela (|close - open|)
  double get bodySize => (close - open).abs();
  
  /// Obtener mecha superior
  double get upperWick => high - (isBullish ? close : open);
  
  /// Obtener mecha inferior
  double get lowerWick => (isBullish ? open : close) - low;
  
  @override
  String toString() {
    return 'CandleData(symbol: $symbol, timestamp: $timestamp, OHLC: [$open, $high, $low, $close], volume: $volume)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CandleData &&
        other.timestamp == timestamp &&
        other.symbol == symbol;
  }
  
  @override
  int get hashCode => timestamp.hashCode ^ symbol.hashCode;
}

/// Modelo para datos del order book
class OrderBookData {
  final String symbol;
  final DateTime lastUpdateId;
  final List<OrderBookLevel> bids;
  final List<OrderBookLevel> asks;
  
  const OrderBookData({
    required this.symbol,
    required this.lastUpdateId,
    required this.bids,
    required this.asks,
  });
  
  /// Crear desde respuesta de Binance
  factory OrderBookData.fromBinanceResponse(Map<String, dynamic> response, String symbol) {
    final bidsData = response['bids'] as List<dynamic>? ?? [];
    final asksData = response['asks'] as List<dynamic>? ?? [];
    
    final bids = bidsData.map((bid) {
      final bidList = bid as List<dynamic>;
      return OrderBookLevel(
        price: double.tryParse(bidList[0].toString()) ?? 0.0,
        quantity: double.tryParse(bidList[1].toString()) ?? 0.0,
      );
    }).toList();
    
    final asks = asksData.map((ask) {
      final askList = ask as List<dynamic>;
      return OrderBookLevel(
        price: double.tryParse(askList[0].toString()) ?? 0.0,
        quantity: double.tryParse(askList[1].toString()) ?? 0.0,
      );
    }).toList();
    
    return OrderBookData(
      symbol: symbol,
      lastUpdateId: DateTime.now(),
      bids: bids,
      asks: asks,
    );
  }
  
  /// Obtener mejor precio de compra
  double get bestBid => bids.isNotEmpty ? bids.first.price : 0.0;
  
  /// Obtener mejor precio de venta
  double get bestAsk => asks.isNotEmpty ? asks.first.price : 0.0;
  
  /// Obtener spread
  double get spread => bestAsk - bestBid;
  
  /// Obtener spread porcentual
  double get spreadPercent => bestBid != 0 ? (spread / bestBid) * 100 : 0;
  
  /// Obtener precio medio
  double get midPrice => (bestBid + bestAsk) / 2;
  
  /// Obtener volumen total de bids
  double get totalBidVolume {
    return bids.fold(0.0, (sum, level) => sum + level.quantity);
  }
  
  /// Obtener volumen total de asks
  double get totalAskVolume {
    return asks.fold(0.0, (sum, level) => sum + level.quantity);
  }
}

/// Nivel del order book
class OrderBookLevel {
  final double price;
  final double quantity;
  
  const OrderBookLevel({
    required this.price,
    required this.quantity,
  });
  
  /// Valor total del nivel
  double get total => price * quantity;
}

/// Intervalo de tiempo para gráficos
enum ChartInterval {
  m1('1m', Duration(minutes: 1)),
  m3('3m', Duration(minutes: 3)),
  m5('5m', Duration(minutes: 5)),
  m15('15m', Duration(minutes: 15)),
  m30('30m', Duration(minutes: 30)),
  h1('1h', Duration(hours: 1)),
  h2('2h', Duration(hours: 2)),
  h4('4h', Duration(hours: 4)),
  h6('6h', Duration(hours: 6)),
  h8('8h', Duration(hours: 8)),
  h12('12h', Duration(hours: 12)),
  d1('1d', Duration(days: 1)),
  d3('3d', Duration(days: 3)),
  w1('1w', Duration(days: 7)),
  M1('1M', Duration(days: 30));
  
  const ChartInterval(this.binanceInterval, this.duration);
  
  final String binanceInterval;
  final Duration duration;
  
  /// Obtener etiqueta para mostrar
  String get label {
    switch (this) {
      case ChartInterval.m1:
        return '1m';
      case ChartInterval.m3:
        return '3m';
      case ChartInterval.m5:
        return '5m';
      case ChartInterval.m15:
        return '15m';
      case ChartInterval.m30:
        return '30m';
      case ChartInterval.h1:
        return '1h';
      case ChartInterval.h2:
        return '2h';
      case ChartInterval.h4:
        return '4h';
      case ChartInterval.h6:
        return '6h';
      case ChartInterval.h8:
        return '8h';
      case ChartInterval.h12:
        return '12h';
      case ChartInterval.d1:
        return '1d';
      case ChartInterval.d3:
        return '3d';
      case ChartInterval.w1:
        return '1w';
      case ChartInterval.M1:
        return '1M';
    }
  }
  
  /// Verificar si es intervalo corto (menor a 1 hora)
  bool get isShortTerm => duration.inHours < 1;
  
  /// Verificar si es intervalo medio (1 hora a 1 día)
  bool get isMediumTerm => duration.inHours >= 1 && duration.inDays < 1;
  
  /// Verificar si es intervalo largo (1 día o más)
  bool get isLongTerm => duration.inDays >= 1;
}

/// Datos de ticker/precio en tiempo real
class TickerData {
  final String symbol;
  final double price;
  final double priceChange;
  final double priceChangePercent;
  final double volume;
  final double quoteVolume;
  final double high24h;
  final double low24h;
  final DateTime timestamp;
  
  const TickerData({
    required this.symbol,
    required this.price,
    required this.priceChange,
    required this.priceChangePercent,
    required this.volume,
    required this.quoteVolume,
    required this.high24h,
    required this.low24h,
    required this.timestamp,
  });
  
  /// Crear desde respuesta de Binance
  factory TickerData.fromBinanceResponse(Map<String, dynamic> response) {
    return TickerData(
      symbol: response['symbol'] ?? '',
      price: double.tryParse(response['price']?.toString() ?? '0') ?? 0.0,
      priceChange: double.tryParse(response['priceChange']?.toString() ?? '0') ?? 0.0,
      priceChangePercent: double.tryParse(response['priceChangePercent']?.toString() ?? '0') ?? 0.0,
      volume: double.tryParse(response['volume']?.toString() ?? '0') ?? 0.0,
      quoteVolume: double.tryParse(response['quoteVolume']?.toString() ?? '0') ?? 0.0,
      high24h: double.tryParse(response['highPrice']?.toString() ?? '0') ?? 0.0,
      low24h: double.tryParse(response['lowPrice']?.toString() ?? '0') ?? 0.0,
      timestamp: DateTime.now(),
    );
  }
  
  /// Verificar si el precio está subiendo
  bool get isRising => priceChange > 0;
  
  /// Verificar si el precio está bajando
  bool get isFalling => priceChange < 0;
  
  /// Verificar si el precio está estable
  bool get isStable => priceChange == 0;
  
  /// Obtener rango del día (high - low)
  double get dailyRange => high24h - low24h;
  
  /// Obtener posición del precio en el rango del día (0.0 a 1.0)
  double get pricePositionInRange {
    if (dailyRange == 0) return 0.5;
    return (price - low24h) / dailyRange;
  }
}
