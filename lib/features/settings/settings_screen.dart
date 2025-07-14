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
  final _apiKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _priceAlertsEnabled = true;
  bool _newsAlertsEnabled = true;
  bool _tradingAlertsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';

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
    // TODO: Load settings from storage
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
            _buildAccountSection(),
            const SizedBox(height: 24),
            _buildApiSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildAppearanceSection(),
            const SizedBox(height: 24),
            _buildGeneralSection(),
            const SizedBox(height: 24),
            _buildSubscriptionSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        final user = auth.currentUser;

        return _buildSection(
          title: 'Account',
          icon: Icons.person,
          children: [
            if (user != null) ...[
              _buildInfoTile(
                'Email',
                user.email,
                Icons.email,
              ),
              _buildInfoTile(
                'User ID',
                user.id,
                Icons.badge,
              ),
              _buildInfoTile(
                'Subscription',
                user.subscriptionTier.toUpperCase(),
                Icons.star,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.subscriptionTier == 'premium'
                        ? AppColors.goldPrimary
                        : AppColors.info,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.subscriptionTier.toUpperCase(),
                    style: TextStyle(
                      color: user.subscriptionTier == 'premium'
                          ? AppColors.primaryDark
                          : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bearish,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildApiSection() {
    return _buildSection(
      title: 'Binance API',
      icon: Icons.api,
      children: [
        Text(
          'Connect your Binance account for live trading',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _apiKeyController,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'API Key',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintText: 'Enter your Binance API key',
            hintStyle:
                TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
            prefixIcon: Icon(Icons.key, color: AppColors.goldPrimary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldPrimary),
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _secretKeyController,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Secret Key',
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintText: 'Enter your Binance secret key',
            hintStyle:
                TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
            prefixIcon: Icon(Icons.security, color: AppColors.goldPrimary),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldPrimary),
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveApiKeys,
            icon: const Icon(Icons.save),
            label: const Text('Save API Keys'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your API keys are encrypted and stored securely on your device.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          'Enable Notifications',
          'Receive push notifications',
          _notificationsEnabled,
          (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _updateNotificationSettings();
          },
        ),
        _buildSwitchTile(
          'Price Alerts',
          'Get notified when price targets are hit',
          _priceAlertsEnabled,
          (value) {
            setState(() {
              _priceAlertsEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          'News Alerts',
          'Get notified of important crypto news',
          _newsAlertsEnabled,
          (value) {
            setState(() {
              _newsAlertsEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          'Trading Alerts',
          'Get notified of trading signals',
          _tradingAlertsEnabled,
          (value) {
            setState(() {
              _tradingAlertsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette,
      children: [
        _buildSwitchTile(
          'Dark Mode',
          'Use dark theme',
          _darkModeEnabled,
          (value) {
            setState(() {
              _darkModeEnabled = value;
            });
          },
        ),
        _buildDropdownTile(
          'Currency',
          'Display currency',
          _selectedCurrency,
          ['USD', 'EUR', 'GBP', 'JPY', 'BTC', 'ETH'],
          (value) {
            setState(() {
              _selectedCurrency = value!;
            });
          },
        ),
        _buildDropdownTile(
          'Language',
          'App language',
          _selectedLanguage,
          ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'],
          (value) {
            setState(() {
              _selectedLanguage = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'General',
      icon: Icons.settings,
      children: [
        _buildActionTile(
          'Export Data',
          'Export your trading data',
          Icons.download,
          () => _exportData(),
        ),
        _buildActionTile(
          'Import Data',
          'Import trading data from file',
          Icons.upload,
          () => _importData(),
        ),
        _buildActionTile(
          'Clear Cache',
          'Clear app cache and temporary files',
          Icons.delete_sweep,
          () => _clearCache(),
        ),
        _buildActionTile(
          'Reset Settings',
          'Reset all settings to default',
          Icons.restore,
          () => _resetSettings(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return Consumer<SubscriptionService>(
      builder: (context, subscription, child) {
        return _buildSection(
          title: 'Subscription',
          icon: Icons.star,
          children: [
            _buildActionTile(
              'Upgrade to Premium',
              'Unlock advanced features',
              Icons.upgrade,
              () => _showUpgradeDialog(),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildActionTile(
              'Restore Purchases',
              'Restore your previous purchases',
              Icons.restore_page,
              () => subscription.restorePurchases(),
            ),
            _buildActionTile(
              'Manage Subscription',
              'View and manage your subscription',
              Icons.manage_accounts,
              () => _manageSubscription(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info,
      children: [
        _buildInfoTile(
          'Version',
          AppConstants.appVersion,
          Icons.info_outline,
        ),
        _buildActionTile(
          'Privacy Policy',
          'Read our privacy policy',
          Icons.privacy_tip,
          () => _openPrivacyPolicy(),
        ),
        _buildActionTile(
          'Terms of Service',
          'Read our terms of service',
          Icons.description,
          () => _openTermsOfService(),
        ),
        _buildActionTile(
          'Contact Support',
          'Get help and support',
          Icons.support_agent,
          () => _contactSupport(),
        ),
        _buildActionTile(
          'Rate App',
          'Rate us on the app store',
          Icons.star_rate,
          () => _rateApp(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: AppColors.surfaceDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.goldPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.goldPrimary,
        inactiveThumbColor: AppColors.textSecondary,
        inactiveTrackColor: AppColors.borderColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        dropdownColor: AppColors.surfaceDark,
        style: TextStyle(color: AppColors.textPrimary),
        underline: Container(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.bearish : AppColors.goldPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.bearish : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
          ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon, {
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.goldPrimary),
      title: Text(
        title,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        value,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      trailing: trailing,
    );
  }

  void _saveApiKeys() async {
    // TODO: Implement API key saving with encryption
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('API keys saved securely'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _updateNotificationSettings() async {
    final notificationService = NotificationService();
    if (_notificationsEnabled) {
      await notificationService.requestPermissions();
    }
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data export feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _importData() {
    // TODO: Implement data import
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data import feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Clear Cache',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will clear all cached data. Are you sure?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Clear', style: TextStyle(color: AppColors.bearish)),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Reset Settings',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will reset all settings to default values. Are you sure?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement settings reset
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to default'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Reset', style: TextStyle(color: AppColors.bearish)),
          ),
        ],
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
            child:
                Text('Later', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement subscription upgrade
              context.read<SubscriptionService>().purchaseSubscription(context.read<SubscriptionService>().monthlySubscriptionId);
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
    // TODO: Open subscription management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening subscription management...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openPrivacyPolicy() {
    // TODO: Open privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening privacy policy...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openTermsOfService() {
    // TODO: Open terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening terms of service...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _contactSupport() {
    // TODO: Open support contact
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening support contact...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _rateApp() {
    // TODO: Open app store rating
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening app store...'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
