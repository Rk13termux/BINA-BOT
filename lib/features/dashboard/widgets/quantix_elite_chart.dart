import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../services/binance_service.dart';
import '../../../models/candle.dart';
// ...existing code...

// ...existing code...

/// Widget modular: Gráfico animado de velas japonesas + indicadores avanzados + análisis IA
/// Widget modular: Gráfico animado de velas japonesas + indicadores avanzados + análisis IA
class QuantixEliteChart extends StatefulWidget {
  final String symbol;
  final String timeframe;
  final List<String> selectedIndicators;
  final Function(String) onIndicatorCategorySelected;
  final Function(String) onIndicatorSelected;

  const QuantixEliteChart({
    Key? key,
    required this.symbol,
    required this.timeframe,
    required this.selectedIndicators,
    required this.onIndicatorCategorySelected,
    required this.onIndicatorSelected,
  }) : super(key: key);

  @override
  State<QuantixEliteChart> createState() => _QuantixEliteChartState();
}

class _QuantixEliteChartState extends State<QuantixEliteChart> {
  List<CandleData> _candles = [];
  bool _loading = true;
  String _iaMessage = '';
  String _errorMessage = '';
  List<String> _indicatorCategories = [
    'Tendencia', 'Momentum', 'Volatilidad', 'Volumen', 'Osciladores', 'Custom', 'IA', 'Exóticos', 'Crypto', 'Machine Learning', 'Predicción', 'Long Monitor', 'Short Monitor', 'Arbitraje', 'On-Chain', 'Sentimiento', 'Order Flow', 'Microestructura', 'Estadísticos', 'Multi-Timeframe', 'Combinados', 'Personalizados', 'Más...'
  ];
  // ...existing code...
  // ...existing code...

  @override
  void initState() {
    super.initState();
    _fetchCandles();
    _fetchIndicators();
    _fetchIAMessage();
  }

