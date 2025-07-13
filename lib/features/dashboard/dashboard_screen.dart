import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/subscription_status_widget.dart';
import '../trading/trading_screen.dart';
import '../alerts/alerts_screen.dart';
import '../news/news_screen.dart';
import '../settings/settings_screen.dart';
import '../plugins/plugins_screen.dart';
import 'widgets/price_tile.dart';
import 'widgets/market_overview_widget.dart';
import 'widgets/portfolio_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_alerts_widget.dart';
import '../../services/auth_service.dart';

/// Pantalla principal del dashboard con navegación por pestañas
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _screens = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard,
      'widget': const _DashboardHomeTab(),
    },
    {
      'title': 'Trading',
      'icon': Icons.show_chart,
      'widget': const TradingScreen(),
    },
    {
      'title': 'Alerts',
      'icon': Icons.notifications,
      'widget': const AlertsScreen(),
    },
    {
      'title': 'News',
      'icon': Icons.article,
      'widget': const NewsScreen(),
    },
    {
      'title': 'More',
      'icon': Icons.more_horiz,
      'widget': const _MoreTab(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _screens.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.trending_up,
              color: AppColors.goldPrimary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Invictus Trader Pro',
              style: TextStyle(
                color: AppColors.goldPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Connection status indicator
          Consumer<AuthService>(
            builder: (context, auth, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: auth.isAuthenticated
                      ? AppColors.success
                      : AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      auth.isAuthenticated ? 'LIVE' : 'DEMO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Settings button
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.goldPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _screens.map((screen) => screen['widget'] as Widget).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(
            top: BorderSide(
              color: AppColors.borderColor,
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          tabAlignment: TabAlignment.fill,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          tabs: _screens.map((screen) {
            return Tab(
              icon: Icon(
                screen['icon'] as IconData,
                size: 20,
              ),
              text: screen['title'] as String,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DashboardHomeTab extends StatefulWidget {
  const _DashboardHomeTab();

  @override
  State<_DashboardHomeTab> createState() => _DashboardHomeTabState();
}

class _DashboardHomeTabState extends State<_DashboardHomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 300;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.goldPrimary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header with greeting and subscription status
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthService>(
                      builder: (context, auth, child) {
                        final user = auth.currentUser;
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email.split('@')[0].toUpperCase() ??
                                        'Trader',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (user != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: user.subscriptionTier == 'premium'
                                      ? LinearGradient(
                                          colors: [
                                            AppColors.goldPrimary,
                                            AppColors.warning
                                          ],
                                        )
                                      : null,
                                  color: user.subscriptionTier == 'premium'
                                      ? null
                                      : AppColors.info,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  user.subscriptionTier.toUpperCase(),
                                  style: TextStyle(
                                    color: user.subscriptionTier == 'premium'
                                        ? AppColors.primaryDark
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Subscription Status Widget
            const SliverToBoxAdapter(
              child: SubscriptionStatusWidget(),
            ),

            // Top cryptos price tiles
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    PriceTile(
                      symbol: 'BTC',
                      price: 94825.67,
                      change: 2.45,
                    ),
                    const SizedBox(width: 12),
                    PriceTile(
                      symbol: 'ETH',
                      price: 3245.89,
                      change: 1.23,
                    ),
                    const SizedBox(width: 12),
                    PriceTile(
                      symbol: 'BNB',
                      price: 642.15,
                      change: -0.67,
                    ),
                    const SizedBox(width: 12),
                    PriceTile(
                      symbol: 'SOL',
                      price: 234.56,
                      change: 5.89,
                    ),
                    const SizedBox(width: 12),
                    PriceTile(
                      symbol: 'ADA',
                      price: 1.23,
                      change: 3.45,
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuickActionsWidget(
                  onBuyPressed: () => _showComingSoon('Buy'),
                  onSellPressed: () => _showComingSoon('Sell'),
                  onSwapPressed: () => _showComingSoon('Swap'),
                  onTransferPressed: () => _showComingSoon('Transfer'),
                  onDepositPressed: () => _showComingSoon('Deposit'),
                  onWithdrawPressed: () => _showComingSoon('Withdraw'),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Market Overview and Portfolio
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: MarketOverviewWidget()),
                    const SizedBox(width: 16),
                    Expanded(child: PortfolioWidget()),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Recent Alerts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecentAlertsWidget(),
              ),
            ),

            // Ad space for free users
            SliverToBoxAdapter(
              child: Consumer<AuthService>(
                builder: (context, auth, child) {
                  final user = auth.currentUser;
                  if (user?.subscriptionTier == 'free') {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.goldPrimary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upgrade to Premium',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Get advanced features, real-time data, and remove ads',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Show upgrade dialog
                              _showComingSoon('Premium Upgrade');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldPrimary,
                              foregroundColor: AppColors.primaryDark,
                            ),
                            child: const Text('Upgrade Now'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data refreshed'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'More Options',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Tools & Analysis',
              [
                _buildMenuItem(
                  'Plugins',
                  'Manage and install trading plugins',
                  Icons.extension,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PluginsScreen()),
                  ),
                ),
                _buildMenuItem(
                  'Technical Analysis',
                  'Advanced charting and indicators',
                  Icons.show_chart,
                  () => _showComingSoon(context, 'Technical Analysis'),
                ),
                _buildMenuItem(
                  'Backtesting',
                  'Test your strategies with historical data',
                  Icons.history,
                  () => _showComingSoon(context, 'Backtesting'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Account & Settings',
              [
                _buildMenuItem(
                  'Settings',
                  'App preferences and configuration',
                  Icons.settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  ),
                ),
                _buildMenuItem(
                  'Security',
                  'Two-factor authentication and security',
                  Icons.security,
                  () => _showComingSoon(context, 'Security Settings'),
                ),
                _buildMenuItem(
                  'API Management',
                  'Manage your API keys and connections',
                  Icons.api,
                  () => _showComingSoon(context, 'API Management'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Learning & Support',
              [
                _buildMenuItem(
                  'Trading Academy',
                  'Learn trading strategies and techniques',
                  Icons.school,
                  () => _showComingSoon(context, 'Trading Academy'),
                ),
                _buildMenuItem(
                  'Help & Support',
                  'Get help and contact support',
                  Icons.help,
                  () => _showComingSoon(context, 'Help & Support'),
                ),
                _buildMenuItem(
                  'Community',
                  'Join our trading community',
                  Icons.people,
                  () => _showComingSoon(context, 'Community'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Consumer<AuthService>(
              builder: (context, auth, child) {
                final user = auth.currentUser;
                if (user?.subscriptionTier != 'premium') {
                  return Card(
                    color: AppColors.surfaceDark,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.goldPrimary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlock Premium Features',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Get access to advanced tools, real-time data, unlimited alerts, and more!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _showComingSoon(context, 'Premium Upgrade'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.goldPrimary,
                                foregroundColor: AppColors.primaryDark,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Upgrade to Premium'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.surfaceDark,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.goldPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
