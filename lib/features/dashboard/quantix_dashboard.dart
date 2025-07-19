import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';
import '../../../ui/widgets/quantix_floating_menu.dart';
import 'widgets/binance_pairs_selector.dart';
import 'widgets/quantix_elite_chart.dart';

/// 🚀 Dashboard Principal de QUANTIX AI CORE
/// Panel de control élite para trading profesional
class QuantixDashboard extends StatefulWidget {
  const QuantixDashboard({Key? key}) : super(key: key);

  @override
  State<QuantixDashboard> createState() => _QuantixDashboardState();
}

class _QuantixDashboardState extends State<QuantixDashboard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedSymbol = 'BTCUSDT';
  String _selectedTimeframe = '1m';
  List<String> _selectedIndicators = [];

  @override
  void initState() {
    super.initState();
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
                _buildEliteHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: BinancePairsSelector(
                    onPairSelected: (pair) {
                      setState(() {
                        _selectedSymbol = pair;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: QuantixEliteChart(
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActions(context),
    );
  }

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                ],
              ),
            ],
          ),
          _buildConnectionStatus(),
        ],
      ),
    );
  }

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
          style: const TextStyle(
            color: QuantixTheme.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return QuantixFloatingMenu(
      items: [
        QuantixMenuItem(
          icon: Icons.settings,
          label: 'Configuración',
          onTap: () => Navigator.of(context).pushNamed('/configuracion'),
        ),
        QuantixMenuItem(
          icon: Icons.swap_vert,
          label: 'Trading',
          onTap: () => Navigator.of(context).pushNamed('/trade'),
        ),
        QuantixMenuItem(
          icon: Icons.bar_chart,
          label: 'Indicadores',
          onTap: () => Navigator.of(context).pushNamed('/indicadores'),
        ),
        QuantixMenuItem(
          icon: Icons.history,
          label: 'Historial',
          onTap: () => Navigator.of(context).pushNamed('/historial'),
        ),
        QuantixMenuItem(
          icon: Icons.help_outline,
          label: 'Ayuda',
          onTap: () => Navigator.of(context).pushNamed('/ayuda'),
        ),
      ],
      onAIButtonPressed: () => Navigator.of(context).pushNamed('/ai'),
    );
  }
}
