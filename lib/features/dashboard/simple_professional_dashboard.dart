import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SimpleProfessionalDashboard extends StatefulWidget {
  const SimpleProfessionalDashboard({Key? key}) : super(key: key);

  @override
  State<SimpleProfessionalDashboard> createState() => _SimpleProfessionalDashboardState();
}

class _SimpleProfessionalDashboardState extends State<SimpleProfessionalDashboard>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildQuickStats(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalysisTab(),
                _buildAccountTab(),
                _buildPortfolioTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundDark,
      elevation: 0,
      title: Row(
        children: [
          Icon(
            Icons.analytics,
            color: AppColors.goldPrimary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Invictus Trader Pro - Análisis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'En Desarrollo',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickStats() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Dashboard',
              'Profesional',
              '',
              AppColors.goldPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Estado',
              'Desarrollo',
              '',
              AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Funciones',
              'Avanzadas',
              '',
              AppColors.goldPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.goldPrimary,
        indicatorWeight: 3,
        labelColor: AppColors.goldPrimary,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Análisis'),
          Tab(text: 'Cuenta'),
          Tab(text: 'Portfolio'),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.goldPrimary.withOpacity(0.2),
                  AppColors.goldPrimary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.analytics,
                  size: 48,
                  color: AppColors.goldPrimary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Dashboard de Análisis Profesional',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sistema completo de análisis técnico con integración Binance API\ny gráficos avanzados para trading profesional',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features list
          Expanded(
            child: ListView(
              children: [
                _buildFeatureCard(
                  'Gráficos Candlestick Avanzados',
                  'Visualización profesional con múltiples timeframes',
                  Icons.candlestick_chart,
                  'Implementado',
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Integración Binance API',
                  'Conexión directa con tu cuenta de Binance',
                  Icons.api,
                  'Implementado',
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Order Book en Tiempo Real',
                  'Profundidad de mercado y análisis de liquidez',
                  Icons.list_alt,
                  'Implementado',
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Análisis Técnico',
                  'Indicadores y herramientas profesionales',
                  Icons.insights,
                  'En Desarrollo',
                  AppColors.warning,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  'Portfolio Management',
                  'Gestión avanzada de portafolio',
                  Icons.account_balance_wallet,
                  'Próximamente',
                  AppColors.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccountTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: AppColors.goldPrimary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Gestión de Cuenta Binance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Conecta tu API de Binance para acceder a\\nfunciones avanzadas de cuenta y trading',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _showComingSoon('Configuración de API');
            },
            icon: Icon(Icons.link),
            label: Text('Configurar API Binance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 64,
            color: AppColors.goldPrimary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Análisis de Portfolio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Análisis detallado de tu portafolio\\ncon métricas avanzadas y rendimiento',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              _showComingSoon('Análisis de Portfolio');
            },
            icon: Icon(Icons.analytics),
            label: Text('Ver Portfolio'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.goldPrimary,
              foregroundColor: AppColors.backgroundDark,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard(String title, String description, IconData icon, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.goldPrimary,
              size: 24,
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
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
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
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
