import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';
import '../wallet_overview/wallet_balance_widget.dart';
import '../indicators/technical_indicators_panel.dart';
import '../ai_analysis/quantix_ai_analyzer.dart';
import '../news_scraper/news_feed_widget.dart';
import '../signal_engine/signal_dashboard.dart';

/// 🚀 Dashboard Principal de QUANTIX AI CORE
/// Panel de control élite para trading profesional
class QuantixDashboard extends StatefulWidget {
  const QuantixDashboard({super.key});

  @override
  State<QuantixDashboard> createState() => _QuantixDashboardState();
}

class _QuantixDashboardState extends State<QuantixDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedSymbol = 'BTCUSDT';
  String _selectedTimeframe = '1m';
  bool _isRealTimeActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: QuantixTheme.darkGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header Elite
                _buildEliteHeader(),
                
                // Tab Bar
                _buildTabBar(),
                
                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildAnalysisTab(),
                      _buildSignalsTab(),
                      _buildNewsTab(),
                      _buildPortfolioTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActions(),
    );
  }

  /// Header principal con información del usuario
  Widget _buildEliteHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: QuantixTheme.goldGradient,
        boxShadow: [
          BoxShadow(
            color: QuantixTheme.primaryGold.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primera fila: Logo + Usuario + Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo QUANTIX
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: QuantixTheme.primaryBlack,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_graph,
                      color: QuantixTheme.primaryGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUANTIX',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: QuantixTheme.primaryBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI CORE',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: QuantixTheme.primaryBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Avatar y Estado
              Row(
                children: [
                  // Estado de conexión
                  _buildConnectionStatus(),
                  const SizedBox(width: 16),
                  
                  // Avatar del usuario
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: QuantixTheme.primaryBlack,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: QuantixTheme.electricBlue,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: QuantixTheme.primaryGold,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Segunda fila: Selector de símbolo y timeframe
          Row(
            children: [
              // Selector de símbolo
              Expanded(
                flex: 2,
                child: _buildSymbolSelector(),
              ),
              const SizedBox(width: 12),
              
              // Selector de timeframe
              Expanded(
                child: _buildTimeframeSelector(),
              ),
              const SizedBox(width: 12),
              
              // Toggle tiempo real
              _buildRealTimeToggle(),
            ],
          ),
        ],
      ),
    );
  }

  /// Tab Bar personalizada
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: QuantixTheme.cardBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          gradient: QuantixTheme.blueGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: QuantixTheme.primaryBlack,
        unselectedLabelColor: QuantixTheme.neutralGray,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
          Tab(icon: Icon(Icons.radar), text: 'Signals'),
          Tab(icon: Icon(Icons.article), text: 'News'),
          Tab(icon: Icon(Icons.account_balance_wallet), text: 'Portfolio'),
        ],
      ),
    );
  }

  /// Tab de Overview General
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Balance y métricas principales
          const WalletBalanceWidget(),
          const SizedBox(height: 20),
          
          // Gráfico principal (placeholder)
          _buildMainChart(),
          const SizedBox(height: 20),
          
          // Resumen de indicadores
          _buildIndicatorsSummary(),
        ],
      ),
    );
  }

  /// Tab de Análisis Técnico
  Widget _buildAnalysisTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TechnicalIndicatorsPanel(),
          SizedBox(height: 20),
          QuantixAIAnalyzer(),
        ],
      ),
    );
  }

  /// Tab de Señales
  Widget _buildSignalsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: SignalDashboard(),
    );
  }

  /// Tab de Noticias
  Widget _buildNewsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: NewsFeedWidget(),
    );
  }

  /// Tab de Portfolio
  Widget _buildPortfolioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const WalletBalanceWidget(),
          const SizedBox(height: 20),
          _buildPortfolioDistribution(),
          const SizedBox(height: 20),
          _buildRecentTrades(),
        ],
      ),
    );
  }

  /// Estado de conexión
  Widget _buildConnectionStatus() {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: QuantixTheme.bullishGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'LIVE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: QuantixTheme.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Selector de símbolo
  Widget _buildSymbolSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSymbol,
          onChanged: (value) => setState(() => _selectedSymbol = value!),
          dropdownColor: QuantixTheme.cardBlack,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: QuantixTheme.primaryGold,
            fontWeight: FontWeight.w600,
          ),
          items: ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'SOLUSDT']
              .map((symbol) => DropdownMenuItem(
                    value: symbol,
                    child: Text(symbol),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Selector de timeframe
  Widget _buildTimeframeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimeframe,
          onChanged: (value) => setState(() => _selectedTimeframe = value!),
          dropdownColor: QuantixTheme.cardBlack,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: QuantixTheme.electricBlue,
            fontWeight: FontWeight.w600,
          ),
          items: ['1m', '5m', '15m', '1h', '4h', '1d']
              .map((timeframe) => DropdownMenuItem(
                    value: timeframe,
                    child: Text(timeframe),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Toggle de tiempo real
  Widget _buildRealTimeToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isRealTimeActive = !_isRealTimeActive),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _isRealTimeActive 
              ? QuantixTheme.bullishGreen 
              : QuantixTheme.primaryBlack,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.flash_on,
          color: _isRealTimeActive 
              ? QuantixTheme.primaryBlack 
              : QuantixTheme.neutralGray,
          size: 20,
        ),
      ),
    );
  }

  /// Gráfico principal (placeholder)
  Widget _buildMainChart() {
    return Container(
      height: 300,
      decoration: QuantixTheme.eliteCardDecoration,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.candlestick_chart,
              size: 64,
              color: QuantixTheme.primaryGold,
            ),
            SizedBox(height: 16),
            Text(
              'Gráfico Profesional',
              style: TextStyle(
                color: QuantixTheme.lightGold,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Próximamente: Velas profesionales con indicadores',
              style: TextStyle(
                color: QuantixTheme.neutralGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Resumen de indicadores
  Widget _buildIndicatorsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Rápido',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickIndicator('RSI', '67.5', QuantixTheme.strongBuy),
              _buildQuickIndicator('MACD', 'BUY', QuantixTheme.buy),
              _buildQuickIndicator('BB', 'HOLD', QuantixTheme.hold),
              _buildQuickIndicator('SMA', 'SELL', QuantixTheme.sell),
            ],
          ),
        ],
      ),
    );
  }

  /// Indicador rápido
  Widget _buildQuickIndicator(String name, String value, Color color) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: QuantixTheme.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  /// Distribución del portfolio
  Widget _buildPortfolioDistribution() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución del Portfolio',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // TODO: Implementar gráfico de pie
          const Center(
            child: Text(
              'Gráfico de distribución próximamente',
              style: TextStyle(color: QuantixTheme.neutralGray),
            ),
          ),
        ],
      ),
    );
  }

  /// Trades recientes
  Widget _buildRecentTrades() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trades Recientes',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          // TODO: Implementar lista de trades
          const Center(
            child: Text(
              'Historial de trades próximamente',
              style: TextStyle(color: QuantixTheme.neutralGray),
            ),
          ),
        ],
      ),
    );
  }

  /// Acciones flotantes
  Widget _buildFloatingActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón de configuración
        FloatingActionButton(
          heroTag: 'settings',
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          backgroundColor: QuantixTheme.cardBlack,
          child: const Icon(Icons.settings, color: QuantixTheme.primaryGold),
        ),
        const SizedBox(height: 16),
        
        // Botón principal de trading
        FloatingActionButton.extended(
          heroTag: 'trade',
          onPressed: () => Navigator.pushNamed(context, '/trade'),
          backgroundColor: QuantixTheme.primaryGold,
          icon: const Icon(Icons.trending_up, color: QuantixTheme.primaryBlack),
          label: const Text(
            'TRADE',
            style: TextStyle(
              color: QuantixTheme.primaryBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
