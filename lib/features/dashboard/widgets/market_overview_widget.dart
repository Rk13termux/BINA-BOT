import 'package:flutter/material.dart';
import '../../../ui/theme/colors.dart';

class MarketOverviewWidget extends StatelessWidget {
  const MarketOverviewWidget({super.key});

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
                  Icons.trending_up,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Market Overview',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bullish,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BULLISH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMarketStat('Total Market Cap', '\$2.47T', '+2.34%', true),
            const SizedBox(height: 8),
            _buildMarketStat('24h Volume', '\$89.2B', '+5.67%', true),
            const SizedBox(height: 8),
            _buildMarketStat('BTC Dominance', '42.8%', '-0.12%', false),
            const SizedBox(height: 8),
            _buildMarketStat('Fear & Greed Index', '76 (Extreme Greed)', '+8', true),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStat(String label, String value, String change, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              change,
              style: TextStyle(
                color: isPositive ? AppColors.bullish : AppColors.bearish,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
