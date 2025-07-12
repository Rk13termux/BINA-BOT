import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/binance_websocket_service.dart';
import '../services/api_manager.dart';

class ApiConnectionTester extends StatefulWidget {
  const ApiConnectionTester({super.key});

  @override
  State<ApiConnectionTester> createState() => _ApiConnectionTesterState();
}

class _ApiConnectionTesterState extends State<ApiConnectionTester> {
  bool _isTesting = false;
  String _testResult = '';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Testing API connection...';
    });

    try {
      final webSocketService = context.read<BinanceWebSocketService>();
      final apiManager = context.read<ApiManager>();

      // Test API first
      _updateStatus('Testing Binance API...');
      final apiTest = await apiManager.testConnection();
      
      if (!apiTest) {
        setState(() {
          _testResult = 'API Connection Failed';
          _isConnected = false;
          _isTesting = false;
        });
        return;
      }

      // Test WebSocket connection
      _updateStatus('Testing WebSocket connection...');
      final wsTest = await webSocketService.testConnection();
      
      if (wsTest) {
        setState(() {
          _testResult = 'All connections successful!';
          _isConnected = true;
          _isTesting = false;
        });
      } else {
        setState(() {
          _testResult = 'WebSocket connection failed';
          _isConnected = false;
          _isTesting = false;
        });
      }

    } catch (e) {
      setState(() {
        _testResult = 'Connection test failed: $e';
        _isConnected = false;
        _isTesting = false;
      });
    }
  }

  void _updateStatus(String status) {
    setState(() {
      _testResult = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected 
                      ? Icons.check_circle 
                      : _isTesting 
                          ? Icons.hourglass_empty 
                          : Icons.error,
                  color: _isConnected 
                      ? Colors.green 
                      : _isTesting 
                          ? Colors.orange 
                          : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'API Connection Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              _testResult,
              style: TextStyle(
                color: _isConnected 
                    ? Colors.green 
                    : _isTesting 
                        ? Colors.orange 
                        : Colors.red,
                fontSize: 14,
              ),
            ),
            
            if (_isConnected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Real-time BTC price display
              Consumer<BinanceWebSocketService>(
                builder: (context, wsService, child) {
                  final btcPrice = wsService.getFormattedPrice('BTCUSDT');
                  final priceChange = wsService.getPriceChange('BTCUSDT');
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live BTC Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$$btcPrice',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          
                          if (priceChange != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: priceChange >= 0 
                                    ? const Color(0xFF00FF88) 
                                    : const Color(0xFFFF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Retry button
            if (!_isTesting)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: Text(_isConnected ? 'Retest Connection' : 'Retry Connection'),
                ),
              ),
              
            if (_isTesting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
