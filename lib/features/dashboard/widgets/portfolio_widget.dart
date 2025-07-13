import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/colors.dart';
import '../../../services/binance_service.dart';

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({super.key});

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  double _totalBalance = 0.0;
  List<Map<String, dynamic>> _topAssets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    setState(() => _isLoading = true);
    
    try {
      final binanceService = context.read<BinanceService>();
      
      if (binanceService.isAuthenticated) {
        // Get total balance
        _totalBalance = await binanceService.getTotalBalanceUSDT();
        
        // Get formatted balances and take top 5
        final balances = await binanceService.getFormattedBalances();
        _topAssets = balances.take(5).toList();
      }
    } catch (e) {
      print('Error loading portfolio: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BinanceService>(
      builder: (context, binanceService, child) {
        return Card(
          color: AppColors.surfaceDark,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.goldPrimary, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Portfolio Balance',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!_isLoading)
                      IconButton(
                        onPressed: _loadPortfolioData,
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.goldPrimary,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (!binanceService.isAuthenticated)
                  _buildNotConnectedState()
                else if (_isLoading)
                  _buildLoadingState()
                else
                  _buildPortfolioContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotConnectedState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.goldPrimary, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            color: AppColors.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            'Binance API not connected',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to settings to configure API
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Configure API'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppColors.goldPrimary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text(
              'Loading portfolio...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total Balance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.goldPrimary.withOpacity(0.1),
                AppColors.goldSecondary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.goldPrimary, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${_totalBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Top Assets
        if (_topAssets.isNotEmpty) ...[
          Text(
            'Top Assets',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._topAssets.map((asset) => _buildAssetItem(asset)),
        ] else
          Center(
            child: Text(
              'No assets found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAssetItem(Map<String, dynamic> asset) {
    final assetName = asset['asset'].toString();
    final total = (asset['total'] as double);
    final usdtValue = (asset['usdtValue'] as double);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          // Asset Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                assetName.substring(0, assetName.length > 2 ? 2 : assetName.length),
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Asset Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assetName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(6)} $assetName',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          
          // USDT Value
          Text(
            '\$${usdtValue.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
