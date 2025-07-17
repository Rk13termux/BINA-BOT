/// Información de cuenta de Binance
class AccountInfo {
  final int makerCommission;
  final int takerCommission;
  final int buyerCommission;
  final int sellerCommission;
  final bool canTrade;
  final bool canWithdraw;
  final bool canDeposit;
  final bool brokered;
  final int updateTime;
  final String accountType;
  final List<Balance> balances;
  final List<String> permissions;

  AccountInfo({
    required this.makerCommission,
    required this.takerCommission,
    required this.buyerCommission,
    required this.sellerCommission,
    required this.canTrade,
    required this.canWithdraw,
    required this.canDeposit,
    required this.brokered,
    required this.updateTime,
    required this.accountType,
    required this.balances,
    required this.permissions,
  });

  /// Crear desde JSON de respuesta de Binance
  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      makerCommission: json['makerCommission'] ?? 0,
      takerCommission: json['takerCommission'] ?? 0,
      buyerCommission: json['buyerCommission'] ?? 0,
      sellerCommission: json['sellerCommission'] ?? 0,
      canTrade: json['canTrade'] ?? false,
      canWithdraw: json['canWithdraw'] ?? false,
      canDeposit: json['canDeposit'] ?? false,
      brokered: json['brokered'] ?? false,
      updateTime: json['updateTime'] ?? 0,
      accountType: json['accountType'] ?? 'SPOT',
      balances: (json['balances'] as List<dynamic>?)
              ?.map((balance) => Balance.fromJson(balance))
              .toList() ??
          [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((permission) => permission.toString())
              .toList() ??
          [],
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'makerCommission': makerCommission,
      'takerCommission': takerCommission,
      'buyerCommission': buyerCommission,
      'sellerCommission': sellerCommission,
      'canTrade': canTrade,
      'canWithdraw': canWithdraw,
      'canDeposit': canDeposit,
      'brokered': brokered,
      'updateTime': updateTime,
      'accountType': accountType,
      'balances': balances.map((balance) => balance.toJson()).toList(),
      'permissions': permissions,
    };
  }

  /// Obtener balance de un asset específico
  Balance? getBalanceForAsset(String asset) {
    try {
      return balances.firstWhere(
        (balance) => balance.asset.toUpperCase() == asset.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  

  /// Obtener balances con valor mayor a cero
  List<Balance> get nonZeroBalances {
    return balances
        .where((balance) => (balance.free + balance.locked) > 0.0)
        .toList();
  }

  /// Verificar si tiene balance suficiente para trading
  bool hasBalanceForTrading(String asset, double amount) {
    final balance = getBalanceForAsset(asset);
    return balance != null && balance.free >= amount;
  }

  /// Obtener balance total estimado en USDT
  double getTotalBalanceUSDT() {
    // Esta implementación básica suma USDT y BUSD directamente
    // En un escenario real, necesitarías convertir otros assets usando precios actuales
    double total = 0.0;
    
    // Sumar USDT directamente
    final usdtBalance = getBalanceForAsset('USDT');
    if (usdtBalance != null) {
      total += usdtBalance.total;
    }
    
    // Sumar BUSD directamente (asumiendo paridad 1:1 con USDT)
    final busdBalance = getBalanceForAsset('BUSD');
    if (busdBalance != null) {
      total += busdBalance.total;
    }
    
    // Para otros assets, sería necesario obtener su precio en USDT
    // Por ahora retornamos solo el total de stablecoins
    return total;
  }

  @override
  String toString() {
    return 'AccountInfo(accountType: $accountType, canTrade: $canTrade, '
        'balancesCount: ${balances.length})';
  }
}

/// Balance de un asset específico
class Balance {
  final String asset;
  final double free;
  final double locked;

  Balance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  /// Crear desde JSON
  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      asset: json['asset'] ?? '',
      free: double.tryParse(json['free']?.toString() ?? '0') ?? 0.0,
      locked: double.tryParse(json['locked']?.toString() ?? '0') ?? 0.0,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'free': free.toString(),
      'locked': locked.toString(),
    };
  }

  /// Total disponible (libre + bloqueado)
  double get total => free + locked;

  /// Verificar si tiene balance disponible
  bool get hasBalance => total > 0.0;

  /// Verificar si tiene balance libre para trading
  bool get hasFreeBalance => free > 0.0;

  @override
  String toString() {
    return 'Balance(asset: $asset, free: $free, locked: $locked, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Balance &&
        other.asset == asset &&
        other.free == free &&
        other.locked == locked;
  }

  @override
  int get hashCode => asset.hashCode ^ free.hashCode ^ locked.hashCode;
}
