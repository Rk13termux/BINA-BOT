class BinanceAccount {
  final String accountType;
  final double? makerCommission;
  final double? takerCommission;
  final double? buyerCommission;
  final double? sellerCommission;
  final bool canTrade;
  final bool canWithdraw;
  final bool canDeposit;
  final DateTime updateTime;
  final List<AccountBalance> balances;
  final List<String> permissions;

  BinanceAccount({
    required this.accountType,
    this.makerCommission,
    this.takerCommission,
    this.buyerCommission,
    this.sellerCommission,
    required this.canTrade,
    required this.canWithdraw,
    required this.canDeposit,
    required this.updateTime,
    required this.balances,
    required this.permissions,
  });

  factory BinanceAccount.fromJson(Map<String, dynamic> json) {
    return BinanceAccount(
      accountType: json['accountType'] ?? 'SPOT',
      makerCommission: (json['makerCommission'] as num?)?.toDouble(),
      takerCommission: (json['takerCommission'] as num?)?.toDouble(),
      buyerCommission: (json['buyerCommission'] as num?)?.toDouble(),
      sellerCommission: (json['sellerCommission'] as num?)?.toDouble(),
      canTrade: json['canTrade'] ?? false,
      canWithdraw: json['canWithdraw'] ?? false,
      canDeposit: json['canDeposit'] ?? false,
      updateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['updateTime'] as num?)?.toInt() ?? 0,
      ),
      balances: (json['balances'] as List<dynamic>?)
          ?.map((balance) => AccountBalance.fromJson(balance))
          .toList() ?? [],
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((permission) => permission.toString())
          .toList() ?? [],
    );
  }

  // Cálculo de balance total en USDT
  double get totalWalletBalance {
    // Calcular el valor total en USDT de todos los balances
    // Por ahora retornamos la suma simple de todos los balances libres
    return balances.fold(0.0, (sum, balance) => sum + balance.free);
  }

  // Obtener balances con valor mayor a 0
  List<AccountBalance> get nonZeroBalances {
    return balances.where((balance) => balance.free > 0 || balance.locked > 0).toList();
  }

  // Obtener balance total estimado en USDT
  double get totalBalanceUSDT {
    return balances.fold(0.0, (sum, balance) => sum + balance.totalValueUSDT);
  }

  // Verificar si la API está conectada correctamente
  bool get isConnected {
    return accountType.isNotEmpty && updateTime.isAfter(
      DateTime.now().subtract(const Duration(minutes: 5))
    );
  }
}

class AccountBalance {
  final String asset;
  final double free;
  final double locked;
  final double? priceUSDT; // Precio actual en USDT
  final double? change24h; // Cambio en 24h

  AccountBalance({
    required this.asset,
    required this.free,
    required this.locked,
    this.priceUSDT,
    this.change24h,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      asset: json['asset'] ?? '',
      free: double.tryParse(json['free']?.toString() ?? '0') ?? 0.0,
      locked: double.tryParse(json['locked']?.toString() ?? '0') ?? 0.0,
      priceUSDT: (json['priceUSDT'] as num?)?.toDouble(),
      change24h: (json['change24h'] as num?)?.toDouble(),
    );
  }

  // Balance total (libre + bloqueado)
  double get total => free + locked;

  // Valor total en USDT
  double get totalValueUSDT {
    if (asset == 'USDT') return total;
    return (priceUSDT ?? 0) * total;
  }

  // Formato para mostrar el balance
  String get formattedBalance {
    if (total >= 1) {
      return total.toStringAsFixed(4);
    } else {
      return total.toStringAsFixed(8);
    }
  }

  // Formato para mostrar el valor en USDT
  String get formattedValueUSDT {
    if (totalValueUSDT >= 1) {
      return '\$${totalValueUSDT.toStringAsFixed(2)}';
    } else {
      return '\$${totalValueUSDT.toStringAsFixed(6)}';
    }
  }

  // Indica si tiene un balance significativo
  bool get hasSignificantBalance {
    return totalValueUSDT > 1.0; // Más de $1 USD
  }
}

class BinanceApiCredentials {
  final String apiKey;
  final String secretKey;
  final bool isTestnet;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final String? nickname;

  BinanceApiCredentials({
    required this.apiKey,
    required this.secretKey,
    this.isTestnet = false,
    required this.createdAt,
    this.lastUsed,
    this.nickname,
  });

  factory BinanceApiCredentials.fromJson(Map<String, dynamic> json) {
    return BinanceApiCredentials(
      apiKey: json['apiKey'] ?? '',
      secretKey: json['secretKey'] ?? '',
      isTestnet: json['isTestnet'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'secretKey': secretKey,
      'isTestnet': isTestnet,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'nickname': nickname,
    };
  }

  // API Key parcialmente oculta para mostrar en UI
  String get maskedApiKey {
    if (apiKey.length <= 8) return apiKey;
    return '${apiKey.substring(0, 4)}${'*' * (apiKey.length - 8)}${apiKey.substring(apiKey.length - 4)}';
  }

  // Verificar si las credenciales están completas
  bool get isValid {
    return apiKey.isNotEmpty && secretKey.isNotEmpty;
  }

  // Estado de conexión
  String get connectionStatus {
    if (lastUsed == null) return 'Nunca conectado';
    
    final difference = DateTime.now().difference(lastUsed!);
    if (difference.inMinutes < 5) return 'Conectado';
    if (difference.inHours < 1) return 'Conectado recientemente';
    if (difference.inDays < 1) return 'Última conexión: ${difference.inHours}h';
    return 'Última conexión: ${difference.inDays}d';
  }
}
