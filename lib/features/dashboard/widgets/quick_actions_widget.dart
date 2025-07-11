import 'package:flutter/material.dart';
import '../../../ui/theme/colors.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback? onBuyPressed;
  final VoidCallback? onSellPressed;
  final VoidCallback? onSwapPressed;
  final VoidCallback? onTransferPressed;
  final VoidCallback? onDepositPressed;
  final VoidCallback? onWithdrawPressed;

  const QuickActionsWidget({
    super.key,
    this.onBuyPressed,
    this.onSellPressed,
    this.onSwapPressed,
    this.onTransferPressed,
    this.onDepositPressed,
    this.onWithdrawPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Buy',
                    Icons.add_shopping_cart,
                    AppColors.bullish,
                    onBuyPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Sell',
                    Icons.sell,
                    AppColors.bearish,
                    onSellPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Swap',
                    Icons.swap_horiz,
                    AppColors.info,
                    onSwapPressed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Transfer',
                    Icons.send,
                    AppColors.warning,
                    onTransferPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Deposit',
                    Icons.download,
                    AppColors.success,
                    onDepositPressed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'Withdraw',
                    Icons.upload,
                    AppColors.goldPrimary,
                    onWithdrawPressed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
