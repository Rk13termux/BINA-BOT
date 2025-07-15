import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../services/binance_service.dart';
import '../../../utils/logger.dart';

/// Widget selector de criptomonedas y timeframes con búsqueda avanzada
class CryptoSelectorWidget extends StatefulWidget {
  final String selectedSymbol;
  final String selectedTimeframe;
  final Function(String) onSymbolChanged;
  final Function(String) onTimeframeChanged;

  const CryptoSelectorWidget({
    super.key,
    required this.selectedSymbol,
    required this.selectedTimeframe,
    required this.onSymbolChanged,
    required this.onTimeframeChanged,
  });

  @override
  State<CryptoSelectorWidget> createState() => _CryptoSelectorWidgetState();
}

class _CryptoSelectorWidgetState extends State<CryptoSelectorWidget> {
  static final AppLogger _logger = AppLogger();
  
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allSymbols = [];
  List<Map<String, dynamic>> _filteredSymbols = [];
  bool _isLoading = false;
  bool _showDropdown = false;

  // Lista completa de timeframes disponibles
  static const List<Map<String, String>> _timeframes = [
    {'value': '1m', 'label': '1 Minuto'},
    {'value': '3m', 'label': '3 Minutos'},
    {'value': '5m', 'label': '5 Minutos'},
    {'value': '15m', 'label': '15 Minutos'},
    {'value': '30m', 'label': '30 Minutos'},
    {'value': '1h', 'label': '1 Hora'},
    {'value': '2h', 'label': '2 Horas'},
    {'value': '4h', 'label': '4 Horas'},
    {'value': '6h', 'label': '6 Horas'},
    {'value': '8h', 'label': '8 Horas'},
    {'value': '12h', 'label': '12 Horas'},
    {'value': '1d', 'label': '1 Día'},
    {'value': '3d', 'label': '3 Días'},
    {'value': '1w', 'label': '1 Semana'},
    {'value': '1M', 'label': '1 Mes'},
  ];

  // Criptomonedas más populares para acceso rápido
  static const List<Map<String, String>> _popularSymbols = [
    {'symbol': 'BTCUSDT', 'name': 'Bitcoin'},
    {'symbol': 'ETHUSDT', 'name': 'Ethereum'},
    {'symbol': 'BNBUSDT', 'name': 'BNB'},
    {'symbol': 'ADAUSDT', 'name': 'Cardano'},
    {'symbol': 'XRPUSDT', 'name': 'XRP'},
    {'symbol': 'SOLUSDT', 'name': 'Solana'},
    {'symbol': 'DOTUSDT', 'name': 'Polkadot'},
    {'symbol': 'DOGEUSDT', 'name': 'Dogecoin'},
    {'symbol': 'AVAXUSDT', 'name': 'Avalanche'},
    {'symbol': 'SHIBUSDT', 'name': 'Shiba Inu'},
    {'symbol': 'LINKUSDT', 'name': 'Chainlink'},
    {'symbol': 'MATICUSDT', 'name': 'Polygon'},
    {'symbol': 'UNIUSDT', 'name': 'Uniswap'},
    {'symbol': 'LTCUSDT', 'name': 'Litecoin'},
    {'symbol': 'BCHUSDT', 'name': 'Bitcoin Cash'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSymbols();
    _searchController.addListener(_filterSymbols);
  }

  void _loadSymbols() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final binanceService = context.read<BinanceService>();
      final symbols = await binanceService.getTradingPairs();
      
      if (symbols.isNotEmpty) {
        setState(() {
          _allSymbols = symbols;
          _filteredSymbols = symbols.take(50).toList(); // Mostrar solo los primeros 50 inicialmente
        });
        _logger.info('Loaded ${symbols.length} trading pairs');
      } else {
        // Si no se pueden cargar de la API, usar símbolos populares
        setState(() {
          _allSymbols = _popularSymbols
              .map((s) => {
                    'symbol': s['symbol']!,
                    'baseAsset': s['symbol']!.replaceAll('USDT', ''),
                    'quoteAsset': 'USDT',
                    'status': 'TRADING',
                  })
              .toList();
          _filteredSymbols = _allSymbols;
        });
        _logger.info('Using popular symbols as fallback');
      }
    } catch (e) {
      _logger.error('Error loading symbols: $e');
      // Usar símbolos populares como respaldo
      setState(() {
        _allSymbols = _popularSymbols
            .map((s) => {
                  'symbol': s['symbol']!,
                  'baseAsset': s['symbol']!.replaceAll('USDT', ''),
                  'quoteAsset': 'USDT',
                  'status': 'TRADING',
                })
            .toList();
        _filteredSymbols = _allSymbols;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterSymbols() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSymbols = _allSymbols.take(50).toList();
      });
      return;
    }

    setState(() {
      _filteredSymbols = _allSymbols.where((symbol) {
        final symbolName = symbol['symbol'].toString().toLowerCase();
        final baseAsset = symbol['baseAsset'].toString().toLowerCase();
        return symbolName.contains(query) || baseAsset.contains(query);
      }).take(50).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.search,
                color: AppColors.goldPrimary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Selector de Criptomonedas',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Símbolos populares
          _buildPopularSymbols(),
          
          const SizedBox(height: 16),
          
          // Búsqueda y selección
          Row(
            children: [
              // Buscador de símbolos
              Expanded(
                flex: 2,
                child: _buildSymbolSelector(),
              ),
              
              const SizedBox(width: 16),
              
              // Selector de timeframe
              Expanded(
                child: _buildTimeframeSelector(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSymbols() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criptomonedas Populares',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSymbols.take(8).map((symbol) {
            final isSelected = widget.selectedSymbol == symbol['symbol'];
            return GestureDetector(
              onTap: () => widget.onSymbolChanged(symbol['symbol']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.goldPrimary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.goldPrimary
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  symbol['name']!,
                  style: TextStyle(
                    color: isSelected ? AppColors.goldPrimary : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSymbolSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buscar Criptomoneda',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        GestureDetector(
          onTap: () {
            setState(() {
              _showDropdown = !_showDropdown;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedSymbol,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  _showDropdown ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown con búsqueda
        if (_showDropdown) ...[
          const SizedBox(height: 8),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Buscar símbolo...',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.goldPrimary),
                      ),
                    ),
                  ),
                ),
                
                // Lista de símbolos
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.goldPrimary,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredSymbols.length,
                          itemBuilder: (context, index) {
                            final symbol = _filteredSymbols[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                symbol['symbol'],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${symbol['baseAsset']} / ${symbol['quoteAsset']}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () {
                                widget.onSymbolChanged(symbol['symbol']);
                                setState(() {
                                  _showDropdown = false;
                                });
                                _searchController.clear();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeframeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeframe',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        DropdownButton<String>(
          value: widget.selectedTimeframe,
          isExpanded: true,
          dropdownColor: Colors.black,
          style: const TextStyle(color: AppColors.textPrimary),
          underline: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          items: _timeframes.map((timeframe) {
            return DropdownMenuItem<String>(
              value: timeframe['value'],
              child: Text(
                timeframe['label']!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onTimeframeChanged(value);
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
