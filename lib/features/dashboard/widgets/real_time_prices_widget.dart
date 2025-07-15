import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../services/binance_websocket_service.dart';
import '../../../utils/logger.dart';

/// Widget para mostrar precios en tiempo real con actualizaciones automáticas
class RealTimePricesWidget extends StatefulWidget {
  final String selectedSymbol;
  final Function(String symbol, double price) onPriceUpdate;

  const RealTimePricesWidget({
    super.key,
    required this.selectedSymbol,
    required this.onPriceUpdate,
  });

  @override
  State<RealTimePricesWidget> createState() => _RealTimePricesWidgetState();
}

class _RealTimePricesWidgetState extends State<RealTimePricesWidget>
    with TickerProviderStateMixin {
  static final AppLogger _logger = AppLogger();
  
  late AnimationController _priceFlashController;
  late AnimationController _pulseController;
  
  String? _lastSymbol;
  double? _lastPrice;
  bool _isPriceIncreasing = true;

  // Lista de símbolos para mostrar en tiempo real
  final List<String> _watchlistSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'BNBUSDT',
    'ADAUSDT',
    'XRPUSDT',
    'SOLUSDT',
    'DOGEUSDT',
    'AVAXUSDT',
  ];

  @override
  void initState() {
    super.initState();
    
    _priceFlashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _initializeWebSocketSubscriptions();
    _startPulseAnimation();
  }

  void _initializeWebSocketSubscriptions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final websocketService = context.read<BinanceWebSocketService>();
      
      // Suscribirse a los símbolos de la watchlist
      for (final symbol in _watchlistSymbols) {
        websocketService.subscribeToTicker(symbol);
      }
      
      _logger.info('Subscribed to ${_watchlistSymbols.length} symbols for real-time prices');
    });
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _onPriceChanged(String symbol, double newPrice) {
    if (_lastSymbol == symbol && _lastPrice != null) {
      _isPriceIncreasing = newPrice > _lastPrice!;
      _priceFlashController.forward().then((_) {
        _priceFlashController.reverse();
      });
    }
    
    _lastSymbol = symbol;
    _lastPrice = newPrice;
    
    widget.onPriceUpdate(symbol, newPrice);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con indicador de tiempo real
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.5 + (_pulseController.value * 0.5)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              const Text(
                'Precios en Tiempo Real',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const Spacer(),
              
              Consumer<BinanceWebSocketService>(
                builder: (context, websocketService, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: websocketService.isConnected
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      websocketService.isConnected ? 'CONECTADO' : 'DESCONECTADO',
                      style: TextStyle(
                        color: websocketService.isConnected ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Precio principal (símbolo seleccionado)
          _buildMainPriceDisplay(),
          
          const SizedBox(height: 20),
          
          // Watchlist de precios
          _buildPriceWatchlist(),
        ],
      ),
    );
  }

  Widget _buildMainPriceDisplay() {
    return Consumer<BinanceWebSocketService>(
      builder: (context, websocketService, _) {
        final price = websocketService.getPrice(widget.selectedSymbol);
        final priceChange = websocketService.getPriceChange(widget.selectedSymbol);
        
        if (price != null) {
          _onPriceChanged(widget.selectedSymbol, price);
        }
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedSymbol,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    AnimatedBuilder(
                      animation: _priceFlashController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priceFlashController.value > 0
                                ? (_isPriceIncreasing ? Colors.green : Colors.red)
                                    .withOpacity(_priceFlashController.value * 0.3)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            price != null ? '\$${price.toStringAsFixed(2)}' : '--',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              if (priceChange != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: priceChange >= 0
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priceChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: priceChange >= 0 ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${priceChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: priceChange >= 0 ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceWatchlist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watchlist',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Consumer<BinanceWebSocketService>(
          builder: (context, websocketService, _) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _watchlistSymbols.length,
              itemBuilder: (context, index) {
                final symbol = _watchlistSymbols[index];
                final price = websocketService.getPrice(symbol);
                final priceChange = websocketService.getPriceChange(symbol);
                
                return _buildWatchlistItem(symbol, price, priceChange);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWatchlistItem(String symbol, double? price, double? priceChange) {
    final isSelected = symbol == widget.selectedSymbol;
    
    return GestureDetector(
      onTap: () {
        // Cambiar el símbolo seleccionado
        // widget.onSymbolChanged(symbol); // Necesitarías agregar este callback
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.green.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    symbol.replaceAll('USDT', ''),
                    style: TextStyle(
                      color: isSelected ? Colors.green : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (priceChange != null)
                  Icon(
                    priceChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: priceChange >= 0 ? Colors.green : Colors.red,
                    size: 12,
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    price != null ? '\$${price.toStringAsFixed(4)}' : '--',
                    style: TextStyle(
                      color: isSelected ? Colors.green : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (priceChange != null)
                  Text(
                    '${priceChange.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: priceChange >= 0 ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _priceFlashController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
