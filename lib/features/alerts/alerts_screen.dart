import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/colors.dart';
import '../../../models/signal.dart';
import '../../../services/auth_service.dart';
import 'alerts_controller.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertsController>().startMonitoring();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Alerts',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppColors.goldPrimary),
            onPressed: () => _showCreateAlertDialog(context),
          ),
        ],
      ),
      body: Consumer<AlertsController>(
        builder: (context, alertsController, child) {
          if (alertsController.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.bearish,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${alertsController.error}',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => alertsController.startMonitoring(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final alerts = alertsController.alerts;
          final signals = alertsController.signals;

          return Column(
            children: [
              // Subscription warning for free users
              Consumer<AuthService>(
                builder: (context, auth, child) {
                  final user = auth.currentUser;
                  if (user?.subscriptionTier == 'free') {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Free Plan: 5 alerts max',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Upgrade to Premium for 25 alerts or Pro for unlimited',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Tabs for alerts and signals
              DefaultTabController(
                length: 2,
                child: Expanded(
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: AppColors.goldPrimary,
                        labelColor: AppColors.goldPrimary,
                        unselectedLabelColor: AppColors.textSecondary,
                        tabs: [
                          Tab(text: 'Price Alerts (${alerts.length})'),
                          Tab(text: 'Signals (${signals.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAlertsTab(alerts, alertsController),
                            _buildSignalsTab(signals),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab(List<PriceAlert> alerts, AlertsController controller) {
    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No price alerts',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first alert to get notified',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateAlertDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(alert, controller);
      },
    );
  }

  Widget _buildSignalsTab(List<Signal> signals) {
    if (signals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No signals yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Signals will appear here when generated',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        return _buildSignalCard(signal);
      },
    );
  }

  Widget _buildAlertCard(PriceAlert alert, AlertsController controller) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAlertConditionIcon(alert.condition),
                  color: _getAlertConditionColor(alert.condition),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.symbol,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: alert.isEnabled,
                  activeColor: AppColors.goldPrimary,
                  onChanged: (value) {
                    controller.toggleAlert(alert.id, value);
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  color: AppColors.surfaceDark,
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.removeAlert(alert.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              color: AppColors.bearish, size: 16),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_getConditionText(alert.condition)} ${alert.value}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (alert.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                alert.description!,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: alert.isEnabled
                        ? AppColors.bullish
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    alert.isEnabled ? 'ACTIVE' : 'DISABLED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(alert.createdAt),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (alert.triggeredAt != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.goldPrimary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.goldPrimary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Triggered ${_formatTime(alert.triggeredAt!)}',
                      style:
                          TextStyle(color: AppColors.goldPrimary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(Signal signal) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSignalIcon(signal.type),
                  color: _getSignalColor(signal.type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    signal.symbol,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(signal.confidence),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    signal.confidence.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              signal.reason,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Price: \$${signal.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(signal.timestamp),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (signal.metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: signal.metadata.entries.map((entry) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getSignalIcon(SignalType type) {
    switch (type) {
      case SignalType.buy:
        return Icons.trending_up;
      case SignalType.sell:
        return Icons.trending_down;
      case SignalType.hold:
        return Icons.pause;
      case SignalType.warning:
        return Icons.warning;
    }
  }

  Color _getSignalColor(SignalType type) {
    switch (type) {
      case SignalType.buy:
        return AppColors.bullish;
      case SignalType.sell:
        return AppColors.bearish;
      case SignalType.hold:
        return AppColors.neutral;
      case SignalType.warning:
        return AppColors.warning;
    }
  }

  IconData _getAlertConditionIcon(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.priceAbove:
        return Icons.keyboard_arrow_up;
      case AlertCondition.priceBelow:
        return Icons.keyboard_arrow_down;
      case AlertCondition.rsiAbove:
        return Icons.trending_up;
      case AlertCondition.rsiBelow:
        return Icons.trending_down;
      case AlertCondition.volumeAbove:
        return Icons.volume_up;
      case AlertCondition.priceChange:
        return Icons.compare_arrows;
    }
  }

  Color _getAlertConditionColor(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.priceAbove:
        return AppColors.bullish;
      case AlertCondition.priceBelow:
        return AppColors.bearish;
      case AlertCondition.rsiAbove:
        return AppColors.warning;
      case AlertCondition.rsiBelow:
        return AppColors.info;
      case AlertCondition.volumeAbove:
        return AppColors.goldPrimary;
      case AlertCondition.priceChange:
        return AppColors.neutral;
    }
  }

  String _getConditionText(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.priceAbove:
        return 'Price above';
      case AlertCondition.priceBelow:
        return 'Price below';
      case AlertCondition.rsiAbove:
        return 'RSI above';
      case AlertCondition.rsiBelow:
        return 'RSI below';
      case AlertCondition.volumeAbove:
        return 'Volume above';
      case AlertCondition.priceChange:
        return 'Price change';
    }
  }

  Color _getConfidenceColor(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.low:
        return AppColors.textSecondary;
      case ConfidenceLevel.medium:
        return AppColors.warning;
      case ConfidenceLevel.high:
        return AppColors.bullish;
      case ConfidenceLevel.veryHigh:
        return AppColors.goldPrimary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showCreateAlertDialog(BuildContext context) {
    final priceController = TextEditingController();
    AlertCondition selectedCondition = AlertCondition.priceAbove;
    String selectedSymbol = 'BTCUSDT';
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            'Create Alert',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert condition selector
              Text(
                'Condition',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AlertCondition>(
                value: selectedCondition,
                dropdownColor: AppColors.surfaceDark,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                ),
                items: AlertCondition.values
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(_getConditionText(condition)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCondition = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Symbol selector
              Text(
                'Symbol',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedSymbol,
                dropdownColor: AppColors.surfaceDark,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                ),
                items: const [
                  'BTCUSDT',
                  'ETHUSDT',
                  'BNBUSDT',
                  'ADAUSDT',
                  'SOLUSDT',
                ]
                    .map((symbol) => DropdownMenuItem(
                          value: symbol,
                          child: Text(symbol),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSymbol = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Value input
              Text(
                'Value',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                style: TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
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

              // Description input
              Text(
                'Description (Optional)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(priceController.text);
                if (value != null) {
                  context.read<AlertsController>().addPriceAlert(
                        symbol: selectedSymbol,
                        condition: selectedCondition,
                        value: value,
                        description: descriptionController.text.isEmpty
                            ? null
                            : descriptionController.text,
                      );
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alert created for $selectedSymbol'),
                      backgroundColor: AppColors.bullish,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
