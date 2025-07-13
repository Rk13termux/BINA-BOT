import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/free_price_widget.dart';
import '../trading/trading_screen.dart';
import '../alerts/alerts_screen.dart';
import '../settings/settings_screen.dart';
import '../plugins/plugins_screen.dart';

import 'widgets/market_overview_widget.dart';
import 'widgets/portfolio_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_alerts_widget.dart';
import 'free_crypto_screen.dart';
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
      'title': 'Analysis',
      'icon': Icons.analytics,
      'widget': const _AnalysisTab(),
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
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.goldPrimary,
                                      AppColors.warning
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.black,
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

            // Subscription Status Widget - Eliminado ya que todas las funciones son gratuitas

            // Top cryptos price tiles - All users have access to real-time prices
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precios en Tiempo Real',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FreeCryptoScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward,
                            color: AppColors.goldPrimary,
                            size: 16,
                          ),
                          label: Text(
                            'Ver más',
                            style: TextStyle(
                              color: AppColors.goldPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: FreePriceWidget(
                      symbols: ['BTC', 'ETH', 'BNB', 'SOL', 'ADA'],
                      showHeader: false,
                    ),
                  ),
                ],
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

            // All features are now free - no ads needed

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

/// Tab de análisis profesional
class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header con descripción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldPrimary.withOpacity(0.2),
                  AppColors.goldPrimary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics,
                  size: 48,
                  color: AppColors.goldPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Análisis Profesional',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gráficos avanzados, análisis técnico y conexión con Binance API para trading profesional',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botón principal para acceder al análisis
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/analysis');
              },
              icon: Icon(
                Icons.analytics,
                size: 24,
              ),
              label: Text(
                'Abrir Dashboard de Análisis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Lista de características
          Expanded(
            child: ListView(
              children: [
                _buildFeatureCard(
                  'Gráficos de Velas Profesionales',
                  'Visualización avanzada con múltiples intervalos de tiempo',
                  Icons.candlestick_chart,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Conexión Binance API',
                  'Datos en tiempo real y gestión de cuenta',
                  Icons.api,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Order Book en Tiempo Real',
                  'Profundidad de mercado y análisis de liquidez',
                  Icons.list_alt,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Análisis Técnico',
                  'Indicadores y herramientas de análisis avanzadas',
                  Icons.insights,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Portfolio Tracking',
                  'Seguimiento de balances y rendimiento',
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
            // All features are now free - no premium upgrade needed
            const SizedBox(height: 24),
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
