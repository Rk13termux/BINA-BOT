import 'package:flutter/material.dart';
import '../../models/binance_account.dart';
import '../../models/chart_data.dart';
import '../../services/binance_api_service.dart';
import '../../ui/widgets/professional_candlestick_chart.dart';
import '../../utils/constants.dart';
import '../../utils/logger.dart';

class ProfessionalAnalysisDashboard extends StatefulWidget {
  const ProfessionalAnalysisDashboard({Key? key}) : super(key: key);

  @override
  State<ProfessionalAnalysisDashboard> createState() => _ProfessionalAnalysisDashboardState();
}

class _ProfessionalAnalysisDashboardState extends State<ProfessionalAnalysisDashboard>
    with TickerProviderStateMixin {
  
  final AppLogger _logger = AppLogger();
  late TabController _tabController;
  
  // Servicios
  late BinanceApiService _binanceService;
  
  // Estado
  String _selectedSymbol = 'BTCUSDT';
  ChartInterval _selectedInterval = ChartInterval.h1;
  List<CandleData> _candleData = [];
  OrderBookData? _orderBookData;
  BinanceAccount? _binanceAccount;
  bool _isLoadingChart = false;
  bool _isLoadingAccount = false;
  bool _showOrderBook = false;
  
  // Símbolos populares
  final List<String> _popularSymbols = [
    'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'DOGEUSDT',
    'XRPUSDT', 'DOTUSDT', 'UNIUSDT', 'LINKUSDT', 'LTCUSDT',
    'SOLUSDT', 'MATICUSDT', 'AVAXUSDT', 'ATOMUSDT', 'FILUSDT'
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadInitialData();
  }
  
  void _initializeServices() {
    _binanceService = BinanceApiService();
    
    _binanceService.initialize();
    
    // Escuchar cambios en la cuenta
    _binanceService.accountStream.listen((account) {
      if (mounted) {
        setState(() {
          _binanceAccount = account;
          _isLoadingAccount = false;
        });
      }
    });
    
    // Escuchar cambios en la conexión
    _binanceService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isLoadingAccount = !isConnected;
        });
      }
    });
  }
  
  Future<void> _loadInitialData() async {
    await _loadChartData();
    if (_showOrderBook) {
      await _loadOrderBookData();
    }
  }
  
  Future<void> _loadChartData() async {
    setState(() {
      _isLoadingChart = true;
    });
    
    try {
      _logger.info('Cargando datos de gráfico para $_selectedSymbol');
      
      final klineData = await _binanceService.getKlineData(
        symbol: _selectedSymbol,
        interval: _selectedInterval.binanceInterval,
        limit: 200,
      );
      
      if (klineData.isNotEmpty) {
        final candles = klineData.map((kline) {
          return CandleData.fromBinanceKline(kline, _selectedSymbol);
        }).toList();
        
        setState(() {
          _candleData = candles;
        });
        
        _logger.info('✅ Datos de gráfico cargados: ${candles.length} velas');
      } else {
        _logger.warning('No se encontraron datos de kline para $_selectedSymbol');
      }
      
    } catch (e) {
      _logger.error('Error cargando datos de gráfico: $e');
      _showErrorSnackBar('Error cargando datos del gráfico');
    } finally {
      setState(() {
        _isLoadingChart = false;
      });
    }
  }
  
  Future<void> _loadOrderBookData() async {
    try {
      final orderBookResponse = await _binanceService.getOrderBookDepth(
        symbol: _selectedSymbol,
        limit: 20,
      );
      
      if (orderBookResponse != null) {
        setState(() {
          _orderBookData = OrderBookData.fromBinanceResponse(
            orderBookResponse,
            _selectedSymbol,
          );
        });
      }
      
    } catch (e) {
      _logger.error('Error cargando order book: $e');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bearishRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(),
                _buildAccountTab(),
                _buildPortfolioTab(),
                _buildMarketsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            Icons.analytics,
            color: AppColors.goldPrimary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Invictus Trader Pro',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Conexión Binance
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _binanceService.isConnected
                    ? AppColors.bullishGreen
                    : AppColors.bearishRed,
              ),
              const SizedBox(width: 8),
              Text(
                _binanceService.isConnected ? 'Binance' : 'Desconectado',
                style: TextStyle(
                  color: _binanceService.isConnected
                      ? AppColors.bullishGreen
                      : AppColors.bearishRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // Configuración
        IconButton(
          onPressed: _showConfigurationDialog,
          icon: Icon(
            Icons.settings,
            color: AppColors.goldPrimary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Balance Total',
              _binanceAccount?.totalWalletBalance.toStringAsFixed(2) ?? '0.00',
              'USDT',
              AppColors.goldPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'PnL 24h',
              '+1,234.56',
              'USDT',
              AppColors.bullishGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Activos',
              _binanceAccount?.balances.where((b) => b.total > 0).length.toString() ?? '0',
              'tokens',
              AppColors.goldPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'BTC Precio',
              _candleData.isNotEmpty ? '\$${_candleData.last.close.toStringAsFixed(0)}' : '\$0',
              '',
              AppColors.goldPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.goldPrimary,
        indicatorWeight: 3,
        labelColor: AppColors.goldPrimary,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Análisis'),
          Tab(text: 'Cuenta'),
          Tab(text: 'Portfolio'),
          Tab(text: 'Mercados'),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisTab() {
    return Column(
      children: [
        // Selector de símbolo
        Container(
          height: 60,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.goldPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSymbol,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundDark,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (symbol) {
                        if (symbol != null) {
                          setState(() {
                            _selectedSymbol = symbol;
                          });
                          _loadChartData();
                          if (_showOrderBook) {
                            _loadOrderBookData();
                          }
                        }
                      },
                      items: _popularSymbols.map((symbol) {
                        return DropdownMenuItem(
                          value: symbol,
                          child: Text(symbol),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Toggle Order Book
              Container(
                decoration: BoxDecoration(
                  color: _showOrderBook
                      ? AppColors.goldPrimary.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.goldPrimary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showOrderBook = !_showOrderBook;
                    });
                    if (_showOrderBook) {
                      _loadOrderBookData();
                    }
                  },
                  icon: Icon(
                    Icons.list_alt,
                    color: AppColors.goldPrimary,
                  ),
                  tooltip: 'Order Book',
                ),
              ),
            ],
          ),
        ),
        
        // Gráfico principal
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoadingChart
                ? _buildLoadingChart()
                : ProfessionalCandlestickChart(
                    candles: _candleData,
                    symbol: _selectedSymbol,
                    interval: _selectedInterval,
                    showVolume: true,
                    showOrderBook: _showOrderBook,
                    orderBook: _orderBookData,
                    onIntervalChanged: _loadChartData,
                    onIntervalSelected: (interval) {
                      setState(() {
                        _selectedInterval = interval;
                      });
                      _loadChartData();
                    },
                  ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingChart() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando datos del gráfico...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountTab() {
    if (!_binanceService.isConnected) {
      return _buildConnectAccountWidget();
    }
    
    if (_isLoadingAccount || _binanceAccount == null) {
      return _buildLoadingWidget('Cargando información de cuenta...');
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la cuenta
          _buildAccountInfoCard(),
          const SizedBox(height: 16),
          
          // Balances
          _buildBalancesCard(),
          const SizedBox(height: 16),
          
          // Comisiones
          _buildCommissionsCard(),
        ],
      ),
    );
  }
  
  Widget _buildConnectAccountWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: AppColors.goldPrimary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Conectar cuenta Binance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Conecta tu cuenta de Binance para acceder a\\nfunciones avanzadas de análisis y trading',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showConfigurationDialog,
            icon: Icon(Icons.link),
            label: Text('Configurar API'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountInfoCard() {
    return Card(
      color: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: AppColors.goldPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Información de la Cuenta',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Tipo de Cuenta', _binanceAccount!.accountType),
            _buildInfoRow('Puede Tradear', _binanceAccount!.canTrade ? 'Sí' : 'No'),
            _buildInfoRow('Puede Retirar', _binanceAccount!.canWithdraw ? 'Sí' : 'No'),
            _buildInfoRow('Puede Depositar', _binanceAccount!.canDeposit ? 'Sí' : 'No'),
            _buildInfoRow('Balance Total', '\$${_binanceAccount!.totalWalletBalance.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBalancesCard() {
    final activeBalances = _binanceAccount!.balances
        .where((balance) => balance.total > 0)
        .toList();
    
    return Card(
      color: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: AppColors.goldPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Balances (${activeBalances.length})',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (activeBalances.isEmpty)
              Center(
                child: Text(
                  'No hay balances activos',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              )
            else
              Column(
                children: activeBalances.map((balance) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.goldPrimary.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Asset icon/name
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.goldPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              balance.asset.substring(0, balance.asset.length > 3 ? 3 : balance.asset.length),
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Asset info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                balance.asset,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Libre: ${balance.free.toStringAsFixed(8)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Balance amounts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              balance.total.toStringAsFixed(8),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (balance.locked > 0)
                              Text(
                                'Bloqueado: ${balance.locked.toStringAsFixed(8)}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommissionsCard() {
    return Card(
      color: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.percent,
                  color: AppColors.goldPrimary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Comisiones',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Comisión Maker', '${((_binanceAccount!.makerCommission ?? 0) / 10000).toStringAsFixed(4)}%'),
            _buildInfoRow('Comisión Taker', '${((_binanceAccount!.takerCommission ?? 0) / 10000).toStringAsFixed(4)}%'),
            _buildInfoRow('Comisión Compra', '${((_binanceAccount!.buyerCommission ?? 0) / 10000).toStringAsFixed(4)}%'),
            _buildInfoRow('Comisión Venta', '${((_binanceAccount!.sellerCommission ?? 0) / 10000).toStringAsFixed(4)}%'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioTab() {
    return Center(
      child: Text(
        'Portfolio - Próximamente',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildMarketsTab() {
    return Center(
      child: Text(
        'Mercados - Próximamente',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 18,
        ),
      ),
    );
  }
  
  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (context) => BinanceConfigDialog(
        binanceService: _binanceService,
        onConfigured: () {
          setState(() {
            _isLoadingAccount = true;
          });
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _binanceService.dispose();
    super.dispose();
  }
}

class BinanceConfigDialog extends StatefulWidget {
  final BinanceApiService binanceService;
  final VoidCallback? onConfigured;
  
  const BinanceConfigDialog({
    Key? key,
    required this.binanceService,
    this.onConfigured,
  }) : super(key: key);

  @override
  State<BinanceConfigDialog> createState() => _BinanceConfigDialogState();
}

class _BinanceConfigDialogState extends State<BinanceConfigDialog> {
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isTestnet = false;
  bool _isLoading = false;
  bool _obscureSecret = true;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.link,
            color: AppColors.goldPrimary,
          ),
          const SizedBox(width: 12),
          const Text(
            'Configurar API Binance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nombre (opcional)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _apiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'API Key *',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _secretKeyController,
              obscureText: _obscureSecret,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Secret Key *',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldPrimary),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureSecret = !_obscureSecret;
                    });
                  },
                  icon: Icon(
                    _obscureSecret ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              value: _isTestnet,
              onChanged: (value) {
                setState(() {
                  _isTestnet = value ?? false;
                });
              },
              title: const Text(
                'Usar Testnet',
                style: TextStyle(color: Colors.white),
              ),
              activeColor: AppColors.goldPrimary,
              checkColor: AppColors.backgroundDark,
            ),
            
            const SizedBox(height: 8),
            Text(
              'Tus credenciales se almacenan de forma segura en tu dispositivo.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        
        ElevatedButton(
          onPressed: _isLoading ? null : _saveConfiguration,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: AppColors.backgroundDark,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundDark),
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
  
  Future<void> _saveConfiguration() async {
    if (_apiKeyController.text.trim().isEmpty || _secretKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa API Key y Secret Key'),
          backgroundColor: AppColors.bearishRed,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await widget.binanceService.setApiCredentials(
        apiKey: _apiKeyController.text.trim(),
        secretKey: _secretKeyController.text.trim(),
        isTestnet: _isTestnet,
        nickname: _nicknameController.text.trim().isNotEmpty
            ? _nicknameController.text.trim()
            : null,
      );
      
      if (success) {
        widget.onConfigured?.call();
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Conexión con Binance establecida'),
            backgroundColor: AppColors.bullishGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al verificar credenciales'),
            backgroundColor: AppColors.bearishRed,
          ),
        );
      }
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.bearishRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }
}