  Future<void> _fetchCandles() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    try {
      final binance = BinanceService();
      final data = await binance.getCandlestickData(symbol: widget.symbol, interval: widget.timeframe);
      _candles = data.map((c) {
        // Si es CandleData, úsalo directamente
        if (c is CandleData) {
          return c;
        }
        // Si es Candle, conviértelo
        return CandleData(
          time: c.openTime.toIso8601String(),
          open: c.open,
          high: c.high,
          low: c.low,
          close: c.close,
        );
      }).toList().cast<CandleData>();
    } catch (e) {
      _errorMessage = 'Error al cargar datos de velas: ' + e.toString() + '. Verifica la conexión y el formato de datos.';
      _candles = [];
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _fetchIndicators() async {
    // Simulación: más de 100 indicadores por categoría
    final indicatorsByCategory = {
      'Tendencia': List.generate(10, (i) => 'SMA${i+1}'),
      'Momentum': List.generate(10, (i) => 'RSI${i+1}'),
      'Volatilidad': List.generate(10, (i) => 'ATR${i+1}'),
      'Volumen': List.generate(10, (i) => 'OBV${i+1}'),
      'Osciladores': List.generate(10, (i) => 'Stoch${i+1}'),
      'Custom': List.generate(10, (i) => 'CustomInd${i+1}'),
      'IA': List.generate(10, (i) => 'AIInd${i+1}'),
      'Exóticos': List.generate(10, (i) => 'Exotic${i+1}'),
      'Crypto': List.generate(10, (i) => 'CryptoInd${i+1}'),
      'Machine Learning': List.generate(10, (i) => 'MLInd${i+1}'),
      'Predicción': List.generate(10, (i) => 'Pred${i+1}'),
      'Long Monitor': List.generate(10, (i) => 'LongMon${i+1}'),
      'Short Monitor': List.generate(10, (i) => 'ShortMon${i+1}'),
      'Arbitraje': List.generate(10, (i) => 'Arb${i+1}'),
      'On-Chain': List.generate(10, (i) => 'OnChain${i+1}'),
      'Sentimiento': List.generate(10, (i) => 'Sent${i+1}'),
      'Order Flow': List.generate(10, (i) => 'OrderFlow${i+1}'),
      'Microestructura': List.generate(10, (i) => 'Micro${i+1}'),
      'Estadísticos': List.generate(10, (i) => 'Stat${i+1}'),
      'Multi-Timeframe': List.generate(10, (i) => 'MTF${i+1}'),
      'Combinados': List.generate(10, (i) => 'Combo${i+1}'),
      'Personalizados': List.generate(10, (i) => 'Personal${i+1}'),
      'Más...': List.generate(10, (i) => 'Extra${i+1}'),
    };
  }

  Future<void> _fetchIAMessage() async {
    // Simulación: análisis IA
    // Fallback: Mensaje simulado de IA
    setState(() => _iaMessage = 'Análisis IA no disponible.');
  }

  @override
  Widget build(BuildContext context) {
    // ...existing code...
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: _loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 8)],
                    ),
                    child: Text(_errorMessage, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                )
              : Column(
                  children: [
                    // Mensaje IA y predicción
                    if (_iaMessage.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Color(0xFFFFD700).withOpacity(0.2), blurRadius: 8)],
                        ),
                        child: Text(_iaMessage, style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                      ),
                    // Gráfico de velas japonesas animado y original
                    SizedBox(
                      height: 320,
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        backgroundColor: Color(0xFF1A1A1A),
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(),
                        series: <CandleSeries<CandleData, String>>[
                          CandleSeries<CandleData, String>(
                            dataSource: _candles,
                            xValueMapper: (CandleData c, _) => c.time,
                            lowValueMapper: (CandleData c, _) => c.low,
                            highValueMapper: (CandleData c, _) => c.high,
                            openValueMapper: (CandleData c, _) => c.open,
                            closeValueMapper: (CandleData c, _) => c.close,
                            enableTooltip: true,
                            animationDuration: 1200,
                            bearColor: Color(0xFFFF4444),
                            bullColor: Color(0xFF00FF88),
                          ),
                        ],
                        annotations: <CartesianChartAnnotation>[
                          if (_candles.isNotEmpty)
                            CartesianChartAnnotation(
                              widget: Icon(Icons.trending_up, color: Color(0xFFFFD700), size: 32),
                              coordinateUnit: CoordinateUnit.point,
                              x: _candles.last.time,
                              y: _candles.last.close,
                            ),
                        ],
                      ),
                    ),
                    // Selector de indicadores por categoría
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Wrap(
                        spacing: 8,
                        children: _indicatorCategories.map((cat) => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1A1A1A),
                            foregroundColor: Color(0xFFFFD700),
                            shape: StadiumBorder(),
                          ),
                          onPressed: () => widget.onIndicatorCategorySelected(cat),
                          child: Text(cat),
                        )).toList(),
                      ),
                    ),
                    // Lista de indicadores de la categoría seleccionada
                    if (widget.selectedIndicators.isNotEmpty)
                      Container(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.selectedIndicators.map((ind) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Chip(
                              label: Text(ind),
                              backgroundColor: Color(0xFFFFD700),
                              deleteIcon: Icon(Icons.close, color: Colors.black),
                              onDeleted: () => widget.onIndicatorSelected(ind),
                            ),
                          )).toList(),
                        ),
                      ),
                    // Monitor profesional estilo long/short
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Color(0xFFFFD700).withOpacity(0.1), blurRadius: 6)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text('LONG', style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold)),
                              Text('Monitor', style: TextStyle(color: Colors.white)),
                              Text('Señales: 12', style: TextStyle(color: Color(0xFF00FF88))),
                            ],
                          ),
                          Column(
                            children: [
                              Text('SHORT', style: TextStyle(color: Color(0xFFFF4444), fontWeight: FontWeight.bold)),
                              Text('Monitor', style: TextStyle(color: Colors.white)),
                              Text('Señales: 8', style: TextStyle(color: Color(0xFFFF4444))),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Tendencia', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                              Text('Actual', style: TextStyle(color: Colors.white)),
                              Text('Bullish', style: TextStyle(color: Color(0xFF00FF88))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Modelo de datos para velas japonesas
class CandleData {
  final String time;
  final double open, high, low, close;
  CandleData({required this.time, required this.open, required this.high, required this.low, required this.close});
}
