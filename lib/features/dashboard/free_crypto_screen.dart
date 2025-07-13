import 'package:flutter/material.dart';
import '../../ui/widgets/free_price_widget.dart';
import '../../ui/theme/colors.dart';

class FreeCryptoScreen extends StatelessWidget {
  const FreeCryptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Precios de Cryptomonedas'),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with info
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldPrimary.withOpacity(0.1),
                    AppColors.warning.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.goldPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Versión Gratuita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Los precios se actualizan cada 2 minutos. Actualiza a Premium para datos en tiempo real.',
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
            ),

            // Top Cryptocurrencies
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Top Cryptomonedas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            FreePriceWidget(
              symbols: const [
                'BTC', 'ETH', 'BNB', 'ADA', 'XRP', 
                'SOL', 'DOT', 'DOGE', 'AVAX', 'MATIC'
              ],
              showHeader: false,
            ),

            const SizedBox(height: 24),

            // DeFi Tokens
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tokens DeFi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            FreePriceWidget(
              symbols: const [
                'UNI', 'LINK', 'AAVE', 'COMP', 'SUSHI'
              ],
              showHeader: false,
            ),

            const SizedBox(height: 24),

            // Layer 1 Blockchains
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Layer 1 Blockchains',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            FreePriceWidget(
              symbols: const [
                'ATOM', 'NEAR', 'ALGO', 'FTM', 'ONE'
              ],
              showHeader: false,
            ),

            const SizedBox(height: 32),

            // Upgrade prompt
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldPrimary.withOpacity(0.2),
                    AppColors.warning.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rocket_launch,
                    color: AppColors.goldPrimary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Actualiza a Premium',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Obtén acceso a:',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureRow('✓ Precios en tiempo real'),
                      _buildFeatureRow('✓ Más de 1000 cryptomonedas'),
                      _buildFeatureRow('✓ Gráficos avanzados con indicadores'),
                      _buildFeatureRow('✓ Alertas personalizadas'),
                      _buildFeatureRow('✓ Análisis de mercado con IA'),
                      _buildFeatureRow('✓ Trading automatizado'),
                      _buildFeatureRow('✓ Sin anuncios'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to subscription screen
                        Navigator.pushNamed(context, '/subscription');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Empezar Prueba Gratuita',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desde \$5/mes • Cancela cuando quieras',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
