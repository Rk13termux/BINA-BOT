import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/binance_account.dart';
import '../../../services/binance_api_service.dart';
import '../../../ui/theme/colors.dart';
import '../../../utils/logger.dart';

class ProfessionalPortfolioWidget extends StatefulWidget {
  final BinanceApiService binanceService;
  
  const ProfessionalPortfolioWidget({
    Key? key,
    required this.binanceService,
  }) : super(key: key);

  @override
  State<ProfessionalPortfolioWidget> createState() => _ProfessionalPortfolioWidgetState();
}

class _ProfessionalPortfolioWidgetState extends State<ProfessionalPortfolioWidget>
    with TickerProviderStateMixin {
  
  final AppLogger _logger = AppLogger();
  late TabController _portfolioTabController;
  
  BinanceAccount? _binanceAccount;
  bool _isLoading = false;
  bool _showZeroBalances = false;
  String _sortBy = 'value'; // value, amount, symbol
  bool _sortAscending = false;
  
  @override
  void initState() {
    super.initState();
    _portfolioTabController = TabController(length: 3, vsync: this);
    _initializePortfolio();
  }
  
  @override
  void dispose() {
    _portfolioTabController.dispose();
    super.dispose();
  }
  
  void _initializePortfolio() {
    // Escuchar cambios en la cuenta
    widget.binanceService.accountStream.listen((account) {
      if (mounted) {
        setState(() {
          _binanceAccount = account;
          _isLoading = false;
        });
      }
    });
    
    // Escuchar cambios en la conexión
    widget.binanceService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isLoading = !isConnected && _binanceAccount == null;
        });
      }
    });
    
    // Cargar datos iniciales
    _refreshPortfolio();
  }
  
  Future<void> _refreshPortfolio() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Intentar obtener datos actualizados de la cuenta
      _logger.info('Actualizando datos del portfolio');
    } catch (e) {
      _logger.error('Error actualizando portfolio: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPortfolioHeader(),
          _buildPortfolioTabs(),
          Expanded(
            child: _buildPortfolioContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldPrimary.withOpacity(0.1),
            AppColors.goldPrimary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.goldPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portfolio Profesional',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getPortfolioSubtitle(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _refreshPortfolio,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: AppColors.goldPrimary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBalanceSummary(),
        ],
      ),
    );
  }
  
  Widget _buildBalanceSummary() {
    if (_binanceAccount == null) {
      return _buildNoAccountWidget();
    }
    
    final totalBalance = _binanceAccount!.totalBalanceUSDT;
    final significantBalances = _binanceAccount!.balances
        .where((b) => b.hasSignificantBalance)
        .length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Balance Total',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activos',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$significantBalances',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _binanceAccount!.isConnected 
                            ? AppColors.bullish 
                            : AppColors.bearish,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _binanceAccount!.isConnected ? 'Conectado' : 'Desconectado',
                      style: TextStyle(
                        color: _binanceAccount!.isConnected 
                            ? AppColors.bullish 
                            : AppColors.bearish,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoAccountWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Conecta tu cuenta de Binance',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Para ver tu portfolio en tiempo real',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Abrir configuración de API
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Configurar API'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _portfolioTabController,
        tabs: const [
          Tab(text: 'Balances'),
          Tab(text: 'Historial'),
          Tab(text: 'P&L'),
        ],
        indicatorColor: AppColors.goldPrimary,
        labelColor: AppColors.goldPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildPortfolioContent() {
    return TabBarView(
      controller: _portfolioTabController,
      children: [
        _buildBalancesTab(),
        _buildHistoryTab(),
        _buildPnLTab(),
      ],
    );
  }
  
  Widget _buildBalancesTab() {
    if (_binanceAccount == null) {
      return _buildEmptyState('No hay cuenta conectada');
    }
    
    List<AccountBalance> balances = _showZeroBalances
        ? _binanceAccount!.balances
        : _binanceAccount!.nonZeroBalances;
    
    // Ordenar balances
    balances.sort((a, b) {
      switch (_sortBy) {
        case 'value':
          final comparison = a.totalValueUSDT.compareTo(b.totalValueUSDT);
          return _sortAscending ? comparison : -comparison;
        case 'amount':
          final comparison = a.total.compareTo(b.total);
          return _sortAscending ? comparison : -comparison;
        case 'symbol':
          final comparison = a.asset.compareTo(b.asset);
          return _sortAscending ? comparison : -comparison;
        default:
          return 0;
      }
    });
    
    if (balances.isEmpty) {
      return _buildEmptyState('No hay balances para mostrar');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: balances.length,
      itemBuilder: (context, index) {
        return _buildBalanceItem(balances[index]);
      },
    );
  }
  
  Widget _buildBalanceItem(AccountBalance balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildAssetIcon(balance.asset),
        title: Row(
          children: [
            Text(
              balance.asset,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (balance.change24h != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (balance.change24h! >= 0 ? AppColors.bullish : AppColors.bearish)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${balance.change24h! >= 0 ? '+' : ''}${balance.change24h!.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: balance.change24h! >= 0 ? AppColors.bullish : AppColors.bearish,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${balance.formattedBalance} ${balance.asset}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (balance.locked > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Bloqueado: ${balance.locked.toStringAsFixed(8)}',
                style: TextStyle(
                  color: AppColors.bearish,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              balance.formattedValueUSDT,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (balance.priceUSDT != null && balance.asset != 'USDT') ...[
              const SizedBox(height: 2),
              Text(
                '\$${balance.priceUSDT!.toStringAsFixed(balance.priceUSDT! >= 1 ? 2 : 6)}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        onTap: () => _showBalanceDetails(balance),
        onLongPress: () => _copyBalanceInfo(balance),
      ),
    );
  }
  
  Widget _buildAssetIcon(String asset) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldPrimary.withOpacity(0.3),
            AppColors.goldPrimary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          asset.length > 4 ? asset.substring(0, 4) : asset,
          style: TextStyle(
            color: AppColors.goldPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    return _buildEmptyState('Historial próximamente');
  }
  
  Widget _buildPnLTab() {
    return _buildEmptyState('P&L próximamente');
  }
  
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPortfolioSubtitle() {
    if (_binanceAccount == null) {
      return 'Conecta tu cuenta para ver el portfolio';
    }
    
    final lastUpdate = _binanceAccount!.updateTime;
    final timeDiff = DateTime.now().difference(lastUpdate);
    
    if (timeDiff.inMinutes < 1) {
      return 'Actualizado ahora';
    } else if (timeDiff.inHours < 1) {
      return 'Actualizado hace ${timeDiff.inMinutes}m';
    } else {
      return 'Actualizado hace ${timeDiff.inHours}h';
    }
  }
  
  void _showBalanceDetails(AccountBalance balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Detalles de ${balance.asset}',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Balance libre:', balance.free.toStringAsFixed(8)),
            _buildDetailRow('Balance bloqueado:', balance.locked.toStringAsFixed(8)),
            _buildDetailRow('Balance total:', balance.total.toStringAsFixed(8)),
            if (balance.priceUSDT != null)
              _buildDetailRow('Precio USDT:', '\$${balance.priceUSDT!.toStringAsFixed(6)}'),
            _buildDetailRow('Valor total:', balance.formattedValueUSDT),
            if (balance.change24h != null)
              _buildDetailRow('Cambio 24h:', '${balance.change24h!.toStringAsFixed(2)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: AppColors.goldPrimary),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _copyBalanceInfo(AccountBalance balance) {
    final info = '''
${balance.asset} Balance:
Libre: ${balance.free.toStringAsFixed(8)}
Bloqueado: ${balance.locked.toStringAsFixed(8)}
Total: ${balance.total.toStringAsFixed(8)}
Valor: ${balance.formattedValueUSDT}
''';
    
    Clipboard.setData(ClipboardData(text: info));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Información de ${balance.asset} copiada'),
        backgroundColor: AppColors.goldPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
