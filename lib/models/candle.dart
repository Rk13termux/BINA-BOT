/// Modelo para datos de vela (candlestick)
class Candle {
  final DateTime openTime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final DateTime closeTime;

  Candle({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime.millisecondsSinceEpoch,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
      'closeTime': closeTime.millisecondsSinceEpoch,
    };
  }

  /// Crea desde JSON
  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      openTime: DateTime.fromMillisecondsSinceEpoch(json['openTime']),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json['closeTime']),
    );
  }

  /// Crea desde respuesta de Binance API
  factory Candle.fromBinanceKline(List<dynamic> kline) {
    return Candle(
      openTime: DateTime.fromMillisecondsSinceEpoch(kline[0]),
      open: double.parse(kline[1].toString()),
      high: double.parse(kline[2].toString()),
      low: double.parse(kline[3].toString()),
      close: double.parse(kline[4].toString()),
      volume: double.parse(kline[5].toString()),
      closeTime: DateTime.fromMillisecondsSinceEpoch(kline[6]),
    );
  }

  /// Verifica si es una vela alcista (verde)
  bool get isBullish => close > open;

  /// Verifica si es una vela bajista (roja)
  bool get isBearish => close < open;

  /// Calcula el cuerpo de la vela
  double get body => (close - open).abs();

  /// Calcula la sombra superior
  double get upperShadow => high - (isBullish ? close : open);

  /// Calcula la sombra inferior
  double get lowerShadow => (isBullish ? open : close) - low;

  /// Calcula el rango total
  double get range => high - low;

  @override
  String toString() {
    return 'Candle(time: $openTime, O: $open, H: $high, L: $low, C: $close, V: $volume)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Candle &&
        other.openTime == openTime &&
        other.open == open &&
        other.high == high &&
        other.low == low &&
        other.close == close &&
        other.volume == volume;
  }

  @override
  int get hashCode {
    return openTime.hashCode ^
        open.hashCode ^
        high.hashCode ^
        low.hashCode ^
        close.hashCode ^
        volume.hashCode;
  }
}
