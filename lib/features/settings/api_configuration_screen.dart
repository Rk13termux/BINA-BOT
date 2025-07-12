import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/binance_websocket_service.dart';
import '../../core/api_manager.dart';
import '../../ui/widgets/api_connection_tester.dart';

class ApiConfigurationScreen extends StatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  State<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends State<ApiConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isTestnet = false;
  bool _isSaving = false;
  bool _showSecretKey = false;
  
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final apiManager = context.read<ApiManager>();
    await apiManager.loadCredentials();
    
    // Note: For security, we don't load the actual keys into the text fields
    // Just indicate if credentials are configured
    setState(() {
      if (apiManager.isConfigured) {
        _apiKeyController.text = '••••••••••••••••';
        _secretKeyController.text = '••••••••••••••••••••••••••••••••';
      }
    });
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final apiManager = context.read<ApiManager>();
      final webSocketService = context.read<BinanceWebSocketService>();

      // Save credentials
      await apiManager.setCredentials(
        _apiKeyController.text.trim(),
        _secretKeyController.text.trim(),
        testnet: _isTestnet,
      );

      // Test connection
      final isApiConnected = await apiManager.testConnection();
      if (isApiConnected) {
        // Connect WebSocket
        await webSocketService.connect(useTestnet: _isTestnet);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API credentials saved and connection established!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credentials saved but connection failed. Please check your keys.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('API Configuration'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFFFFD700)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.api,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Binance API Configuration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure your Binance API credentials to enable real-time trading features.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // API Connection Status
            const ApiConnectionTester(),

            const SizedBox(height: 24),

            // Configuration Form
            Card(
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Credentials',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // API Key Field
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'API Key',
                          hintText: 'Enter your Binance API Key',
                          prefixIcon: Icon(Icons.key, color: Color(0xFFFFD700)),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your API Key';
                          }
                          if (value.contains('•')) {
                            return 'Please enter a valid API Key';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Secret Key Field
                      TextFormField(
                        controller: _secretKeyController,
                        obscureText: !_showSecretKey,
                        decoration: InputDecoration(
                          labelText: 'Secret Key',
                          hintText: 'Enter your Binance Secret Key',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFFFD700)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showSecretKey ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _showSecretKey = !_showSecretKey;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                          labelStyle: const TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Secret Key';
                          }
                          if (value.contains('•')) {
                            return 'Please enter a valid Secret Key';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Testnet Toggle
                      Row(
                        children: [
                          Switch(
                            value: _isTestnet,
                            onChanged: (value) {
                              setState(() {
                                _isTestnet = value;
                              });
                            },
                            activeColor: const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Use Testnet',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 16,
                          ),
                        ],
                      ),

                      if (_isTestnet)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Testnet mode uses paper trading and test data.',
                            style: TextStyle(
                              color: Colors.orange.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveCredentials,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD700),
                            foregroundColor: const Color(0xFF1A1A1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1A1A1A),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Save & Test Connection',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: const Color(0xFF2A2A2A),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to get your API Keys',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInstructionStep(
                      '1.',
                      'Go to Binance.com and log into your account',
                    ),
                    _buildInstructionStep(
                      '2.',
                      'Navigate to Account > API Management',
                    ),
                    _buildInstructionStep(
                      '3.',
                      'Create a new API Key with "Enable Reading" permission',
                    ),
                    _buildInstructionStep(
                      '4.',
                      'Copy the API Key and Secret Key to the fields above',
                    ),
                    _buildInstructionStep(
                      '5.',
                      'For testing, you can use Binance Testnet',
                    ),
                    
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your API keys are stored securely on your device and never sent to our servers.',
                              style: TextStyle(
                                color: Colors.blue.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }
}
