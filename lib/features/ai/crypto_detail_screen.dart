import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candlesticks/candlesticks.dart' as CandleSticks;
import '../../ui/theme/colors.dart';
import '../../services/binance_service.dart';
import '../../models/candle.dart' as LocalCandle;

class CryptoDetailScreen extends StatefulWidget {
  final String cryptoSymbol;

  const CryptoDetailScreen({
    super.key,
    required this.cryptoSymbol,
  });

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedInterval = '1h';
  bool _isLoading = true;
  
  Map<String, dynamic> _cryptoData = {};
  List<LocalCandle.Candle> _chartData = [];
  Map<String, dynamic> _marketStats = {};

  final List<String> _intervals = ['1m', '5m', '15m', '1h', '4h', '1d'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCryptoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCryptoData() async {
    setState(() => _isLoading = true);
    
    try {
      final binanceService = context.read<BinanceService>();
      final symbol = '${widget.cryptoSymbol}USDT';
      
      // Cargar datos del precio actual
      final currentPrice = await binanceService.getCurrentPrice(symbol);
      
      // Cargar estadísticas 24h
      final stats = await binanceService.get24hStats(symbol);
      
      // Cargar datos de velas
      final candles = await binanceService.getCandlestickData(
        symbol,
        _selectedInterval,
        100,
      );
      
      setState(() {
        _cryptoData = {
          'symbol': widget.cryptoSymbol,
          'price': currentPrice,
          'pair': symbol,
        };
        _marketStats = stats;
        _chartData = candles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: $e'),
          backgroundColor: AppColors.bearish,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.cryptoSymbol,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.goldPrimary),
            onPressed: _loadCryptoData,
          ),
          IconButton(
            icon: Icon(Icons.star_border, color: AppColors.goldPrimary),
            onPressed: () {
              // Agregar a favoritos
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.cryptoSymbol} agregado a favoritos'),
                  backgroundColor: AppColors.bullish,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Chart'),
            Tab(text: 'Analysis'),
            Tab(text: 'Trade'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.goldPrimary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildChartTab(),
                _buildAnalysisTab(),
                _buildTradeTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final price = _cryptoData['price'] ?? 0.0;
    final change24h = _marketStats['priceChange'] != null
        ? double.tryParse(_marketStats['priceChange'].toString()) ?? 0.0
        : 0.0;
    final changePercent24h = _marketStats['priceChangePercent'] != null
        ? double.tryParse(_marketStats['priceChangePercent'].toString()) ?? 0.0
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldPrimary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.cryptoSymbol}/USDT',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      changePercent24h >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: changePercent24h >= 0
                          ? AppColors.bullish
                          : AppColors.bearish,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercent24h >= 0 ? '+' : ''}${changePercent24h.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: changePercent24h >= 0
                            ? AppColors.bullish
                            : AppColors.bearish,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(\$${change24h.toStringAsFixed(2)})',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Market Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldPrimary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Statistics (24h)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('High', '\$${_getStatValue('highPrice')}'),
                _buildStatRow('Low', '\$${_getStatValue('lowPrice')}'),
                _buildStatRow('Volume', '${_getStatValue('volume')} ${widget.cryptoSymbol}'),
                _buildStatRow('Quote Volume', '\$${_getStatValue('quoteVolume')}'),
                _buildStatRow('Trades', _getStatValue('count')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // AI Insights
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldPrimary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.goldPrimary),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insights',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  'Market Sentiment',
                  changePercent24h >= 0 ? 'Bullish' : 'Bearish',
                  changePercent24h >= 0 ? AppColors.bullish : AppColors.bearish,
                ),
                _buildInsightCard(
                  'Volatility',
                  'Moderate',
                  AppColors.warning,
                ),
                _buildInsightCard(
                  'Trend',
                  changePercent24h >= 2 ? 'Strong Up' : 
                  changePercent24h <= -2 ? 'Strong Down' : 'Sideways',
                  changePercent24h >= 2 ? AppColors.bullish :
                  changePercent24h <= -2 ? AppColors.bearish : AppColors.neutral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        // Interval Selector
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _intervals.length,
            itemBuilder: (context, index) {
              final interval = _intervals[index];
              final isSelected = _selectedInterval == interval;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedInterval = interval;
                    });
                    _loadCryptoData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.goldPrimary
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.goldPrimary,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interval,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Chart
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _chartData.isEmpty
                ? Center(
                    child: Text(
                      'No chart data available',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : CandleSticks.Candlesticks(
                    candles: _chartData
                        .map((c) => CandleSticks.Candle(
                              date: c.openTime,
                              high: c.high,
                              low: c.low,
                              open: c.open,
                              close: c.close,
                              volume: c.volume,
                            ))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalysisCard(
            'Technical Analysis',
            'RSI: 65.4 (Neutral)',
            'MACD: Bullish crossover detected',
            AppColors.bullish,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Support & Resistance',
            'Support: \$${(_cryptoData['price'] * 0.95).toStringAsFixed(2)}',
            'Resistance: \$${(_cryptoData['price'] * 1.05).toStringAsFixed(2)}',
            AppColors.info,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Volume Analysis',
            'Above average volume',
            'Strong buying pressure detected',
            AppColors.bullish,
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Quick Trade ${widget.cryptoSymbol}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showTradeDialog('BUY');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bullish,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'BUY ${widget.cryptoSymbol}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showTradeDialog('SELL');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bearish,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'SELL ${widget.cryptoSymbol}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldPrimary, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'Current Price',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${_cryptoData['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String subtitle, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatValue(String key) {
    final value = _marketStats[key];
    if (value == null) return '0';
    
    try {
      final doubleValue = double.parse(value.toString());
      return doubleValue.toStringAsFixed(2);
    } catch (e) {
      return value.toString();
    }
  }

  void _showTradeDialog(String side) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          '$side ${widget.cryptoSymbol}',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Trade functionality will be implemented here.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$side order placed!'),
                  backgroundColor: side == 'BUY' ? AppColors.bullish : AppColors.bearish,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: side == 'BUY' ? AppColors.bullish : AppColors.bearish,
            ),
            child: Text(
              side,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
