import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../services/binance_service.dart';
import '../../../services/binance_websocket_service.dart';
import '../../../services/data_stream_service.dart';
import '../../../utils/logger.dart';
import '../widgets/crypto_selector_widget.dart';
import '../widgets/technical_indicators_widget.dart';
import '../widgets/real_time_prices_widget.dart';
import '../widgets/portfolio_balance_widget.dart';
import '../widgets/floating_menu_widget.dart';
import '../../ai_assistant/professional_ai_assistant_screen.dart';

/// Dashboard profesional de trading con análisis en tiempo real
class ProfessionalTradingDashboard extends StatefulWidget {
  const ProfessionalTradingDashboard({super.key});

  @override
  State<ProfessionalTradingDashboard> createState() => _ProfessionalTradingDashboardState();
}

class _ProfessionalTradingDashboardState extends State<ProfessionalTradingDashboard>
    with TickerProviderStateMixin {
  static final AppLogger _logger = AppLogger();
  
  late AnimationController _menuController;
  late AnimationController _priceUpdateController;
  
  String _selectedSymbol = 'BTCUSDT';
  String _selectedTimeframe = '1h';
  bool _isMenuExpanded = false;
  bool _isRealTimeEnabled = true;
  
  final List<String> _selectedIndicators = [];
  final Map<String, double> _currentPrices = {};
  
  @override
  void initState() {
    super.initState();
    
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _priceUpdateController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _initializeServices();
  }

  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final websocketService = context.read<BinanceWebSocketService>();
        final dataStreamService = context.read<DataStreamService>();
        
        // Conectar WebSocket si no está conectado
        if (!websocketService.isConnected) {
          websocketService.connect();
        }
        
        // Inicializar el servicio de datos en tiempo real
        if (!dataStreamService.isRunning) {
          dataStreamService.initialize();
        }
        
        _logger.info('Trading dashboard services initialized');
      } catch (e) {
        _logger.error('Error initializing dashboard services: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.backgroundSecondary,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Contenido principal
              _buildMainContent(),
              
              // Menú flotante estilo widget
              Positioned(
                top: 20,
                right: 20,
                child: FloatingMenuWidget(
                  isExpanded: _isMenuExpanded,
                  onToggle: _toggleMenu,
                  onApiConfig: _navigateToApiConfig,
                  onIndicatorConfig: _navigateToIndicatorConfig,
                  onSettings: _navigateToSettings,
                  onHelp: _showHelp,
                  onAIAssistant: _navigateToAIAssistant,
                ),
              ),
              
              // Indicador de conexión en tiempo real
              if (_isRealTimeEnabled)
                Positioned(
                  top: 20,
                  left: 20,
                  child: _buildRealTimeIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 80, // Espacio para el menú flotante
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con logo y título
          _buildHeader(),
          
          const SizedBox(height: 24),
          
          // Selector de criptomoneda
          CryptoSelectorWidget(
            selectedSymbol: _selectedSymbol,
            selectedTimeframe: _selectedTimeframe,
            onSymbolChanged: _onSymbolChanged,
            onTimeframeChanged: _onTimeframeChanged,
          ),
          
          const SizedBox(height: 24),
          
          // Precios en tiempo real
          RealTimePricesWidget(
            selectedSymbol: _selectedSymbol,
            onPriceUpdate: _onPriceUpdate,
          ),
          
          const SizedBox(height: 24),
          
          // Balance y portfolio
          PortfolioBalanceWidget(),
          
          const SizedBox(height: 24),
          
          // Indicadores técnicos
          TechnicalIndicatorsWidget(
            selectedSymbol: _selectedSymbol,
            selectedTimeframe: _selectedTimeframe,
            selectedIndicators: _selectedIndicators,
            onIndicatorToggle: _onIndicatorToggle,
          ),
          
          const SizedBox(height: 24),
          
          // Sección de análisis profundo
          _buildDeepAnalysisSection(),
          
          const SizedBox(height: 24),
          
          // Sección de estadísticas de mercado
          _buildMarketStatsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Logo de la app
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/icons/icon.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INVICTUS TRADER PRO',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional Trading Analysis',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Estado de conexión API
          Consumer<BinanceService>(
            builder: (context, service, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: service.isAuthenticated
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: service.isAuthenticated ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      service.isAuthenticated ? Icons.check_circle : Icons.error,
                      color: service.isAuthenticated ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      service.isAuthenticated ? 'API OK' : 'NO API',
                      style: TextStyle(
                        color: service.isAuthenticated ? Colors.green : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeIndicator() {
    return Consumer<BinanceWebSocketService>(
      builder: (context, websocketService, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: websocketService.isConnected
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: websocketService.isConnected ? Colors.green : Colors.orange,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: websocketService.isConnected ? Colors.green : Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                websocketService.isConnected ? 'LIVE' : 'CONNECTING',
                style: TextStyle(
                  color: websocketService.isConnected ? Colors.green : Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeepAnalysisSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
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
                Icons.analytics,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Análisis Profundo',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PROFESIONAL',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Análisis avanzado con múltiples indicadores técnicos y patrones de mercado en tiempo real.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botones de acción para análisis
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAnalysisButton(
                'Señales de Trading',
                Icons.show_chart,
                Colors.green,
                () => _showTradingSignals(),
              ),
              _buildAnalysisButton(
                'Patrones de Precio',
                Icons.pattern,
                Colors.purple,
                () => _showPricePatterns(),
              ),
              _buildAnalysisButton(
                'Análisis de Volumen',
                Icons.bar_chart,
                Colors.orange,
                () => _showVolumeAnalysis(),
              ),
              _buildAnalysisButton(
                'Soporte y Resistencia',
                Icons.horizontal_rule,
                Colors.cyan,
                () => _showSupportResistance(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.goldPrimary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Estadísticas de Mercado',
                style: TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Grid de estadísticas
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildStatCard('Cap. de Mercado', '\$2.1T', Colors.blue),
              _buildStatCard('Volumen 24h', '\$89.5B', Colors.green),
              _buildStatCard('Dominancia BTC', '52.3%', Colors.orange),
              _buildStatCard('Miedo/Codicia', '74 (Codicia)', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
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
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de navegación y callbacks
  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
    
    if (_isMenuExpanded) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _onSymbolChanged(String symbol) {
    setState(() {
      _selectedSymbol = symbol;
    });
    _logger.info('Symbol changed to: $symbol');
  }

  void _onTimeframeChanged(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    _logger.info('Timeframe changed to: $timeframe');
  }

  void _onPriceUpdate(String symbol, double price) {
    setState(() {
      _currentPrices[symbol] = price;
    });
    
    // Animar actualización de precio
    _priceUpdateController.forward().then((_) {
      _priceUpdateController.reverse();
    });
  }

  void _onIndicatorToggle(String indicator, bool enabled) {
    setState(() {
      if (enabled) {
        _selectedIndicators.add(indicator);
      } else {
        _selectedIndicators.remove(indicator);
      }
    });
    _logger.info('Indicator $indicator ${enabled ? 'enabled' : 'disabled'}');
  }

  // Navegación
  void _navigateToApiConfig() {
    Navigator.pushNamed(context, '/api-config');
  }

  void _navigateToIndicatorConfig() {
    Navigator.pushNamed(context, '/indicator-config');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToAIAssistant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalAIAssistantScreen(
          selectedSymbol: _selectedSymbol,
          selectedTimeframe: _selectedTimeframe,
          activeIndicators: _selectedIndicators,
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Ayuda', style: TextStyle(color: AppColors.goldPrimary)),
        content: const Text(
          'Dashboard profesional para análisis de trading en tiempo real.\n\n'
          '• Configure sus APIs en el menú flotante\n'
          '• Seleccione criptomonedas para analizar\n'
          '• Active/desactive indicadores técnicos\n'
          '• Monitoree precios en tiempo real',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido', style: TextStyle(color: AppColors.goldPrimary)),
          ),
        ],
      ),
    );
  }

  // Métodos de análisis
  void _showTradingSignals() {
    _logger.info('Showing trading signals for $_selectedSymbol');
    // TODO: Implementar ventana de señales de trading
  }

  void _showPricePatterns() {
    _logger.info('Showing price patterns for $_selectedSymbol');
    // TODO: Implementar análisis de patrones
  }

  void _showVolumeAnalysis() {
    _logger.info('Showing volume analysis for $_selectedSymbol');
    // TODO: Implementar análisis de volumen
  }

  void _showSupportResistance() {
    _logger.info('Showing support/resistance for $_selectedSymbol');
    // TODO: Implementar análisis de soporte y resistencia
  }

  @override
  void dispose() {
    _menuController.dispose();
    _priceUpdateController.dispose();
    super.dispose();
  }
}
