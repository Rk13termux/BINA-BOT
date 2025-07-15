import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../services/advanced_ai_service.dart';
import '../../../services/technical_indicator_service.dart';
import '../../../models/ai_analysis.dart';
import '../../../models/technical_indicator.dart';
import '../../../models/candle.dart';
import '../../../ui/theme/app_colors.dart';
import '../../../ui/widgets/orbital_widget.dart';
import '../../../utils/logger.dart';

class UltraProfessionalDashboard extends StatefulWidget {
  const UltraProfessionalDashboard({Key? key}) : super(key: key);

  @override
  State<UltraProfessionalDashboard> createState() => _UltraProfessionalDashboardState();
}

class _UltraProfessionalDashboardState extends State<UltraProfessionalDashboard>
    with TickerProviderStateMixin {
  final AppLogger _logger = AppLogger();

  // Controladores de animación
  late AnimationController _orbitalController;
  late AnimationController _pulseController;
  late AnimationController _gridController;

  // Estado del dashboard
  String _selectedSymbol = 'BTCUSDT';
  bool _isApiKeyConfigured = false;
  bool _showOnboarding = true;
  List<TechnicalIndicator> _indicators = [];
  List<Candle> _candles = [];
  double _currentPrice = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDashboard();
  }

  void _initializeAnimations() {
    _orbitalController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _gridController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();
  }

  Future<void> _initializeDashboard() async {
    try {
      // Verificar configuración de API
      _checkApiConfiguration();
      
      // Inicializar indicadores técnicos
      await _initializeTechnicalIndicators();
      
      // Comenzar monitoreo en tiempo real
      _startRealTimeUpdates();
      
    } catch (e) {
      _logger.error('Error inicializando dashboard: $e');
    }
  }

  void _checkApiConfiguration() {
    // TODO: Verificar si las API keys están configuradas
    setState(() {
      _isApiKeyConfigured = true; // Temporal
      _showOnboarding = !_isApiKeyConfigured;
    });
  }

  Future<void> _initializeTechnicalIndicators() async {
    // Configurar indicadores predeterminados
    final indicators = IndicatorFactory.createDefaultIndicators();
    
    // Habilitar indicadores clave para el dashboard
    for (final indicator in indicators) {
      if (['ema_21', 'rsi', 'macd', 'atr', 'obv'].contains(indicator.id)) {
        indicator.isEnabled = true;
      }
    }
    
    setState(() {
      _indicators = indicators;
    });
  }

  void _startRealTimeUpdates() {
    // TODO: Implementar actualizaciones en tiempo real cada 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _updateMarketData();
        _startRealTimeUpdates();
      }
    });
  }

  Future<void> _updateMarketData() async {
    try {
      // TODO: Obtener datos reales del WebSocket
      setState(() {
        _currentPrice = 50000 + (math.Random().nextDouble() - 0.5) * 1000;
      });
      
      // Actualizar indicadores técnicos
      final indicatorService = context.read<TechnicalIndicatorService>();
      indicatorService.calculateIndicators(_candles, _selectedSymbol);
      
      setState(() {
        _indicators = indicatorService.enabledIndicators;
      });
      
    } catch (e) {
      _logger.error('Error actualizando datos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return _buildOnboardingFlow();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Negro puro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Negro puro
              Color(0xFF0A0A0A), // Negro muy oscuro
            ],
          ),
        ),
        child: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildUserStatusSection(),
                  const SizedBox(height: 20),
                  _buildOrbitalIndicatorsSection(),
                  const SizedBox(height: 20),
                  _buildAIAnalysisSection(),
                  const SizedBox(height: 20),
                  _buildTechnicalIndicatorsGrid(),
                  const SizedBox(height: 20),
                  _buildMarketOverviewSection(),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOnboardingFlow() {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Negro puro
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Negro puro
              Color(0xFF0A0A0A), // Negro muy oscuro
            ],
          ),
        ),
        child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo y bienvenida
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.goldPrimary, AppColors.goldPrimary.withOpacity(0.3)],
                  ),
                ),
                child: const Icon(
                  Icons.auto_graph,
                  size: 60,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                '¡Bienvenido a Invictus Trader Pro!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.goldPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Configure sus API keys para comenzar a operar con análisis profesional en tiempo real.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Botón de configuración
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _showApiConfigDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldPrimary,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.settings),
                  label: const Text(
                    'Configurar API Keys',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón demo
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _startDemoMode,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.goldPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow, color: AppColors.goldPrimary),
                  label: const Text(
                    'Modo Demo',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ), // Cierra Container del gradiente
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              Color(0xFF2A2A2A),
            ],
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/icon.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.goldPrimary, AppColors.goldPrimary.withValues(alpha: 0.6)],
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_graph,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Invictus Trader Pro',
            style: TextStyle(
              color: AppColors.goldPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        _buildPriceDisplay(),
        const SizedBox(width: 8),
        _buildConnectionStatus(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildPriceDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bullishGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bullishGreen.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedSymbol,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '\$${_currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.bullishGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bullishGreen,
            boxShadow: [
              BoxShadow(
                color: AppColors.bullishGreen.withOpacity(0.5 * _pulseController.value),
                blurRadius: 8 * _pulseController.value,
                spreadRadius: 2 * _pulseController.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserStatusSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.goldPrimary.withOpacity(0.1),
            AppColors.goldPrimary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.goldPrimary, Color(0xFFB8860B)],
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primaryDark,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trader Profesional',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Conectado • API Activa • IA Habilitada',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bullishGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                color: AppColors.bullishGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitalIndicatorsSection() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Orbital widgets animados
          AnimatedBuilder(
            animation: _orbitalController,
            builder: (context, child) {
              return OrbitalWidget(
                center: const Offset(0.5, 0.5),
                radius: 0.35,
                angle: _orbitalController.value * 2 * math.pi,
                child: _buildIndicatorOrb('RSI', '67.8', AppColors.bullishGreen),
              );
            },
          ),
          AnimatedBuilder(
            animation: _orbitalController,
            builder: (context, child) {
              return OrbitalWidget(
                center: const Offset(0.5, 0.5),
                radius: 0.3,
                angle: (_orbitalController.value * 2 * math.pi) + (math.pi / 2),
                child: _buildIndicatorOrb('MACD', '0.234', AppColors.goldPrimary),
              );
            },
          ),
          AnimatedBuilder(
            animation: _orbitalController,
            builder: (context, child) {
              return OrbitalWidget(
                center: const Offset(0.5, 0.5),
                radius: 0.25,
                angle: (_orbitalController.value * 2 * math.pi) + math.pi,
                child: _buildIndicatorOrb('ATR', '1.23%', AppColors.bearishRed),
              );
            },
          ),
          
          // Centro del orbital
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldPrimary,
                    AppColors.goldPrimary.withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primaryDark,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorOrb(String name, String value, Color color) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisSection() {
    return Consumer<AdvancedAIService>(
      builder: (context, aiService, child) {
        final analysis = aiService.state.currentAnalysis;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6A1B9A).withOpacity(0.1),
                const Color(0xFF4A148C).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF6A1B9A).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
                      ),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Análisis de IA',
                    style: TextStyle(
                      color: Color(0xFF6A1B9A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (aiService.state.isAnalyzing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (analysis != null) ...[
                _buildAIRecommendationCard(analysis),
              ] else ...[
                _buildStartAnalysisButton(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIRecommendationCard(AIAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildRecommendationBadge(analysis.recommendation),
              const SizedBox(width: 12),
              _buildConfidenceBadge(analysis.confidence),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis.briefSummary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildKeyFactorsList(analysis.keyFactors),
        ],
      ),
    );
  }

  Widget _buildRecommendationBadge(AIRecommendation recommendation) {
    Color color;
    String text;
    
    switch (recommendation) {
      case AIRecommendation.strongBuy:
        color = const Color(0xFF2E7D32);
        text = 'COMPRA FUERTE';
        break;
      case AIRecommendation.buy:
        color = AppColors.bullishGreen;
        text = 'COMPRA';
        break;
      case AIRecommendation.sell:
        color = AppColors.bearishRed;
        text = 'VENTA';
        break;
      case AIRecommendation.strongSell:
        color = const Color(0xFFC62828);
        text = 'VENTA FUERTE';
        break;
      default:
        color = AppColors.goldPrimary;
        text = 'MANTENER';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(ConfidenceLevel confidence) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < confidence.value;
        return Icon(
          Icons.star,
          size: 16,
          color: filled ? AppColors.goldPrimary : Colors.grey.shade600,
        );
      }),
    );
  }

  Widget _buildKeyFactorsList(List<String> factors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: factors.take(3).map((factor) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Icon(
                Icons.fiber_manual_record,
                size: 8,
                color: AppColors.goldPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  factor,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStartAnalysisButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _startAIAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          'Iniciar Análisis Estratégico',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalIndicatorsGrid() {
    final enabledIndicators = _indicators.where((i) => i.isEnabled).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Indicadores Técnicos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: enabledIndicators.length,
          itemBuilder: (context, index) {
            final indicator = enabledIndicators[index];
            return _buildIndicatorCard(indicator);
          },
        ),
      ],
    );
  }

  Widget _buildIndicatorCard(TechnicalIndicator indicator) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: indicator.category.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: indicator.category.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indicator.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            indicator.value.toStringAsFixed(4),
            style: TextStyle(
              color: indicator.category.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                indicator.trend == TrendDirection.bullish
                    ? Icons.trending_up
                    : indicator.trend == TrendDirection.bearish
                        ? Icons.trending_down
                        : Icons.trending_flat,
                size: 16,
                color: indicator.trend == TrendDirection.bullish
                    ? AppColors.bullishGreen
                    : indicator.trend == TrendDirection.bearish
                        ? AppColors.bearishRed
                        : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${indicator.percentageChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: indicator.percentageChange >= 0
                      ? AppColors.bullishGreen
                      : AppColors.bearishRed,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del Mercado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMarketSummaryRow('Volatilidad', '3.2%', AppColors.goldPrimary),
          _buildMarketSummaryRow('Momentum', '+1.8%', AppColors.bullishGreen),
          _buildMarketSummaryRow('Volumen 24h', '\$2.1B', Colors.white70),
          _buildMarketSummaryRow('Tendencia General', 'Alcista', AppColors.bullishGreen),
        ],
      ),
    );
  }

  Widget _buildMarketSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showApiConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => const ApiConfigurationDialog(),
    );
  }

  void _startDemoMode() {
    setState(() {
      _showOnboarding = false;
      _isApiKeyConfigured = true;
    });
  }

  Future<void> _startAIAnalysis() async {
    final aiService = context.read<AdvancedAIService>();
    await aiService.performStrategicAnalysis(
      symbol: _selectedSymbol,
      indicators: _indicators.where((i) => i.isEnabled).toList(),
      candles: _candles,
      currentPrice: _currentPrice,
    );
  }

  @override
  void dispose() {
    _orbitalController.dispose();
    _pulseController.dispose();
    _gridController.dispose();
    super.dispose();
  }
}

