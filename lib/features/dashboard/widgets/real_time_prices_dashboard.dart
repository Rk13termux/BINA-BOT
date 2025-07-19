import 'package:flutter/material.dart';
import '../../../core/websocket_manager.dart';
import '../../../ui/theme/app_colors.dart';

class RealTimePricesDashboard extends StatefulWidget {
  const RealTimePricesDashboard({super.key});

  @override
  State<RealTimePricesDashboard> createState() => _RealTimePricesDashboardState();
}

class _RealTimePricesDashboardState extends State<RealTimePricesDashboard> {
  final WebSocketManager _wsManager = WebSocketManager();
  late Stream<List<Map<String, dynamic>>> _tickerStream;

  @override
  void initState() {
    super.initState();
    _tickerStream = _wsManager.subscribeAllTickers();
  }

  @override
  void dispose() {
    _wsManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _tickerStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar precios',
                style: TextStyle(color: AppColors.bearish),
              ),
            );
          }
          final tickers = snapshot.data ?? [];
          final mainCoins = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'ADAUSDT'];
          final mainTickers = tickers.where((t) => mainCoins.contains(t['s'])).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mainTickers.length,
            itemBuilder: (context, index) {
              final ticker = mainTickers[index];
              final symbol = ticker['s'];
              final price = ticker['c'];
              final change = double.tryParse(ticker['P'] ?? '0') ?? 0;
              final isBullish = change >= 0;

              return Card(
                color: AppColors.surfaceDark,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.currency_bitcoin, color: AppColors.goldPrimary, size: 32),
                  title: Text(
                    symbol,
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    'Precio: $price USD',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  ),
                  trailing: Text(
                    '${change.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isBullish ? AppColors.bullish : AppColors.bearish,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
