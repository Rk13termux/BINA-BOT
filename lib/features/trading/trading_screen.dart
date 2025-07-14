import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:candlesticks/candlesticks.dart';
import '../../../ui/theme/colors.dart';
import '../../../services/subscription_service.dart';
import '../../../services/auth_service.dart';
import 'trading_controller.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({super.key});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSymbol = 'BTCUSDT';
  String _selectedInterval = '1h';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TradingController>().setSelectedSymbol(_selectedSymbol);
      context.read<TradingController>().setSelectedInterval(_selectedInterval);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Trading',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Chart'),
            Tab(text: 'Trade'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChartTab(),
          _buildTradeTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  Widget _buildChartTab() {
    return Column(
      children: [
        // Symbol and interval selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSymbolSelector(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildIntervalSelector(),
              ),
            ],
          ),
        ),

        // Price info
        Consumer<TradingController>(
          builder: (context, trading, child) {
            final currentPrice = trading.currentPrice;
            final marketStats = trading.marketStats;
            final priceChangePercent = marketStats['priceChangePercent'] != null
                ? double.tryParse(
                        marketStats['priceChangePercent'].toString()) ??
                    0.0
                : 0.0;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSymbol,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priceChangePercent >= 0
                          ? AppColors.bullish
                          : AppColors.bearish,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${priceChangePercent >= 0 ? '+' : ''}${priceChangePercent.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Chart
        Expanded(
          child: Consumer<TradingController>(
            builder: (context, trading, child) {
              if (trading.isLoading) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.goldPrimary),
                );
              }

              final candles = trading.candleData;
              if (candles.isEmpty) {
                return Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Candlesticks(
                  candles: candles
                      .map((c) => Candle(
                            date: c.openTime,
                            high: c.high,
                            low: c.low,
                            open: c.open,
                            close: c.close,
                            volume: c.volume,
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTradeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account balance
          Consumer<AuthService>(
            builder: (context, auth, child) {
              final subscription = context.watch<SubscriptionService>();
              final showSubscriptionBanner = !subscription.isSubscribed;

              return Column(
                children: [
                  if (showSubscriptionBanner) _buildSubscriptionBanner(),
                  _buildBalanceCard(),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Order form
          _buildOrderForm(),

          const SizedBox(height: 20),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Consumer<TradingController>(
      builder: (context, trading, child) {
        final orders = trading.tradeHistory;

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              color: AppColors.surfaceDark,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  order.side.name.toUpperCase() == 'BUY'
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: order.side.name.toUpperCase() == 'BUY'
                      ? AppColors.bullish
                      : AppColors.bearish,
                ),
                title: Text(
                  '${order.side.name.toUpperCase()} ${order.symbol}',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Qty: ${order.quantity} @ \$${(order.price ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status.name),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSymbolSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSymbol,
          dropdownColor: AppColors.surfaceDark,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSymbol = newValue;
              });
              context
                  .read<TradingController>()
                  .setSelectedSymbol(_selectedSymbol);
            }
          },
          items: const [
            'BTCUSDT',
            'ETHUSDT',
            'BNBUSDT',
            'ADAUSDT',
            'SOLUSDT',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIntervalSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedInterval,
          dropdownColor: AppColors.surfaceDark,
          style: TextStyle(color: AppColors.textPrimary),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedInterval = newValue;
              });
              context
                  .read<TradingController>()
                  .setSelectedInterval(_selectedInterval);
            }
          },
          items: const [
            '1m',
            '5m',
            '15m',
            '1h',
            '4h',
            '1d',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return Consumer<SubscriptionService>(
      builder: (context, subscription, child) {
        if (!subscription.isSubscribed) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              border: Border.all(color: const Color(0xFFFFD700)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Unlock advanced trading features & AI analysis',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to subscription screen
                  },
                  child: const Text(
                    'Subscribe',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Balance',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$10,000.00',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Available: \$9,500.00',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  'In Orders: \$500.00',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderForm() {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place Order',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Order type selector
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bullish,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('BUY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bearish,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('SELL'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price input
            TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quantity input
            TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Quantity',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldPrimary),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Place order button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement order placement
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Order placed successfully!'),
                      backgroundColor: AppColors.bullish,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Market Buy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bullish,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.flash_off),
                    label: const Text('Market Sell'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bearish,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'filled':
        return AppColors.bullish;
      case 'cancelled':
        return AppColors.bearish;
      case 'pending':
        return AppColors.goldPrimary;
      default:
        return AppColors.textSecondary;
    }
  }
}
