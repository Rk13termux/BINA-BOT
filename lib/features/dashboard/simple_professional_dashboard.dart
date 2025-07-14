import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/data_stream_service.dart';
import '../../services/plugins/plugin_manager.dart';

/// Dashboard profesional simplificado para Invictus Trader Pro
class SimpleProfessionalDashboard extends StatefulWidget {
  const SimpleProfessionalDashboard({super.key});

  @override
  State<SimpleProfessionalDashboard> createState() => _SimpleProfessionalDashboardState();
}

class _SimpleProfessionalDashboardState extends State<SimpleProfessionalDashboard> 
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Consumer2<DataStreamService, PluginManager>(
          builder: (context, dataService, pluginManager, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con estado
                  _buildHeader(dataService),
                  
                  const SizedBox(height: 24),
                  
                  // Métricas principales
                  _buildMainMetrics(dataService, pluginManager),
                  
                  const SizedBox(height: 24),
                  
                  // Indicadores técnicos
                  _buildTechnicalIndicators(dataService),
                  
                  const SizedBox(height: 24),
                  
                  // Señales activas
                  _buildActiveSignals(pluginManager),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(DataStreamService dataService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dataService.isRunning 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFFFF5722),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dataService.isRunning 
                            ? const Color(0xFF4CAF50).withValues(alpha: 0.5)
                            : const Color(0xFFFF5722).withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVICTUS TRADER PRO',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  dataService.isRunning ? 'Sistema Activo' : 'Sistema Inactivo',
                  style: TextStyle(
                    color: dataService.isRunning 
                        ? const Color(0xFF4CAF50) 
                        : const Color(0xFFFF5722),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'BTC/USDT',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                '\$${dataService.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics(DataStreamService dataService, PluginManager pluginManager) {
    final activePlugins = pluginManager.pluginEnabled.values.where((enabled) => enabled).length;
    final totalSignals = pluginManager.getAllSignals().length;
    
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Plugins Activos',
            value: activePlugins.toString(),
            icon: Icons.extension,
            color: const Color(0xFF2196F3),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildMetricCard(
            title: 'Señales Totales',
            value: totalSignals.toString(),
            icon: Icons.trending_up,
            color: const Color(0xFF4CAF50),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: _buildMetricCard(
            title: 'Indicadores',
            value: dataService.technicalIndicators.length.toString(),
            icon: Icons.analytics,
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators(DataStreamService dataService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indicadores Técnicos',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            ),
          ),
          child: dataService.technicalIndicators.isEmpty
              ? const Center(
                  child: Text(
                    'Inicializando indicadores...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2,
                  ),
                  itemCount: dataService.technicalIndicators.length,
                  itemBuilder: (context, index) {
                    final indicator = dataService.technicalIndicators.entries.elementAt(index);
                    return _buildIndicatorItem(indicator.key, indicator.value);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIndicatorItem(String name, double value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSignals(PluginManager pluginManager) {
    final signals = pluginManager.getAllSignals();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Señales Activas',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const Spacer(),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '${signals.length}',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            ),
          ),
          child: signals.isEmpty
              ? const Center(
                  child: Text(
                    'No hay señales activas',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                )
              : Column(
                  children: signals.take(5).map((signal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildSignalItem(signal),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSignalItem(signal) {
    Color signalColor = signal.type.name == 'buy' 
        ? const Color(0xFF4CAF50) 
        : signal.type.name == 'sell'
            ? const Color(0xFFFF5722)
            : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: signalColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: signalColor,
              shape: BoxShape.circle,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.type.name.toUpperCase(),
                  style: TextStyle(
                    color: signalColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  '${signal.symbol} - \$${signal.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            signal.confidence.name.toUpperCase(),
            style: TextStyle(
              color: signalColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
