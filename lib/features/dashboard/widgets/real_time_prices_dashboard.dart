import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/binance_websocket_service.dart';
import '../../../ui/theme/app_colors.dart';

class RealTimePricesDashboard extends StatefulWidget {
  const RealTimePricesDashboard({super.key});

  @override
  State<RealTimePricesDashboard> createState() => _RealTimePricesDashboardState();
}

class _RealTimePricesDashboardState extends State<RealTimePricesDashboard> {
  // El WebSocket se gestiona globalmente por Provider

  @override
  Widget build(BuildContext context) {
    // Lista ampliada de monedas populares
    final allCoins = [
      'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'ADAUSDT',
      'XRPUSDT', 'DOGEUSDT', 'AVAXUSDT', 'DOTUSDT', 'LINKUSDT',
      'LTCUSDT', 'BCHUSDT', 'MATICUSDT', 'SHIBUSDT', 'UNIUSDT',
      'TRXUSDT', 'XLMUSDT', 'ATOMUSDT', 'FILUSDT', 'APEUSDT'
    ];

    return Container(
      color: AppColors.primaryDark,
      child: Consumer<BinanceWebSocketService>(
        builder: (context, wsService, _) {
          final prices = wsService.prices;
          final changes = wsService.priceChanges;
          final isConnected = wsService.isConnected;

          final tickers = allCoins.map((symbol) {
            return {
              'symbol': symbol,
              'price': prices[symbol],
              'change': changes[symbol],
            };
          }).where((t) => t['price'] != null).toList();

          if (!isConnected) {
            return const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary));
          }

          if (tickers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: AppColors.goldPrimary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No hay datos de precios disponibles.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica tu conexión o espera unos segundos.',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickers.length,
            itemBuilder: (context, index) {
              final ticker = tickers[index];
              final symbol = ticker['symbol'] as String;
              final price = ticker['price'] as double?;
              final change = ticker['change'] as double? ?? 0;
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
                    price != null ? 'Precio: ${price.toStringAsFixed(2)} USD' : 'Sin datos',
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