// Widget auxiliar para configuración de API
class ApiConfigurationDialog extends StatefulWidget {
  const ApiConfigurationDialog({Key? key}) : super(key: key);

  @override
  State<ApiConfigurationDialog> createState() => _ApiConfigurationDialogState();
}

class _ApiConfigurationDialogState extends State<ApiConfigurationDialog> {
  final _binanceApiController = TextEditingController();
  final _binanceSecretController = TextEditingController();
  final _groqApiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.primaryDark,
      title: const Text(
        'Configuración de API Keys',
        style: TextStyle(color: AppColors.goldPrimary),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildApiField(
              'Binance API Key',
              _binanceApiController,
              'Ingrese su API Key de Binance',
            ),
            const SizedBox(height: 16),
            _buildApiField(
              'Binance Secret Key',
              _binanceSecretController,
              'Ingrese su Secret Key de Binance',
              isSecret: true,
            ),
            const SizedBox(height: 16),
            _buildApiField(
              'Groq API Key',
              _groqApiController,
              'Ingrese su API Key de Groq AI',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: _saveApiKeys,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldPrimary,
            foregroundColor: AppColors.primaryDark,
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildApiField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isSecret = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isSecret,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.goldPrimary),
            ),
          ),
        ),
      ],
    );
  }

  void _saveApiKeys() {
    // TODO: Guardar API keys de forma segura
    Navigator.of(context).pop();
  }
}
