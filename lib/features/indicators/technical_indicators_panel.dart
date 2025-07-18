import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 📊 Panel de Indicadores Técnicos Profesionales
/// Top 100 indicadores categorizados por función
class TechnicalIndicatorsPanel extends StatefulWidget {
  const TechnicalIndicatorsPanel({super.key});

  @override
  State<TechnicalIndicatorsPanel> createState() => _TechnicalIndicatorsPanelState();
}

class _TechnicalIndicatorsPanelState extends State<TechnicalIndicatorsPanel>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'trend';
  
  // Categorías de indicadores
  final Map<String, String> _categories = {
    'trend': 'Tendencia',
    'momentum': 'Momentum',
    'volume': 'Volumen',
    'volatility': 'Volatilidad',
    'support_resistance': 'Soporte/Resistencia',
    'oscillator': 'Osciladores',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: QuantixTheme.blueGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: QuantixTheme.primaryBlack,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Indicadores Técnicos Pro',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: QuantixTheme.primaryBlack.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TOP 100',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: QuantixTheme.primaryBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar de categorías
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = entry.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? QuantixTheme.indicatorColors[entry.key]
                              : QuantixTheme.cardBlack,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: QuantixTheme.indicatorColors[entry.key] ?? QuantixTheme.neutralGray,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: isSelected 
                                ? QuantixTheme.primaryBlack 
                                : QuantixTheme.lightGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Contenido de indicadores
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildIndicatorsGrid(),
          ),
        ],
      ),
    );
  }

  /// Grid de indicadores por categoría
  Widget _buildIndicatorsGrid() {
    final indicators = _getIndicatorsByCategory(_selectedCategory);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: indicators.length,
      itemBuilder: (context, index) {
        final indicator = indicators[index];
        return _buildIndicatorCard(indicator);
      },
    );
  }

  /// Card de indicador individual
  Widget _buildIndicatorCard(Map<String, dynamic> indicator) {
    final signal = indicator['signal'] as String;
    final Color signalColor = _getSignalColor(signal);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: QuantixTheme.cardBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signalColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del indicador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  indicator['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: signalColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Valor actual
          Text(
            indicator['value'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: QuantixTheme.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Señal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: signalColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              signal.toUpperCase(),
              style: const TextStyle(
                color: QuantixTheme.primaryBlack,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener indicadores por categoría
  List<Map<String, dynamic>> _getIndicatorsByCategory(String category) {
    switch (category) {
      case 'trend':
        return [
          {'name': 'SMA 20', 'value': '42,350', 'signal': 'buy'},
          {'name': 'EMA 50', 'value': '41,890', 'signal': 'strong_buy'},
          {'name': 'MACD', 'value': '156.8', 'signal': 'buy'},
          {'name': 'ADX', 'value': '68.4', 'signal': 'strong_buy'},
          {'name': 'Parabolic SAR', 'value': '40,245', 'signal': 'hold'},
          {'name': 'Ichimoku', 'value': 'Bullish', 'signal': 'buy'},
        ];
      case 'momentum':
        return [
          {'name': 'RSI', 'value': '67.5', 'signal': 'hold'},
          {'name': 'Stochastic', 'value': '78.2', 'signal': 'sell'},
          {'name': 'Williams %R', 'value': '-23.4', 'signal': 'buy'},
          {'name': 'ROC', 'value': '2.8%', 'signal': 'buy'},
          {'name': 'CCI', 'value': '145.6', 'signal': 'strong_buy'},
          {'name': 'MFI', 'value': '54.3', 'signal': 'hold'},
        ];
      case 'volume':
        return [
          {'name': 'Volume SMA', 'value': '2.4M', 'signal': 'strong_buy'},
          {'name': 'OBV', 'value': '156.8K', 'signal': 'buy'},
          {'name': 'VWAP', 'value': '42,156', 'signal': 'hold'},
          {'name': 'A/D Line', 'value': '89.4K', 'signal': 'buy'},
          {'name': 'Chaikin MF', 'value': '0.23', 'signal': 'buy'},
          {'name': 'VROC', 'value': '15.6%', 'signal': 'strong_buy'},
        ];
      case 'volatility':
        return [
          {'name': 'Bollinger B.', 'value': '0.78', 'signal': 'hold'},
          {'name': 'ATR', 'value': '1,245', 'signal': 'buy'},
          {'name': 'Keltner Ch.', 'value': 'Middle', 'signal': 'hold'},
          {'name': 'Donchian Ch.', 'value': 'Upper', 'signal': 'sell'},
          {'name': 'Volatility', 'value': '2.4%', 'signal': 'buy'},
          {'name': 'STARC Bands', 'value': 'Lower', 'signal': 'strong_buy'},
        ];
      case 'support_resistance':
        return [
          {'name': 'Pivot Point', 'value': '42,100', 'signal': 'hold'},
          {'name': 'R1', 'value': '43,200', 'signal': 'sell'},
          {'name': 'S1', 'value': '41,000', 'signal': 'buy'},
          {'name': 'Fibonacci', 'value': '61.8%', 'signal': 'hold'},
          {'name': 'Woodie\'s PP', 'value': '42,050', 'signal': 'hold'},
          {'name': 'Classic PP', 'value': '42,150', 'signal': 'hold'},
        ];
      case 'oscillator':
        return [
          {'name': 'Awesome Osc.', 'value': '89.4', 'signal': 'buy'},
          {'name': 'Bull Bear P.', 'value': 'Bullish', 'signal': 'strong_buy'},
          {'name': 'UO', 'value': '65.8', 'signal': 'hold'},
          {'name': 'Aroon', 'value': '78.5', 'signal': 'buy'},
          {'name': 'DeMarker', 'value': '0.68', 'signal': 'hold'},
          {'name': 'Fisher', 'value': '1.24', 'signal': 'buy'},
        ];
      default:
        return [];
    }
  }

  /// Obtener color según la señal
  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'strong_buy':
        return QuantixTheme.strongBuy;
      case 'buy':
        return QuantixTheme.buy;
      case 'hold':
        return QuantixTheme.hold;
      case 'sell':
        return QuantixTheme.sell;
      case 'strong_sell':
        return QuantixTheme.strongSell;
      default:
        return QuantixTheme.neutralGray;
    }
  }
}
