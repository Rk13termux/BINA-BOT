import 'package:flutter/material.dart';
import '../../services/binance_service.dart';
import '../../services/groq_service.dart';
import '../../models/user.dart';
import '../../models/account_info.dart';
import '../indicators/technical_indicators_panel.dart';
import 'widgets/quantix_elite_chart.dart';
import 'widgets/binance_pairs_selector.dart';
import 'widgets/portfolio_balance_widget.dart';
import '../../ui/widgets/quantix_floating_menu.dart';
import 'package:provider/provider.dart';
import '../../services/binance_websocket_service.dart';
import 'dart:async';
import '../plugin_center/plugin_center_screen.dart';
import '../news_scraper/news_scraper_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';

class QuantixDashboard extends StatefulWidget {
  const QuantixDashboard({Key? key}) : super(key: key);

  @override
  State<QuantixDashboard> createState() => _QuantixDashboardState();
}

class _QuantixDashboardState extends State<QuantixDashboard> {
  String _selectedSymbol = 'BTCUSDT';
  String _selectedTimeframe = '1h';
  List<String> _selectedIndicators = [];
  User? _user;
  AccountInfo? _accountInfo;
  double _totalBalance = 0.0;
  bool _isLoading = true;
  String _aiAnalysis = '';
  bool _isConnected = false;
  List<double> _prices = [];
  // Eliminar: StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadMarketData();
    _initWebSocket();
  }

  @override
  void dispose() {
    // _wsSubscription?.cancel(); // Eliminar esto
    super.dispose();
  }

  void _initWebSocket() async {
    final ws = Provider.of<BinanceWebSocketService>(context, listen: false);
    await ws.connect();
    await ws.subscribeToTicker(_selectedSymbol);
    // No usar addListener aquí
  }

  void _onPairChanged(String pair) async {
    setState(() {
      _selectedSymbol = pair;
    });
    final ws = Provider.of<BinanceWebSocketService>(context, listen: false);
    await ws.subscribeToTicker(pair);
    _loadMarketData();
    _loadAIAnalysis();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final binance = BinanceService();
      await binance.initialize();
      final account = binance.accountInfo;
      final user = User(
        id: 'demo',
        email: '',
        displayName: 'Usuario QUANTIX',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      double total = 0.0;
      if (account != null) {
        for (final asset in account.balances) {
          if (asset.asset == 'USDT') {
            total += asset.free;
          }
        }
      }
      setState(() {
        _user = user;
        _accountInfo = account;
        _totalBalance = total;
        _isConnected = binance.isConnected;
        _isLoading = false;
      });
      _loadAIAnalysis();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  Future<void> _loadMarketData() async {
    try {
      final binance = BinanceService();
      // Obtener datos de velas para el símbolo y timeframe seleccionados
      final candles = await binance.getCandlestickData(
          symbol: _selectedSymbol, interval: _selectedTimeframe);
      // Extraer precios de cierre para los indicadores
      final prices = candles.map((c) => c.close).toList();
      setState(() {
        _prices = prices;
      });
    } catch (e) {
      setState(() {
        _prices = [];
      });
    }
  }

  Future<void> _loadAIAnalysis() async {
    try {
      final groq = GroqService();
      final result = await groq.getChatCompletion(messages: [
        // Puedes personalizar el prompt para análisis de mercado
        // Ejemplo:
        // ChatMessage(role: 'user', content: 'Analiza el mercado de $_selectedSymbol en timeframe $_selectedTimeframe')
      ]);
      setState(() {
        _aiAnalysis = result;
      });
    } catch (_) {
      setState(() {
        _aiAnalysis = 'No disponible.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent))
            : Column(
                children: [
                  _buildUserPanel(),
                  _buildBalancePanel(),
                  _buildPairSelector(),
                  Expanded(child: _buildMainChart()),
                  _buildIndicatorsPanel(),
                  _buildAIAnalysisPanel(),
                ],
              ),
      ),
      floatingActionButton: _buildFloatingMenu(context),
    );
  }

  Widget _buildUserPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        gradient:
            LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF2C5364)]),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 24,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_user?.displayName ?? 'Usuario',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              Row(
                children: [
                  Icon(_isConnected ? Icons.check_circle : Icons.cancel,
                      color:
                          _isConnected ? Colors.greenAccent : Colors.redAccent,
                      size: 16),
                  const SizedBox(width: 4),
                  Text(_isConnected ? 'Conectado' : 'Desconectado',
                      style: TextStyle(
                          color: _isConnected
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalancePanel() {
    return const PortfolioBalanceWidget();
  }

  Widget _buildPairSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: BinancePairsSelector(
        onPairSelected: _onPairChanged,
      ),
    );
  }

  Widget _buildMainChart() {
    return Consumer<BinanceWebSocketService>(
      builder: (context, ws, child) {
        final price = ws.getPrice(_selectedSymbol);
        if (price != null && _prices.isNotEmpty) {
          _prices[_prices.length - 1] = price;
        }
        return QuantixEliteChart(
          symbol: _selectedSymbol,
          timeframe: _selectedTimeframe,
          selectedIndicators: _selectedIndicators,
          onIndicatorCategorySelected: (cat) {},
          onIndicatorSelected: (ind) {
            setState(() {
              if (_selectedIndicators.contains(ind)) {
                _selectedIndicators.remove(ind);
              } else {
                _selectedIndicators.add(ind);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildIndicatorsPanel() {
    return TechnicalIndicatorsPanel(
      prices: _prices,
    );
  }

  Widget _buildAIAnalysisPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _aiAnalysis.isNotEmpty
                  ? _aiAnalysis
                  : 'Análisis AI no disponible.',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenu(BuildContext context) {
    return QuantixFloatingMenu(
      items: [
        QuantixMenuItem(
          icon: Icons.settings,
          label: 'Ajustes',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        QuantixMenuItem(
          icon: Icons.extension,
          label: 'Plugins',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PluginCenterScreen()),
          ),
        ),
        QuantixMenuItem(
          icon: Icons.article,
          label: 'Noticias',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewsScraperScreen()),
          ),
        ),
        QuantixMenuItem(
          icon: Icons.notifications,
          label: 'Notificaciones',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        QuantixMenuItem(
          icon: Icons.swap_vert,
          label: 'Trading',
          onTap: () => Navigator.of(context).pushNamed('/trading'),
        ),
        QuantixMenuItem(
          icon: Icons.bar_chart,
          label: 'Indicadores',
          onTap: () {},
        ),
        QuantixMenuItem(
          icon: Icons.history,
          label: 'Historial',
          onTap: () {},
        ),
        QuantixMenuItem(
          icon: Icons.help_outline,
          label: 'Ayuda',
          onTap: () {},
        ),
      ],
      onAIButtonPressed: () => Navigator.of(context).pushNamed('/ai-chat'),
    );
  }
}
