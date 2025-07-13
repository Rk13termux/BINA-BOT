import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../ui/widgets/free_price_widget.dart';
import '../trading/trading_screen.dart';
import '../alerts/alerts_screen.dart';
import '../settings/settings_screen.dart';
import '../plugins/plugins_screen.dart';
import '../ai/ai_news_screen.dart';

import 'widgets/market_overview_widget.dart';
import 'widgets/portfolio_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_alerts_widget.dart';
import 'free_crypto_screen.dart';
import '../../services/auth_service.dart';
import '../../services/binance_service.dart';

/// Pantalla principal del dashboard con menú lateral estilo Binance
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Dashboard',
      'icon': Icons.dashboard_outlined,
      'selectedIcon': Icons.dashboard,
      'widget': const _DashboardHomeTab(),
    },
    {
      'title': 'Mercados',
      'icon': Icons.trending_up_outlined,
      'selectedIcon': Icons.trending_up,
      'widget': const FreeCryptoScreen(),
    },
    {
      'title': 'Trading',
      'icon': Icons.show_chart_outlined,
      'selectedIcon': Icons.show_chart,
      'widget': const TradingScreen(),
    },
    {
      'title': 'AI News',
      'icon': Icons.psychology_outlined,
      'selectedIcon': Icons.psychology,
      'widget': const AINewsScreen(),
    },
    {
      'title': 'Portfolio',
      'icon': Icons.account_balance_wallet_outlined,
      'selectedIcon': Icons.account_balance_wallet,
      'widget': const _PortfolioTab(),
    },
    {
      'title': 'Alertas',
      'icon': Icons.notifications_outlined,
      'selectedIcon': Icons.notifications,
      'widget': const AlertsScreen(),
    },
    {
      'title': 'Plugins',
      'icon': Icons.extension_outlined,
      'selectedIcon': Icons.extension,
      'widget': const PluginsScreen(),
    },
    {
      'title': 'Configuración',
      'icon': Icons.settings_outlined,
      'selectedIcon': Icons.settings,
      'widget': const SettingsScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark, // Negro puro profesional
      body: Row(
        children: [
          // Menú lateral profesional desplegable
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 280 : 80,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              border: Border(
                right: BorderSide(
                  color: AppColors.goldPrimary,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header del menú
                _buildMenuHeader(),
                
                // Items del menú
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(index);
                    },
                  ),
                ),
                
                // Footer del menú
                _buildMenuFooter(),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Top bar estilo Binance
                _buildTopBar(),
                
                // Contenido de la página actual
                Expanded(
                  child: _menuItems[_selectedIndex]['widget'] as Widget,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construir header del menú
  Widget _buildMenuHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldPrimary,
            width: 1,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Logo/Icon profesional
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.goldPrimary,
                  AppColors.goldSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.black,
              size: 24,
            ),
          ),
          if (_isDrawerOpen) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'BINA-BOT PRO',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Professional AI Trading',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Toggle button profesional
          GestureDetector(
            onTap: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.goldPrimary,
                  width: 1,
                ),
              ),
              child: Icon(
                _isDrawerOpen ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                color: AppColors.goldPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construir item del menú profesional
  Widget _buildMenuItem(int index) {
    final item = _menuItems[index];
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(
                      colors: [
                        AppColors.goldPrimary.withOpacity(0.2),
                        AppColors.goldSecondary.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.goldPrimary, width: 1)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.goldPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.goldPrimary
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? item['selectedIcon'] : item['icon'],
                    color: isSelected 
                        ? AppColors.primaryDark
                        : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
                if (_isDrawerOpen) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected 
                            ? AppColors.goldPrimary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.goldPrimary,
                      size: 12,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construir footer del menú
  Widget _buildMenuFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFF2B3139),
            width: 1,
          ),
        ),
      ),
      child: Consumer<AuthService>(
        builder: (context, auth, child) {
          final user = auth.currentUser;
          return Row(
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0B90B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              if (_isDrawerOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email.split('@')[0].toUpperCase() ?? 'Trader',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0ECB81),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Construir top bar
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldPrimary,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Título de la página actual
          Text(
            _menuItems[_selectedIndex]['title'],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          
          // Balance info when connected
          Consumer<BinanceService>(
            builder: (context, binanceService, child) {
              if (binanceService.isAuthenticated && binanceService.balances.isNotEmpty) {
                return FutureBuilder<double>(
                  future: binanceService.getTotalBalanceUSDT(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.goldPrimary, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.goldPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '\$${snapshot.data!.toStringAsFixed(2)}',
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
                    return const SizedBox.shrink();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(width: 16),
          
          // Indicador de conexión API
          Consumer<BinanceService>(
            builder: (context, binanceService, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: binanceService.isAuthenticated && binanceService.isConnected
                      ? AppColors.bullish
                      : AppColors.bearish,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      binanceService.isAuthenticated && binanceService.isConnected 
                          ? 'API CONECTADA' 
                          : 'API DESCONECTADA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          
          // Botón de configuración de API
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showApiConfigDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.goldPrimary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.api,
                  color: AppColors.goldPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo de configuración de API
  void _showApiConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => const ApiConfigDialog(),
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

// Diálogo de configuración de API
class ApiConfigDialog extends StatefulWidget {
  const ApiConfigDialog({super.key});

  @override
  State<ApiConfigDialog> createState() => _ApiConfigDialogState();
}

class _ApiConfigDialogState extends State<ApiConfigDialog> {
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isTestNet = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final credentials = await authService.getApiCredentials();
    setState(() {
      _apiKeyController.text = credentials['apiKey'] ?? '';
      _secretKeyController.text = credentials['apiSecret'] ?? '';
      _isTestNet = credentials['testNet'] == 'true';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E2329),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0B90B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.api,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configurar API Binance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Configura tu API de Binance para acceder a todas las funcionalidades profesionales.',
                        style: TextStyle(
                          color: Color(0xFF848E9C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF848E9C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // API Key
            const Text(
              'API Key',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ingresa tu API Key de Binance',
                hintStyle: const TextStyle(color: Color(0xFF848E9C)),
                filled: true,
                fillColor: const Color(0xFF2B3139),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF0B90B)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Secret Key
            const Text(
              'Secret Key',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _secretKeyController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ingresa tu Secret Key de Binance',
                hintStyle: const TextStyle(color: Color(0xFF848E9C)),
                filled: true,
                fillColor: const Color(0xFF2B3139),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFF0B90B)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TestNet Toggle
            Row(
              children: [
                Switch(
                  value: _isTestNet,
                  onChanged: (value) {
                    setState(() {
                      _isTestNet = value;
                    });
                  },
                  activeColor: const Color(0xFFF0B90B),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usar TestNet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Habilita para usar el entorno de pruebas de Binance',
                        style: TextStyle(
                          color: Color(0xFF848E9C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF848E9C)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Color(0xFF848E9C)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveApiConfig,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0B90B),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Configurar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveApiConfig() async {
    if (_apiKeyController.text.trim().isEmpty || _secretKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tanto el API Key como el Secret Key'),
          backgroundColor: Color(0xFFF6465D),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final binanceService = Provider.of<BinanceService>(context, listen: false);

      // Configurar credenciales directamente en BinanceService
      await binanceService.setCredentials(
        _apiKeyController.text.trim(),
        _secretKeyController.text.trim(),
        _isTestNet,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('¡API configurada exitosamente!'),
              ],
            ),
            backgroundColor: AppColors.bullish,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al configurar API: $e')),
              ],
            ),
            backgroundColor: AppColors.bearish,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }
}

// Tab de Portfolio
class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab();

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
                  const Color(0xFFF0B90B).withOpacity(0.2),
                  const Color(0xFFF0B90B).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF0B90B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 48,
                  color: Color(0xFFF0B90B),
                ),
                SizedBox(height: 16),
                Text(
                  'Portfolio Profesional',
                  style: TextStyle(
                    color: Color(0xFFF0B90B),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Seguimiento avanzado de tu portfolio con análisis en tiempo real',
                  style: TextStyle(
                    color: Color(0xFF848E9C),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Widget de Portfolio
          const Expanded(
            child: PortfolioWidget(),
          ),
        ],
      ),
    );
  }
}
