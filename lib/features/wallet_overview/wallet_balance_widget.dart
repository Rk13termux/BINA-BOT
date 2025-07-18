import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 💳 Widget de Balance de Billetera - QUANTIX AI CORE
/// Muestra el balance total y distribución de activos
class WalletBalanceWidget extends StatefulWidget {
  const WalletBalanceWidget({super.key});

  @override
  State<WalletBalanceWidget> createState() => _WalletBalanceWidgetState();
}

class _WalletBalanceWidgetState extends State<WalletBalanceWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  // Datos simulados (en producción vendrán de Binance API)
  final double _totalBalance = 12847.35;
  final double _dailyChange = 324.87;
  final double _dailyChangePercent = 2.6;
  final bool _isPositiveChange = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: QuantixTheme.premiumCardDecoration,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance Total',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: QuantixTheme.primaryBlack.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_totalBalance.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: QuantixTheme.primaryBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Ícono de billetera
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: QuantixTheme.primaryBlack.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: QuantixTheme.primaryBlack,
                    size: 30,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Cambio diario
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: QuantixTheme.primaryBlack.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPositiveChange ? Icons.trending_up : Icons.trending_down,
                    color: _isPositiveChange 
                        ? QuantixTheme.bullishGreen 
                        : QuantixTheme.bearishRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_isPositiveChange ? '+' : '-'}\$${_dailyChange.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: QuantixTheme.primaryBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_isPositiveChange ? '+' : '-'}${_dailyChangePercent.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: QuantixTheme.primaryBlack.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Distribución de activos
            _buildAssetDistribution(),
          ],
        ),
      ),
    );
  }

  /// Distribución de activos principales
  Widget _buildAssetDistribution() {
    final assets = [
      {'symbol': 'BTC', 'amount': 0.2847, 'value': 8450.23, 'change': 1.2},
      {'symbol': 'ETH', 'amount': 1.8965, 'value': 3247.85, 'change': -0.8},
      {'symbol': 'BNB', 'amount': 15.47, 'value': 987.52, 'change': 2.1},
      {'symbol': 'USDT', 'amount': 161.75, 'value': 161.75, 'change': 0.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Activos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: QuantixTheme.primaryBlack,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...assets.map((asset) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildAssetRow(
            asset['symbol'] as String,
            asset['amount'] as double,
            asset['value'] as double,
            asset['change'] as double,
          ),
        )),
        
        const SizedBox(height: 12),
        
        // Botón de ver más
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              // TODO: Navegar a vista detallada del portfolio
            },
            style: TextButton.styleFrom(
              backgroundColor: QuantixTheme.primaryBlack.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ver Portfolio Completo',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: QuantixTheme.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Fila de activo individual
  Widget _buildAssetRow(String symbol, double amount, double value, double changePercent) {
    final isPositive = changePercent > 0;
    final isNeutral = changePercent == 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Ícono del activo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: QuantixTheme.primaryBlack.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                symbol[0],
                style: const TextStyle(
                  color: QuantixTheme.primaryBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Información del activo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        color: QuantixTheme.primaryBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '\$${value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: QuantixTheme.primaryBlack,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${amount.toStringAsFixed(4)} $symbol',
                      style: TextStyle(
                        color: QuantixTheme.primaryBlack.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    if (!isNeutral)
                      Row(
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                            color: isPositive 
                                ? QuantixTheme.bullishGreen 
                                : QuantixTheme.bearishRed,
                            size: 16,
                          ),
                          Text(
                            '${changePercent.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositive 
                                  ? QuantixTheme.bullishGreen 
                                  : QuantixTheme.bearishRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Stable',
                        style: TextStyle(
                          color: QuantixTheme.primaryBlack.withOpacity(0.5),
                          fontSize: 12,
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
}
