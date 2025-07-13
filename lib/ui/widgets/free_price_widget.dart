import 'package:flutter/material.dart';
import '../../services/free_crypto_service.dart';
import '../../features/subscription/subscription_screen.dart';

class FreePriceWidget extends StatefulWidget {
  final List<String> symbols;
  final bool showHeader;
  
  const FreePriceWidget({
    super.key,
    this.symbols = const ['BTC', 'ETH', 'BNB', 'ADA', 'XRP'],
    this.showHeader = true,
  });

  @override
  State<FreePriceWidget> createState() => _FreePriceWidgetState();
}

class _FreePriceWidgetState extends State<FreePriceWidget> {
  final FreeCryptoService _cryptoService = FreeCryptoService();
  Map<String, double> _prices = {};
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _loadPrices();
    // Actualizar cada 2 minutos para versión gratuita
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() {
    Future.delayed(const Duration(minutes: 2), () {
      if (mounted) {
        _loadPrices();
        _startPeriodicUpdate();
      }
    });
  }

  Future<void> _loadPrices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prices = await _cryptoService.getCurrentPrices(
        symbols: widget.symbols,
      );

      if (mounted) {
        setState(() {
          _prices = prices;
          _isLoading = false;
          _lastUpdate = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (widget.showHeader) _buildHeader(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            _buildErrorWidget()
          else
            _buildPriceList(),
          _buildUpgradePrompt(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Precios en Tiempo Real',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_lastUpdate != null)
            Text(
              'Actualizado: ${_formatTime(_lastUpdate!)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Error al obtener precios',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadPrices,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.symbols.length,
      itemBuilder: (context, index) {
        final symbol = widget.symbols[index];
        final price = _prices[symbol];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          title: Text(
            symbol,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_getCoinName(symbol)),
          trailing: price != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${_formatPrice(price)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'USD',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : const Text(
                  'N/A',
                  style: TextStyle(color: Colors.grey),
                ),
        );
      },
    );
  }

  Widget _buildUpgradePrompt() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.amber.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actualiza a Premium',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Precios en tiempo real, más cryptos y análisis avanzado',
                  style: TextStyle(
                    color: Colors.amber.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Actualizar',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return price.toStringAsFixed(0);
    } else if (price >= 1) {
      return price.toStringAsFixed(2);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(4);
    } else {
      return price.toStringAsFixed(8);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getCoinName(String symbol) {
    final names = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'BNB': 'Binance Coin',
      'ADA': 'Cardano',
      'XRP': 'Ripple',
      'SOL': 'Solana',
      'DOT': 'Polkadot',
      'DOGE': 'Dogecoin',
      'AVAX': 'Avalanche',
      'MATIC': 'Polygon',
      'LTC': 'Litecoin',
      'ATOM': 'Cosmos',
      'LINK': 'Chainlink',
      'UNI': 'Uniswap',
      'LUNA': 'Terra Luna',
    };
    return names[symbol] ?? symbol;
  }
}
