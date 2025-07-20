import 'package:flutter/material.dart';

class MACDIndicator extends StatelessWidget {
  final List<double> prices;
  final int fastPeriod;
  final int slowPeriod;
  final int signalPeriod;
  const MACDIndicator(
      {Key? key,
      required this.prices,
      this.fastPeriod = 12,
      this.slowPeriod = 26,
      this.signalPeriod = 9})
      : super(key: key);

  List<double> _ema(List<double> values, int period) {
    List<double> ema = [];
    double k = 2 / (period + 1);
    for (int i = 0; i < values.length; i++) {
      if (i == 0) {
        ema.add(values[i]);
      } else {
        ema.add(values[i] * k + ema[i - 1] * (1 - k));
      }
    }
    return ema;
  }

  @override
  Widget build(BuildContext context) {
    if (prices.length < slowPeriod + signalPeriod) {
      return Card(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('No hay suficientes datos para MACD',
              style: TextStyle(color: Colors.amber)),
        ),
      );
    }
    final emaFast = _ema(prices, fastPeriod);
    final emaSlow = _ema(prices, slowPeriod);
    final macdLine =
        List.generate(prices.length, (i) => emaFast[i] - emaSlow[i]);
    final signalLine = _ema(macdLine, signalPeriod);
    final macdValue = macdLine.last;
    final signalValue = signalLine.last;
    final hist = macdValue - signalValue;
    Color color = hist > 0
        ? Colors.greenAccent
        : hist < 0
            ? Colors.redAccent
            : Colors.amber;
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.multiline_chart, color: color),
                const SizedBox(width: 8),
                Text('MACD',
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('MACD: ${macdValue.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontSize: 16)),
            Text('Signal: ${signalValue.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.amber)),
            Text(
                hist > 0
                    ? 'Tendencia alcista'
                    : hist < 0
                        ? 'Tendencia bajista'
                        : 'Neutral',
                style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
