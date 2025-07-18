// Widget de análisis de IA para el dashboard de trading
// Archivo: lib/features/ai_analysis/ai_analysis_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/enhanced_trading_ai_service.dart';
import '../../models/candle.dart';
import '../../models/technical_indicator.dart';
import '../../ui/theme/app_colors.dart';
import '../../utils/logger.dart';

/// Widget de análisis de IA mejorado
class AIAnalysisWidget extends StatefulWidget {
  final String symbol;
  final List<Candle> candles;
  final List<TechnicalIndicator> indicators;
  final double currentPrice;
  final String timeframe;

  const AIAnalysisWidget({
    Key? key,
    required this.symbol,
    required this.candles,
    required this.indicators,
    required this.currentPrice,
    this.timeframe = '1h',
  }) : super(key: key);

  @override
  State<AIAnalysisWidget> createState() => _AIAnalysisWidgetState();
}

class _AIAnalysisWidgetState extends State<AIAnalysisWidget>
    with SingleTickerProviderStateMixin {
  final AppLogger _logger = AppLogger();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  TradingAIAnalysis? _currentAnalysis;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EnhancedTradingAIService>(
      builder: (context, aiService, child) {
        return Container(
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.backgroundSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldPrimary.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(aiService),
              if (_isExpanded) _buildAnalysisContent(aiService),
            ],
          ),
        );
      },
    );
  }

  /// Header del widget con botón de análisis
  Widget _buildHeader(EnhancedTradingAIService aiService) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Icono de IA con animación
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: aiService.isAnalyzing ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: AppColors.goldPrimary,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          SizedBox(width: 12),

          // Título y estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Análisis IA',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getStatusText(aiService),
                  style: TextStyle(
                    color: _getStatusColor(aiService),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Botón de análisis
          _buildAnalyzeButton(aiService),

          SizedBox(width: 8),

          // Botón expandir/contraer
          IconButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Botón de análisis
  Widget _buildAnalyzeButton(EnhancedTradingAIService aiService) {
    return ElevatedButton.icon(
      onPressed: aiService.isAnalyzing ? null : () => _performAnalysis(aiService),
      icon: aiService.isAnalyzing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(Icons.analytics, size: 16),
      label: Text(aiService.isAnalyzing ? 'Analizando...' : 'Analizar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.goldPrimary,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Contenido del análisis expandido
  Widget _buildAnalysisContent(EnhancedTradingAIService aiService) {
    if (_currentAnalysis == null && !aiService.isAnalyzing) {
      return _buildEmptyState();
    }

    if (aiService.isAnalyzing) {
      return _buildLoadingState();
    }

    return _buildAnalysisResults();
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8),
          Text(
            'Presiona "Analizar" para obtener\nrecomendaciones de IA',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de carga
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
          ),
          SizedBox(height: 16),
          Text(
            'Analizando ${widget.symbol} con IA...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Modelo: Llama 3.3 70B Versatile',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Resultados del análisis
  Widget _buildAnalysisResults() {
    if (_currentAnalysis == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recomendación principal
          _buildRecommendationCard(),
          
          SizedBox(height: 12),
          
          // Factores clave
          _buildKeyFactors(),
          
          SizedBox(height: 12),
          
          // Niveles de precio
          _buildPriceLevels(),
          
          SizedBox(height: 12),
          
          // Razonamiento
          _buildReasoning(),
        ],
      ),
    );
  }

  /// Tarjeta de recomendación principal
  Widget _buildRecommendationCard() {
    if (_currentAnalysis == null) return SizedBox.shrink();

    final recommendation = _currentAnalysis!.recommendation;
    final confidence = _currentAnalysis!.confidence;
    
    Color recommendationColor = _getRecommendationColor(recommendation);
    IconData recommendationIcon = _getRecommendationIcon(recommendation);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: recommendationColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: recommendationColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            recommendationIcon,
            color: recommendationColor,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.replaceAll('_', ' '),
                  style: TextStyle(
                    color: recommendationColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Confianza: ${confidence.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Medidor de confianza
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              value: confidence / 100,
              backgroundColor: AppColors.textSecondary.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(recommendationColor),
              strokeWidth: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Factores clave
  Widget _buildKeyFactors() {
    if (_currentAnalysis?.keyFactors.isEmpty ?? true) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Factores Clave:',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...(_currentAnalysis!.keyFactors.map((factor) => Container(
          margin: EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: AppColors.goldPrimary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  factor,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ))),
      ],
    );
  }

  /// Niveles de precio
  Widget _buildPriceLevels() {
    if (_currentAnalysis == null) return SizedBox.shrink();

    return Row(
      children: [
        if (_currentAnalysis!.entryPrice != null)
          _buildPriceLevel('Objetivo', _currentAnalysis!.entryPrice!, AppColors.goldPrimary),
        
        if (_currentAnalysis!.stopLoss != null) ...[
          SizedBox(width: 8),
          _buildPriceLevel('Stop Loss', _currentAnalysis!.stopLoss!, AppColors.bearishRed),
        ],
        
        if (_currentAnalysis!.takeProfit != null) ...[
          SizedBox(width: 8),
          _buildPriceLevel('Take Profit', _currentAnalysis!.takeProfit!, AppColors.bullishGreen),
        ],
      ],
    );
  }

  /// Widget de nivel de precio individual
  Widget _buildPriceLevel(String label, double price, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Razonamiento del análisis
  Widget _buildReasoning() {
    if (_currentAnalysis?.reasoning.isEmpty ?? true) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análisis Detallado:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _currentAnalysis!.reasoning,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Realizar análisis con IA
  Future<void> _performAnalysis(EnhancedTradingAIService aiService) async {
    try {
      _logger.info('🧠 Iniciando análisis de IA para ${widget.symbol}');
      
      final analysis = await aiService.analyzeTradingOpportunity(
        symbol: widget.symbol,
        candles: widget.candles,
        indicators: widget.indicators,
        currentPrice: widget.currentPrice,
        timeframe: widget.timeframe,
      );

      if (analysis != null) {
        setState(() {
          _currentAnalysis = analysis;
          _isExpanded = true; // Auto-expandir cuando hay resultados
        });
        _logger.info('✅ Análisis de IA completado: ${analysis.recommendation}');
      }
    } catch (e) {
      _logger.error('❌ Error en análisis de IA: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en análisis de IA: $e'),
          backgroundColor: AppColors.bearishRed,
        ),
      );
    }
  }

  /// Obtener texto de estado
  String _getStatusText(EnhancedTradingAIService aiService) {
    if (!aiService.isAvailable) {
      return 'No configurado';
    } else if (aiService.isAnalyzing) {
      return 'Analizando...';
    } else if (_currentAnalysis != null) {
      return 'Actualizado hace ${_getTimeAgo(_currentAnalysis!.timestamp)}';
    }
    return 'Listo para analizar';
  }

  /// Obtener color de estado
  Color _getStatusColor(EnhancedTradingAIService aiService) {
    if (!aiService.isAvailable) {
      return AppColors.bearishRed;
    } else if (aiService.isAnalyzing) {
      return AppColors.goldPrimary;
    } else if (_currentAnalysis != null) {
      return AppColors.bullishGreen;
    }
    return AppColors.textSecondary;
  }

  /// Obtener color de recomendación
  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case 'STRONG_BUY':
      case 'BUY':
        return AppColors.bullishGreen;
      case 'STRONG_SELL':
      case 'SELL':
        return AppColors.bearishRed;
      default:
        return AppColors.goldPrimary;
    }
  }

  /// Obtener icono de recomendación
  IconData _getRecommendationIcon(String recommendation) {
    switch (recommendation) {
      case 'STRONG_BUY':
        return Icons.trending_up;
      case 'BUY':
        return Icons.arrow_upward;
      case 'STRONG_SELL':
        return Icons.trending_down;
      case 'SELL':
        return Icons.arrow_downward;
      default:
        return Icons.pause;
    }
  }

  /// Obtener tiempo transcurrido
  String _getTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'ahora';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}min';
    } else {
      return '${diff.inHours}h';
    }
  }
}
