import 'package:flutter/material.dart';

class EMAIndicator extends StatelessWidget {
  final List<double> prices;
  final int period;
  const EMAIndicator({Key? key, required this.prices, this.period = 20})
      : super(key: key);

  double _calculateEMA() {
    if (prices.length < period) return 0;
    double k = 2 / (period + 1);
    double ema = prices[0];
    for (int i = 1; i < prices.length; i++) {
      ema = prices[i] * k + ema * (1 - k);
    }
    return ema;
  }

  @override
  Widget build(BuildContext context) {
    final ema = _calculateEMA();
    Color color = Colors.blueAccent;
    return Card(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: color),
                const SizedBox(width: 8),
                Text('EMA ($period)',
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Valor: ${ema.toStringAsFixed(2)}',
                style: TextStyle(color: color, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
