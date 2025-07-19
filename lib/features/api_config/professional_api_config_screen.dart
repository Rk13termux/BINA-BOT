import 'package:flutter/material.dart';
import '../../ui/theme/app_colors.dart';

/// Pantalla profesional de configuración de APIs sin keys preconfiguradas
class ApiConfigurationScreen extends StatefulWidget {
  const ApiConfigurationScreen({super.key});

  @override
  State<ApiConfigurationScreen> createState() => _ApiConfigurationScreenState();
}

class _ApiConfigurationScreenState extends State<ApiConfigurationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _binanceApiKeyController = TextEditingController();
  final _binanceSecretController = TextEditingController();
  bool _isTestingBinance = false;
  bool _isTestNet = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Configuración de APIs'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.goldPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Binance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBinanceConfigTab(),
        ],
      ),
    );
  }

  Widget _buildBinanceConfigTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Binance API',
            'Conecte su cuenta de Binance para trading en tiempo real y acceso a datos de mercado.',
            Icons.currency_bitcoin,
            Colors.orange,
          ),
          const SizedBox(height: 24),
          _buildInstructionsCard('Binance'),
          const SizedBox(height: 24),
          _buildBinanceForm(),
          const SizedBox(height: 24),
          // Eliminados widgets no definidos (_buildTestResult, _buildProgressIndicator)
        ],
      ),
    );
  }

  Widget _buildBinanceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _binanceApiKeyController,
          label: 'API Key',
          hint: 'Ingrese su API Key de Binance',
          icon: Icons.vpn_key,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _binanceSecretController,
          label: 'Secret Key',
          hint: 'Ingrese su Secret Key de Binance',
          icon: Icons.lock,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Switch(
              value: _isTestNet,
              activeColor: AppColors.goldPrimary,
              onChanged: (val) {
                setState(() {
                  _isTestNet = val;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              'Usar TestNet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: _isTestingBinance
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
                  )
                : const Icon(Icons.cloud_done),
            label: Text(_isTestingBinance ? 'Probando...' : 'Probar Conexión'),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: AppColors.goldPrimary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.goldPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ...existing code...

  Widget _buildInstructionsCard(String apiType) {
    final instructions = apiType == 'Binance' 
        ? [
            '1. Vaya a Binance.com → Account → API Management',
            '2. Cree una nueva API Key con nombre "InvictusTrader"',
            '3. Habilite permisos: "Spot & Margin Trading" + "Futures"',
            '4. Copie y pegue ambas keys en los campos siguientes',
            '5. Para mayor seguridad, use TestNet para pruebas',
            '6. Nunca comparta sus API Keys con terceros',
          ] : [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instrucciones Paso a Paso',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          ...instructions.map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              instruction,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }
}
