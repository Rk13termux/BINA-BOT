/// Modelo para información de la cuenta de Binance
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
          .toList() ?? [],
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((permission) => permission.toString())
          .toList() ?? [],
    );
  }

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
  Balance? getBalance(String asset) {
    try {
      return balances.firstWhere(
        (balance) => balance.asset.toUpperCase() == asset.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener balance total en USDT
  double getTotalBalanceUSDT() {
    // Esta función necesitaría precios actuales para calcular
    // Por ahora retorna solo el balance de USDT
    final usdtBalance = getBalance('USDT');
    return usdtBalance?.free ?? 0.0;
  }
}

/// Modelo para balance de asset
class Balance {
  final String asset;
  final double free;
  final double locked;

  Balance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      asset: json['asset'] ?? '',
      free: double.tryParse(json['free'].toString()) ?? 0.0,
      locked: double.tryParse(json['locked'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset': asset,
      'free': free.toString(),
      'locked': locked.toString(),
    };
  }

  /// Balance total (libre + bloqueado)
  double get total => free + locked;

  /// Verificar si el balance es mayor a cero
  bool get hasBalance => total > 0;
}
