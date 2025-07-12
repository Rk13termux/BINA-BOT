import 'package:flutter/material.dart';
import '../../../ui/theme/colors.dart';

class RecentAlertsWidget extends StatelessWidget {
  const RecentAlertsWidget({super.key});

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
                  Icons.notifications_active,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Alerts',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to alerts screen
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAlertItem(
              'BTC Price Alert',
              'Bitcoin reached \$95,000',
              '2 minutes ago',
              Icons.trending_up,
              AppColors.bullish,
            ),
            const SizedBox(height: 12),
            _buildAlertItem(
              'RSI Signal',
              'ETH RSI oversold - potential buy signal',
              '15 minutes ago',
              Icons.show_chart,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildAlertItem(
              'News Alert',
              'SEC approves new Bitcoin ETF proposal',
              '1 hour ago',
              Icons.article,
              AppColors.info,
            ),
            const SizedBox(height: 12),
            _buildAlertItem(
              'Volume Alert',
              'Unusual volume spike in DOGE',
              '2 hours ago',
              Icons.volume_up,
              AppColors.bearish,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
