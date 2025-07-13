class CryptoPrice {
  final String symbol;
  final double price;
  final double change24h;
  final double changePercent24h;
  final double volume24h;
  final double? high24h;
  final double? low24h;
  final double? marketCap;
  final int? marketCapRank;
  final DateTime timestamp;
  final String source;

  CryptoPrice({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.volume24h,
    this.high24h,
    this.low24h,
    this.marketCap,
    this.marketCapRank,
    required this.timestamp,
    required this.source,
  });

  factory CryptoPrice.fromJson(Map<String, dynamic> json) {
    return CryptoPrice(
      symbol: json['symbol']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      change24h: (json['change_24h'] as num?)?.toDouble() ?? 0.0,
      changePercent24h: (json['change_percent_24h'] as num?)?.toDouble() ?? 0.0,
      volume24h: (json['volume_24h'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble(),
      low24h: (json['low_24h'] as num?)?.toDouble(),
      marketCap: (json['market_cap'] as num?)?.toDouble(),
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num?)?.toDouble() ?? 0 * 1000).round(),
      ),
      source: json['source']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'price': price,
      'change_24h': change24h,
      'change_percent_24h': changePercent24h,
      'volume_24h': volume24h,
      'high_24h': high24h,
      'low_24h': low24h,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'timestamp': timestamp.millisecondsSinceEpoch / 1000,
      'source': source,
    };
  }

  bool get isPositiveChange => changePercent24h > 0;
  
  String get formattedPrice {
    if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }

  String get formattedChange {
    final sign = changePercent24h >= 0 ? '+' : '';
    return '$sign${changePercent24h.toStringAsFixed(2)}%';
  }

  String get formattedVolume {
    if (volume24h >= 1e9) {
      return '\$${(volume24h / 1e9).toStringAsFixed(2)}B';
    } else if (volume24h >= 1e6) {
      return '\$${(volume24h / 1e6).toStringAsFixed(2)}M';
    } else if (volume24h >= 1e3) {
      return '\$${(volume24h / 1e3).toStringAsFixed(2)}K';
    } else {
      return '\$${volume24h.toStringAsFixed(2)}';
    }
  }

  @override
  String toString() {
    return 'CryptoPrice(symbol: $symbol, price: $price, change: $changePercent24h%, source: $source)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoPrice &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          price == other.price &&
          timestamp == other.timestamp;

  @override
  int get hashCode => symbol.hashCode ^ price.hashCode ^ timestamp.hashCode;
}
