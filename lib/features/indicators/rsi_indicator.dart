import 'package:flutter/material.dart';

class RSIIndicator extends StatelessWidget {
  final List<double> prices;
  final int period;
  const RSIIndicator({Key? key, required this.prices, this.period = 14})
      : super(key: key);

  double _calculateRSI() {
    if (prices.length < period + 1) return 0;
    double gain = 0, loss = 0;
    for (int i = 1; i <= period; i++) {
      final diff = prices[prices.length - i] - prices[prices.length - i - 1];
      if (diff >= 0) {
        gain += diff;
      } else {
        loss -= diff;
      }
    }
    if (gain + loss == 0) return 50;
    final rs = gain / (loss == 0 ? 1 : loss);
    return 100 - (100 / (1 + rs));
  }

  @override
  Widget build(BuildContext context) {
    final rsi = _calculateRSI();
    Color color = rsi > 70
        ? Colors.redAccent
        : rsi < 30
            ? Colors.greenAccent
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
                Icon(Icons.show_chart, color: color),
                const SizedBox(width: 8),
                Text('RSI ($period)',
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Valor: ${rsi.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontSize: 16)),
            Text(
                rsi > 70
                    ? 'Sobrecompra'
                    : rsi < 30
                        ? 'Sobreventa'
                        : 'Neutral',
                style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
