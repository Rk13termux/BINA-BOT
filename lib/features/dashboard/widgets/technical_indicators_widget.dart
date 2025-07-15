import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../services/data_stream_service.dart';
import '../../../utils/logger.dart';

/// Widget para configurar y mostrar indicadores técnicos profesionales
class TechnicalIndicatorsWidget extends StatefulWidget {
  final String selectedSymbol;
  final String selectedTimeframe;
  final List<String> selectedIndicators;
  final Function(String indicator, bool enabled) onIndicatorToggle;

  const TechnicalIndicatorsWidget({
    super.key,
    required this.selectedSymbol,
    required this.selectedTimeframe,
    required this.selectedIndicators,
    required this.onIndicatorToggle,
  });

  @override
  State<TechnicalIndicatorsWidget> createState() => _TechnicalIndicatorsWidgetState();
}

class _TechnicalIndicatorsWidgetState extends State<TechnicalIndicatorsWidget>
    with TickerProviderStateMixin {
  static final AppLogger _logger = AppLogger();
  
  late TabController _tabController;
  
  // Los 100 indicadores técnicos más utilizados organizados por categorías
  static const Map<String, List<Map<String, dynamic>>> _indicatorCategories = {
    'Tendencia': [
      {'name': 'SMA_20', 'label': 'SMA 20', 'description': 'Media Móvil Simple 20 períodos'},
      {'name': 'SMA_50', 'label': 'SMA 50', 'description': 'Media Móvil Simple 50 períodos'},
      {'name': 'SMA_200', 'label': 'SMA 200', 'description': 'Media Móvil Simple 200 períodos'},
      {'name': 'EMA_12', 'label': 'EMA 12', 'description': 'Media Móvil Exponencial 12 períodos'},
      {'name': 'EMA_26', 'label': 'EMA 26', 'description': 'Media Móvil Exponencial 26 períodos'},
      {'name': 'EMA_50', 'label': 'EMA 50', 'description': 'Media Móvil Exponencial 50 períodos'},
      {'name': 'MACD', 'label': 'MACD', 'description': 'Moving Average Convergence Divergence'},
      {'name': 'MACD_SIGNAL', 'label': 'MACD Signal', 'description': 'Línea de señal MACD'},
      {'name': 'MACD_HISTOGRAM', 'label': 'MACD Histogram', 'description': 'Histograma MACD'},
      {'name': 'ADX', 'label': 'ADX', 'description': 'Average Directional Index'},
      {'name': 'DI_PLUS', 'label': '+DI', 'description': 'Directional Indicator Plus'},
      {'name': 'DI_MINUS', 'label': '-DI', 'description': 'Directional Indicator Minus'},
      {'name': 'PARABOLIC_SAR', 'label': 'Parabolic SAR', 'description': 'Stop and Reverse'},
      {'name': 'AROON_UP', 'label': 'Aroon Up', 'description': 'Indicador Aroon Alcista'},
      {'name': 'AROON_DOWN', 'label': 'Aroon Down', 'description': 'Indicador Aroon Bajista'},
    ],
    'Momentum': [
      {'name': 'RSI', 'label': 'RSI', 'description': 'Relative Strength Index'},
      {'name': 'STOCH_K', 'label': 'Stoch %K', 'description': 'Stochastic %K'},
      {'name': 'STOCH_D', 'label': 'Stoch %D', 'description': 'Stochastic %D'},
      {'name': 'STOCH_RSI', 'label': 'Stoch RSI', 'description': 'Stochastic RSI'},
      {'name': 'CCI', 'label': 'CCI', 'description': 'Commodity Channel Index'},
      {'name': 'WILLIAMS_R', 'label': 'Williams %R', 'description': 'Williams Percent Range'},
      {'name': 'ROC', 'label': 'ROC', 'description': 'Rate of Change'},
      {'name': 'MOMENTUM', 'label': 'Momentum', 'description': 'Momentum Oscillator'},
      {'name': 'ULTIMATE_OSC', 'label': 'Ultimate Oscillator', 'description': 'Ultimate Oscillator'},
      {'name': 'TSI', 'label': 'TSI', 'description': 'True Strength Index'},
      {'name': 'CMO', 'label': 'CMO', 'description': 'Chande Momentum Oscillator'},
      {'name': 'DEMA', 'label': 'DEMA', 'description': 'Double Exponential Moving Average'},
      {'name': 'TEMA', 'label': 'TEMA', 'description': 'Triple Exponential Moving Average'},
      {'name': 'TRIX', 'label': 'TRIX', 'description': 'Triple Smooth EMA Oscillator'},
      {'name': 'APO', 'label': 'APO', 'description': 'Absolute Price Oscillator'},
    ],
    'Volatilidad': [
      {'name': 'BOLLINGER_UPPER', 'label': 'Bollinger Upper', 'description': 'Banda Superior Bollinger'},
      {'name': 'BOLLINGER_MIDDLE', 'label': 'Bollinger Middle', 'description': 'Banda Media Bollinger'},
      {'name': 'BOLLINGER_LOWER', 'label': 'Bollinger Lower', 'description': 'Banda Inferior Bollinger'},
      {'name': 'ATR', 'label': 'ATR', 'description': 'Average True Range'},
      {'name': 'KELTNER_UPPER', 'label': 'Keltner Upper', 'description': 'Canal Keltner Superior'},
      {'name': 'KELTNER_MIDDLE', 'label': 'Keltner Middle', 'description': 'Canal Keltner Medio'},
      {'name': 'KELTNER_LOWER', 'label': 'Keltner Lower', 'description': 'Canal Keltner Inferior'},
      {'name': 'DONCHIAN_UPPER', 'label': 'Donchian Upper', 'description': 'Canal Donchian Superior'},
      {'name': 'DONCHIAN_MIDDLE', 'label': 'Donchian Middle', 'description': 'Canal Donchian Medio'},
      {'name': 'DONCHIAN_LOWER', 'label': 'Donchian Lower', 'description': 'Canal Donchian Inferior'},
      {'name': 'STDDEV', 'label': 'Std Deviation', 'description': 'Desviación Estándar'},
      {'name': 'VAR', 'label': 'Variance', 'description': 'Varianza'},
      {'name': 'NATR', 'label': 'NATR', 'description': 'Normalized ATR'},
      {'name': 'HV', 'label': 'Historical Volatility', 'description': 'Volatilidad Histórica'},
      {'name': 'VWAP', 'label': 'VWAP', 'description': 'Volume Weighted Average Price'},
    ],
    'Volumen': [
      {'name': 'OBV', 'label': 'OBV', 'description': 'On Balance Volume'},
      {'name': 'AD', 'label': 'A/D Line', 'description': 'Accumulation/Distribution Line'},
      {'name': 'CHAIKIN_OSC', 'label': 'Chaikin Oscillator', 'description': 'Oscilador Chaikin'},
      {'name': 'MFI', 'label': 'MFI', 'description': 'Money Flow Index'},
      {'name': 'PVT', 'label': 'PVT', 'description': 'Price Volume Trend'},
      {'name': 'VOLUME_SMA', 'label': 'Volume SMA', 'description': 'Media Móvil de Volumen'},
      {'name': 'VOLUME_EMA', 'label': 'Volume EMA', 'description': 'EMA de Volumen'},
      {'name': 'KLINGER_OSC', 'label': 'Klinger Oscillator', 'description': 'Oscilador Klinger'},
      {'name': 'EASE_OF_MOVEMENT', 'label': 'Ease of Movement', 'description': 'Facilidad de Movimiento'},
      {'name': 'FORCE_INDEX', 'label': 'Force Index', 'description': 'Índice de Fuerza'},
      {'name': 'NEGATIVE_VI', 'label': 'Negative VI', 'description': 'Vortex Indicator Negativo'},
      {'name': 'POSITIVE_VI', 'label': 'Positive VI', 'description': 'Vortex Indicator Positivo'},
      {'name': 'TWIGGS_MF', 'label': 'Twiggs Money Flow', 'description': 'Flujo de Dinero Twiggs'},
      {'name': 'ACCUMULATION', 'label': 'Accumulation', 'description': 'Indicador de Acumulación'},
      {'name': 'DISTRIBUTION', 'label': 'Distribution', 'description': 'Indicador de Distribución'},
    ],
    'Soporte/Resistencia': [
      {'name': 'PIVOT_POINT', 'label': 'Pivot Point', 'description': 'Punto Pivote'},
      {'name': 'SUPPORT_1', 'label': 'Support 1', 'description': 'Soporte 1'},
      {'name': 'SUPPORT_2', 'label': 'Support 2', 'description': 'Soporte 2'},
      {'name': 'SUPPORT_3', 'label': 'Support 3', 'description': 'Soporte 3'},
      {'name': 'RESISTANCE_1', 'label': 'Resistance 1', 'description': 'Resistencia 1'},
      {'name': 'RESISTANCE_2', 'label': 'Resistance 2', 'description': 'Resistencia 2'},
      {'name': 'RESISTANCE_3', 'label': 'Resistance 3', 'description': 'Resistencia 3'},
      {'name': 'FIBONACCI_236', 'label': 'Fibonacci 23.6%', 'description': 'Retroceso Fibonacci 23.6%'},
      {'name': 'FIBONACCI_382', 'label': 'Fibonacci 38.2%', 'description': 'Retroceso Fibonacci 38.2%'},
      {'name': 'FIBONACCI_500', 'label': 'Fibonacci 50%', 'description': 'Retroceso Fibonacci 50%'},
      {'name': 'FIBONACCI_618', 'label': 'Fibonacci 61.8%', 'description': 'Retroceso Fibonacci 61.8%'},
      {'name': 'FIBONACCI_786', 'label': 'Fibonacci 78.6%', 'description': 'Retroceso Fibonacci 78.6%'},
      {'name': 'CAMARILLA_R1', 'label': 'Camarilla R1', 'description': 'Resistencia Camarilla 1'},
      {'name': 'CAMARILLA_S1', 'label': 'Camarilla S1', 'description': 'Soporte Camarilla 1'},
      {'name': 'WOODIE_PIVOT', 'label': 'Woodie Pivot', 'description': 'Punto Pivote Woodie'},
    ],
    'Ichimoku': [
      {'name': 'ICHIMOKU_TENKAN', 'label': 'Tenkan-sen', 'description': 'Línea de Conversión'},
      {'name': 'ICHIMOKU_KIJUN', 'label': 'Kijun-sen', 'description': 'Línea Base'},
      {'name': 'ICHIMOKU_SENKOU_A', 'label': 'Senkou Span A', 'description': 'Línea Adelantada A'},
      {'name': 'ICHIMOKU_SENKOU_B', 'label': 'Senkou Span B', 'description': 'Línea Adelantada B'},
      {'name': 'ICHIMOKU_CHIKOU', 'label': 'Chikou Span', 'description': 'Línea Retrasada'},
      {'name': 'KUMO_CLOUD', 'label': 'Kumo Cloud', 'description': 'Nube Ichimoku'},
      {'name': 'TENKAN_KIJUN_CROSS', 'label': 'TK Cross', 'description': 'Cruce Tenkan-Kijun'},
      {'name': 'PRICE_CLOUD_POS', 'label': 'Price vs Cloud', 'description': 'Posición Precio vs Nube'},
      {'name': 'CLOUD_COLOR', 'label': 'Cloud Color', 'description': 'Color de la Nube'},
      {'name': 'CHIKOU_CONFIRMATION', 'label': 'Chikou Confirm', 'description': 'Confirmación Chikou'},
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _indicatorCategories.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.analytics,
                color: Colors.purple,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Indicadores Técnicos',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.selectedIndicators.length} ACTIVOS',
                  style: const TextStyle(
                    color: Colors.purple,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información del símbolo y timeframe
          _buildSymbolInfo(),
          
          const SizedBox(height: 16),
          
          // Tabs de categorías
          TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            tabs: _indicatorCategories.keys.map((category) {
              return Tab(text: category);
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Contenido de las tabs
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: _indicatorCategories.entries.map((entry) {
                return _buildIndicatorCategory(entry.key, entry.value);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Indicadores activos
          _buildActiveIndicators(),
        ],
      ),
    );
  }

  Widget _buildSymbolInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.show_chart,
            color: Colors.purple,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.selectedSymbol} - ${widget.selectedTimeframe}',
            style: const TextStyle(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Consumer<DataStreamService>(
            builder: (context, dataService, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dataService.isRunning
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dataService.isRunning ? 'LIVE' : 'OFFLINE',
                  style: TextStyle(
                    color: dataService.isRunning ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCategory(String category, List<Map<String, dynamic>> indicators) {
    return ListView.separated(
      itemCount: indicators.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final indicator = indicators[index];
        final isSelected = widget.selectedIndicators.contains(indicator['name']);
        
        return _buildIndicatorItem(
          indicator['name'],
          indicator['label'],
          indicator['description'],
          isSelected,
        );
      },
    );
  }

  Widget _buildIndicatorItem(String name, String label, String description, bool isSelected) {
    return GestureDetector(
      onTap: () {
        widget.onIndicatorToggle(name, !isSelected);
        _logger.info('Toggled indicator: $name (${isSelected ? 'disabled' : 'enabled'})');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.purple.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? Colors.purple : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
            
            const SizedBox(width: 12),
            
            // Información del indicador
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.purple : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Valor actual (si está disponible)
            Consumer<DataStreamService>(
              builder: (context, dataService, _) {
                final value = dataService.technicalIndicators[name];
                if (value != null && isSelected) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      value.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.purple,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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

  Widget _buildActiveIndicators() {
    if (widget.selectedIndicators.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Selecciona indicadores para ver sus valores en tiempo real',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Indicadores Activos',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                for (final indicator in widget.selectedIndicators.toList()) {
                  widget.onIndicatorToggle(indicator, false);
                }
              },
              child: const Text(
                'Limpiar Todo',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Consumer<DataStreamService>(
          builder: (context, dataService, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedIndicators.map((indicator) {
                final value = dataService.technicalIndicators[indicator];
                final label = _findIndicatorLabel(indicator);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => widget.onIndicatorToggle(indicator, false),
                        child: const Icon(
                          Icons.close,
                          color: Colors.purple,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _findIndicatorLabel(String indicatorName) {
    for (final category in _indicatorCategories.values) {
      for (final indicator in category) {
        if (indicator['name'] == indicatorName) {
          return indicator['label'];
        }
      }
    }
    return indicatorName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
