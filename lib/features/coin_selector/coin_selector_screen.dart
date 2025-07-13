import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../services/binance_service.dart';
import '../../utils/logger.dart';

/// Pantalla de selección de criptomonedas
class CoinSelectorScreen extends StatefulWidget {
  final Function(String) onCoinSelected;

  const CoinSelectorScreen({
    super.key,
    required this.onCoinSelected,
  });

  @override
  State<CoinSelectorScreen> createState() => _CoinSelectorScreenState();
}

class _CoinSelectorScreenState extends State<CoinSelectorScreen> {
  final AppLogger _logger = AppLogger();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCoins = [];
  List<Map<String, dynamic>> _filteredCoins = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTradingPairs();
  }

  Future<void> _loadTradingPairs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final binanceService = Provider.of<BinanceService>(context, listen: false);
      final symbols = await binanceService.getTradingPairs();
      
      _allCoins = symbols.map((symbol) {
        return {
          'symbol': symbol['symbol'],
          'baseAsset': symbol['baseAsset'],
          'quoteAsset': symbol['quoteAsset'],
          'status': symbol['status'],
          'price': '0.00', // Se actualizará con datos reales
          'change24h': '0.00%',
          'volume': '0.00',
        };
      }).toList();

      _filteredCoins = List.from(_allCoins);
      
      // Cargar precios para los primeros 50 símbolos
      _loadPrices();
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      _logger.error('Error loading trading pairs: $e');
      setState(() {
        _error = 'Error al cargar las criptomonedas: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrices() async {
    try {
      final binanceService = Provider.of<BinanceService>(context, listen: false);
      final prices = await binanceService.get24hrTicker();
      
      setState(() {
        for (int i = 0; i < _allCoins.length; i++) {
          final coin = _allCoins[i];
          final priceData = prices.firstWhere(
            (p) => p['symbol'] == coin['symbol'],
            orElse: () => {},
          );
          
          if (priceData.isNotEmpty) {
            _allCoins[i] = {
              ..._allCoins[i],
              'price': double.parse(priceData['lastPrice'] ?? '0').toStringAsFixed(8),
              'change24h': '${double.parse(priceData['priceChangePercent'] ?? '0').toStringAsFixed(2)}%',
              'volume': double.parse(priceData['volume'] ?? '0').toStringAsFixed(2),
            };
          }
        }
        _filterCoins(_searchController.text);
      });
    } catch (e) {
      _logger.error('Error loading prices: $e');
    }
  }

  void _filterCoins(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCoins = List.from(_allCoins);
      } else {
        _filteredCoins = _allCoins.where((coin) {
          final symbol = coin['symbol'].toString().toLowerCase();
          final baseAsset = coin['baseAsset'].toString().toLowerCase();
          final searchQuery = query.toLowerCase();
          
          return symbol.contains(searchQuery) || 
                 baseAsset.contains(searchQuery);
        }).toList();
      }
      
      // Ordenar por volumen (descendente)
      _filteredCoins.sort((a, b) {
        final volumeA = double.tryParse(a['volume'].toString()) ?? 0;
        final volumeB = double.tryParse(b['volume'].toString()) ?? 0;
        return volumeB.compareTo(volumeA);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      title: Text(
        'Seleccionar Criptomoneda',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: AppColors.goldPrimary),
          onPressed: _loadTradingPairs,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Column(
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(child: _buildCoinList()),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.goldPrimary),
          const SizedBox(height: 16),
          Text(
            'Cargando criptomonedas...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.bearish,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTradingPairs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar criptomoneda...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.goldPrimary),
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.goldPrimary),
          ),
        ),
        onChanged: _filterCoins,
      ),
    );
  }

  Widget _buildFilterChips() {
    final popularCoins = ['BTC', 'ETH', 'BNB', 'ADA', 'SOL', 'DOGE'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularCoins.length,
        itemBuilder: (context, index) {
          final coin = popularCoins[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(coin),
              labelStyle: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              backgroundColor: AppColors.surfaceDark,
              selectedColor: AppColors.goldPrimary.withOpacity(0.2),
              side: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
              onSelected: (selected) {
                if (selected) {
                  _searchController.text = coin;
                  _filterCoins(coin);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoinList() {
    if (_filteredCoins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron criptomonedas',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCoins.length,
      itemBuilder: (context, index) {
        final coin = _filteredCoins[index];
        return _buildCoinItem(coin);
      },
    );
  }

  Widget _buildCoinItem(Map<String, dynamic> coin) {
    final changePercent = coin['change24h'].toString();
    final isPositive = changePercent.startsWith('+') || 
                      (!changePercent.startsWith('-') && double.tryParse(changePercent.replaceAll('%', '')) != null && double.parse(changePercent.replaceAll('%', '')) > 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCoinSelected(coin['symbol']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                // Ícono de la moneda
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      coin['baseAsset'].toString().substring(0, 
                        coin['baseAsset'].toString().length > 3 ? 3 : coin['baseAsset'].toString().length
                      ),
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Información de la moneda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coin['baseAsset'],
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        coin['symbol'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Precio y cambio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${coin['price']}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      changePercent,
                      style: TextStyle(
                        color: isPositive ? AppColors.bullish : AppColors.bearish,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
