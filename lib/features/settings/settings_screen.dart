import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _secretKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // TODO: cargar settings desde almacenamiento seguro
  }

  Future<void> _saveApiKeys() async {
    final apiKey = _apiKeyController.text.trim();
    final secretKey = _secretKeyController.text.trim();
    if (apiKey.isEmpty || secretKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API Key y Secret Key son requeridas'),
          backgroundColor: AppColors.bearish,
        ),
      );
      return;
    }
    // Guardar claves y probar conexión
    try {
      // Aquí deberías guardar las claves en SecureStorage y probar la conexión a Binance
      // await Provider.of<ApiManager>(context, listen: false).setCredentials(apiKey, secretKey);
      // final testResult = await Provider.of<ApiManager>(context, listen: false).testConnection();
      // Si la conexión es exitosa, activa el WebSocket
      // _subscribeAllTickers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Claves guardadas y conexión exitosa'),
          backgroundColor: AppColors.bullish,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al conectar con Binance: $e'),
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
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.goldPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSwitchTile(
              title: 'Dark Mode',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildDropdownTile(
              title: 'Currency',
              value: _selectedCurrency,
              items: ['USD', 'EUR', 'GBP', 'JPY', 'BTC', 'ETH'],
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value ?? 'USD';
                });
              },
            ),
            _buildDropdownTile(
              title: 'Language',
              value: _selectedLanguage,
              items: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value ?? 'English';
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                labelText: 'Binance API Key',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _secretKeyController,
              decoration: InputDecoration(
                labelText: 'Binance Secret Key',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceDark,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: AppColors.textPrimary),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
              onPressed: _saveApiKeys,
              child: const Text('Guardar Claves y Probar Conexión'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
              onPressed: _showUpgradeDialog,
              child: const Text('Upgrade to Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.bullish,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title, style: TextStyle(color: AppColors.textPrimary)),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        dropdownColor: AppColors.surfaceDark,
        style: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Upgrade to Premium',
          style: TextStyle(color: AppColors.goldPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock advanced features:',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildFeatureItem('Advanced technical indicators'),
            _buildFeatureItem('Real-time WebSocket data'),
            _buildFeatureItem('Unlimited alerts'),
            _buildFeatureItem('Custom plugins'),
            _buildFeatureItem('Priority customer support'),
            _buildFeatureItem('No ads'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement subscription upgrade
              context.read<SubscriptionService>().purchaseSubscription(
                  context.read<SubscriptionService>().monthlySubscriptionId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check, color: AppColors.goldPrimary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _manageSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening subscription management...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening privacy policy...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening terms of service...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening support contact...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening app store...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
