import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/binance_account.dart';
import '../../services/binance_api_service.dart';
import '../../ui/theme/colors.dart';
import '../../utils/logger.dart';
import 'widgets/professional_portfolio_widget.dart';
import '../../ui/widgets/professional_candlestick_chart.dart';
import '../../models/chart_data.dart';

class BinaBotProMainDashboard extends StatefulWidget {
  const BinaBotProMainDashboard({Key? key}) : super(key: key);

  @override
  State<BinaBotProMainDashboard> createState() => _BinaBotProMainDashboardState();
}

class _BinaBotProMainDashboardState extends State<BinaBotProMainDashboard>
    with TickerProviderStateMixin {
  
  final AppLogger _logger = AppLogger();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Servicios
  late BinanceApiService _binanceService;
  
  // Estado
  BinanceAccount? _binanceAccount;
  bool _isConnected = false;
  bool _isLoading = true;
  String _selectedSymbol = 'BTCUSDT';
  List<CandleData> _chartData = [];
  
  // Datos del dashboard
  Map<String, double> _prices = {};
  Map<String, double> _changes24h = {};
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _loadDashboardData();
  }
  
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  void _initializeServices() {
    _binanceService = BinanceApiService();
    _binanceService.initialize();
    
    // Escuchar cambios en la cuenta
    _binanceService.accountStream.listen((account) {
      if (mounted) {
        setState(() {
          _binanceAccount = account;
          _isConnected = true;
          _isLoading = false;
        });
      }
    });
    
    // Escuchar estado de conexión
    _binanceService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (!isConnected) _isLoading = false;
        });
      }
    });
  }
  
  Future<void> _loadDashboardData() async {
    try {
      // Cargar datos de precios principales
      await _loadMarketData();
      
      // Cargar datos del gráfico
      await _loadChartData();
      
    } catch (e) {
      _logger.error('Error cargando datos del dashboard: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadMarketData() async {
    try {
      // Simulación de datos de mercado (en producción usar API real)
      _prices = {
        'BTC': 43250.75,
        'ETH': 2580.30,
        'BNB': 315.45,
        'ADA': 0.485,
        'XRP': 0.625,
      };
      
      _changes24h = {
        'BTC': 2.45,
        'ETH': -1.23,
        'BNB': 0.87,
        'ADA': 3.21,
        'XRP': -0.65,
      };
    } catch (e) {
      _logger.error('Error cargando datos de mercado: $e');
    }
  }
  
  Future<void> _loadChartData() async {
    try {
      final klineData = await _binanceService.getKlineData(
        symbol: _selectedSymbol,
        interval: '1h',
        limit: 100,
      );
      
      if (klineData.isNotEmpty) {
        final candles = klineData.map((kline) {
          return CandleData.fromBinanceKline(kline, _selectedSymbol);
        }).toList();
        
        setState(() {
          _chartData = candles;
        });
      }
    } catch (e) {
      _logger.error('Error cargando datos del gráfico: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildConnectionStatus(),
                      const SizedBox(height: 20),
                      _buildBalanceOverview(),
                      const SizedBox(height: 20),
                      _buildMarketOverview(),
                      const SizedBox(height: 20),
                      _buildProfessionalChart(),
                      const SizedBox(height: 20),
                      _buildQuickActions(),
                      const SizedBox(height: 20),
                      _buildPortfolioSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.backgroundBlack,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.darkGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // Logo profesional con efecto dorado
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.logoGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.premiumBoxShadows,
                        ),
                        child: const Icon(
                          Icons.auto_graph,
                          color: AppColors.backgroundBlack,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BINA-BOT PRO',
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'Professional Trading Platform',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Indicador de estado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isConnected ? AppColors.bullish : AppColors.bearish,
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
                              _isConnected ? 'LIVE' : 'OFFLINE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _isConnected ? AppColors.bullishGradient : AppColors.bearishGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.premiumBoxShadows,
      ),
      child: Row(
        children: [
          Icon(
            _isConnected ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isConnected ? 'Binance API Conectada' : 'API Desconectada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isConnected 
                      ? 'Trading en tiempo real disponible'
                      : 'Configura tu API para comenzar',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!_isConnected)
            ElevatedButton(
              onPressed: _showApiConfiguration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.backgroundBlack,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Configurar'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildBalanceOverview() {
    if (!_isConnected || _binanceAccount == null) {
      return _buildPlaceholderCard('Balance de Cuenta', 'Conecta tu API para ver el balance');
    }
    
    final totalBalance = _binanceAccount!.totalBalanceUSDT;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.premiumBoxShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.backgroundBlack,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Balance Total',
                style: TextStyle(
                  color: AppColors.backgroundBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '\$${totalBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.backgroundBlack,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuenta Binance Spot',
            style: TextStyle(
              color: AppColors.backgroundBlack.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMarketOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.goldPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Mercado Principal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_prices.entries.map((entry) => _buildPriceItem(entry.key, entry.value))),
        ],
      ),
    );
  }
  
  Widget _buildPriceItem(String symbol, double price) {
    final change = _changes24h[symbol] ?? 0.0;
    final isPositive = change >= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  color: AppColors.backgroundBlack,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol == 'BTC' ? 'Bitcoin' :
                  symbol == 'ETH' ? 'Ethereum' :
                  symbol == 'BNB' ? 'Binance Coin' :
                  symbol == 'ADA' ? 'Cardano' : 'Ripple',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  symbol,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.bullish : AppColors.bearish).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: isPositive ? AppColors.bullish : AppColors.bearish,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfessionalChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.candlestick_chart,
                color: AppColors.goldPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Gráfico Profesional - $_selectedSymbol',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '1H',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _chartData.isNotEmpty
                ? ProfessionalCandlestickChart(
                    candles: _chartData,
                    symbol: _selectedSymbol,
                    interval: ChartInterval.h1,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando gráfico...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildActionButton('Comprar', Icons.trending_up, AppColors.bullish)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton('Vender', Icons.trending_down, AppColors.bearish)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton('Alertas', Icons.notifications, AppColors.warning)),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton('Análisis', Icons.analytics, AppColors.info)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _handleQuickAction(title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPortfolioSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: AppColors.goldPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Portfolio Profesional',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _showFullPortfolio,
                child: Text(
                  'Ver Todo',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isConnected && _binanceAccount != null)
            SizedBox(
              height: 400,
              child: ProfessionalPortfolioWidget(
                binanceService: _binanceService,
              ),
            )
          else
            _buildPlaceholderCard('Portfolio', 'Conecta tu API para ver el portfolio'),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderCard(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _showApiConfiguration() {
    // TODO: Mostrar diálogo de configuración de API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Configurar API Binance',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Configura tu API de Binance para acceder a todas las funcionalidades profesionales.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navegar a configuración de API
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.backgroundBlack,
            ),
            child: const Text('Configurar'),
          ),
        ],
      ),
    );
  }
  
  void _handleQuickAction(String action) {
    HapticFeedback.lightImpact();
    _logger.info('Acción rápida: $action');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action - Próximamente en BINA-BOT PRO'),
        backgroundColor: AppColors.goldPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showFullPortfolio() {
    // TODO: Navegar a portfolio completo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.backgroundBlack,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundBlack,
            title: Text(
              'Portfolio Completo',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          body: ProfessionalPortfolioWidget(
            binanceService: _binanceService,
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
