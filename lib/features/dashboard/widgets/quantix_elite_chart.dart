import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../services/binance_service.dart';
// El import de Candle solo es necesario si usas Candle en este archivo
// import '../../../models/candle.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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
    // ...existing code...
  }

  Future<void> _fetchIAMessage() async {
    // Ejemplo profesional: integración con Groq API usando flutter_dotenv y http
    final groqApiKey = dotenv.env['GROQ_API_KEY'];
    if (groqApiKey == null || groqApiKey.isEmpty) {
      setState(() => _iaMessage = 'API Key de Groq no configurada.');
      return;
    }
    try {
      final url = Uri.parse('https://api.groq.com/v1/market/analyze');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $groqApiKey',
          'Content-Type': 'application/json',
        },
        body: '''{
          "symbol": "${widget.symbol}",
          "timeframe": "${widget.timeframe}"
        }''',
      );
      if (response.statusCode == 200) {
        // Suponiendo que la respuesta tiene un campo "message" con el análisis
        final message = response.body; // Puedes usar jsonDecode si la respuesta es JSON
        setState(() => _iaMessage = 'Groq IA: $message');
      } else {
        setState(() => _iaMessage = 'Error Groq: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() => _iaMessage = 'Error al consultar Groq: ' + e.toString());
    }
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
