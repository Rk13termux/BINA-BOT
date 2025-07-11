import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
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
import '../../services/subscription_service.dart';

/// Pantalla principal del dashboard con navegación por pestañas
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invictus Trader Pro',
          style: AppTheme.headlineSmall.copyWith(
            color: AppColors.goldPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botón de configuración
          IconButton(
            icon: const Icon(Icons.settings),
            color: AppColors.textSecondary,
            onPressed: () {
              // TODO: Navegar a configuración
            },
          ),
          // Indicador de conexión
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Live',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketOverview(),
          _buildTradingTab(),
          _buildPortfolioTab(),
          _buildNewsTab(),
          _buildAlertsTab(),
        ],
      ),
      bottomNavigationBar: Material(
        color: AppColors.secondaryDark,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.trending_up,
                color: _currentIndex == 0 ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              text: 'Market',
            ),
            Tab(
              icon: Icon(
                Icons.swap_horiz,
                color: _currentIndex == 1 ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              text: 'Trade',
            ),
            Tab(
              icon: Icon(
                Icons.account_balance_wallet,
                color: _currentIndex == 2 ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              text: 'Portfolio',
            ),
            Tab(
              icon: Icon(
                Icons.article,
                color: _currentIndex == 3 ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              text: 'News',
            ),
            Tab(
              icon: Icon(
                Icons.notifications,
                color: _currentIndex == 4 ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              text: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }

  /// Tab de visión general del mercado
  Widget _buildMarketOverview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen del mercado
          _buildMarketSummaryCard(),
          const SizedBox(height: 16),
          
          // Lista de principales criptomonedas
          Text(
            'Top Cryptocurrencies',
            style: AppTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          Expanded(
            child: _buildCryptocurrencyList(),
          ),
        ],
      ),
    );
  }

  /// Tarjeta resumen del mercado
  Widget _buildMarketSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Market Summary',
              style: AppTheme.titleMedium.copyWith(
                color: AppColors.goldPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMarketStat('Total Market Cap', '\$2.14T', '+2.34%', true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMarketStat('24h Volume', '\$87.2B', '-1.12%', false),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMarketStat('Bitcoin Dominance', '42.3%', '+0.8%', true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMarketStat('Fear & Greed Index', '67 (Greed)', '', null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de estadística del mercado
  Widget _buildMarketStat(String label, String value, String change, bool? isPositive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (change.isNotEmpty)
          Text(
            change,
            style: AppTheme.bodySmall.copyWith(
              color: isPositive == true ? AppColors.bullish : AppColors.bearish,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  /// Lista de criptomonedas principales
  Widget _buildCryptocurrencyList() {
    final cryptos = [
      {'symbol': 'BTCUSDT', 'name': 'Bitcoin', 'price': '43,256.78', 'change': '+2.34%', 'isPositive': true},
      {'symbol': 'ETHUSDT', 'name': 'Ethereum', 'price': '2,678.90', 'change': '+1.87%', 'isPositive': true},
      {'symbol': 'BNBUSDT', 'name': 'BNB', 'price': '312.45', 'change': '-0.92%', 'isPositive': false},
      {'symbol': 'SOLUSDT', 'name': 'Solana', 'price': '98.76', 'change': '+4.21%', 'isPositive': true},
      {'symbol': 'ADAUSDT', 'name': 'Cardano', 'price': '0.4567', 'change': '-1.45%', 'isPositive': false},
    ];

    return ListView.builder(
      itemCount: cryptos.length,
      itemBuilder: (context, index) {
        final crypto = cryptos[index];
        return _buildCryptoItem(crypto);
      },
    );
  }

  /// Item individual de criptomoneda
  Widget _buildCryptoItem(Map<String, dynamic> crypto) {
    final bool isPositive = crypto['isPositive'] as bool;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.goldPrimary,
          child: Text(
            crypto['symbol'].toString().substring(0, 3),
            style: AppTheme.bodySmall.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          crypto['name'] as String,
          style: AppTheme.titleSmall,
        ),
        subtitle: Text(
          crypto['symbol'] as String,
          style: AppTheme.bodySmall,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\$${crypto['price']}',
              style: AppTheme.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              crypto['change'] as String,
              style: AppTheme.bodySmall.copyWith(
                color: isPositive ? AppColors.bullish : AppColors.bearish,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        onTap: () {
          // TODO: Navegar a detalles de la criptomoneda
        },
      ),
    );
  }

  /// Tab de trading
  Widget _buildTradingTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 64,
            color: AppColors.goldPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'Trading Module',
            style: AppTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Tab de portfolio
  Widget _buildPortfolioTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: AppColors.goldPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'Portfolio Management',
            style: AppTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Tab de noticias
  Widget _buildNewsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article,
            size: 64,
            color: AppColors.goldPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'Crypto News',
            style: AppTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Tab de alertas
  Widget _buildAlertsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications,
            size: 64,
            color: AppColors.goldPrimary,
          ),
          SizedBox(height: 16),
          Text(
            'Trading Alerts',
            style: AppTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
