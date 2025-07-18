import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 🤖 Analizador de IA de QUANTIX AI CORE
/// Análisis automatizado con Groq AI y diagnósticos de estrategias
class QuantixAIAnalyzer extends StatefulWidget {
  const QuantixAIAnalyzer({super.key});

  @override
  State<QuantixAIAnalyzer> createState() => _QuantixAIAnalyzerState();
}

class _QuantixAIAnalyzerState extends State<QuantixAIAnalyzer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isAnalyzing = false;
  bool _hasAnalysis = true; // En producción, esto vendría del estado del análisis
  
  // Datos simulados del análisis de IA
  final Map<String, dynamic> _currentAnalysis = {
    'confidence': 87.5,
    'recommendation': 'STRONG BUY',
    'timeframe': '4H - 1D',
    'strategies': [
      {
        'name': 'Trend Following',
        'confidence': 92.3,
        'signal': 'BUY',
        'reason': 'Ruptura alcista confirmada con volumen alto'
      },
      {
        'name': 'Mean Reversion',
        'confidence': 78.1,
        'signal': 'HOLD',
        'reason': 'RSI en zona neutral, esperando retroceso'
      },
      {
        'name': 'Momentum',
        'confidence': 94.7,
        'signal': 'STRONG_BUY',
        'reason': 'MACD cruzó al alza con divergencia bullish'
      },
      {
        'name': 'Volume Analysis',
        'confidence': 89.2,
        'signal': 'BUY',
        'reason': 'Volumen institucional detectado'
      },
    ],
    'keyPoints': [
      'Soporte fuerte en \$41,200',
      'Resistencia clave en \$44,800',
      'Volumen 40% superior al promedio',
      'Correlación Bitcoin dominante',
    ],
    'riskLevel': 'MEDIUM',
    'timestamp': DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: QuantixTheme.aiCardDecoration,
      child: Column(
        children: [
          // Header con IA
          _buildAIHeader(),
          
          if (_hasAnalysis) ...[
            // Análisis principal
            _buildMainAnalysis(),
            
            // Estrategias
            _buildStrategiesAnalysis(),
            
            // Puntos clave
            _buildKeyPoints(),
            
            // Controles
            _buildControls(),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  /// Header del analizador de IA
  Widget _buildAIHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Ícono de IA animado
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: QuantixTheme.primaryBlack.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: QuantixTheme.primaryBlack,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Título y estado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUANTIX AI Analyzer',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isAnalyzing ? 'Analizando mercado...' : 'Análisis completado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: QuantixTheme.primaryBlack.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de estado
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isAnalyzing 
                  ? QuantixTheme.hold 
                  : QuantixTheme.strongBuy,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Análisis principal
  Widget _buildMainAnalysis() {
    final confidence = _currentAnalysis['confidence'] as double;
    final recommendation = _currentAnalysis['recommendation'] as String;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Nivel de confianza
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nivel de Confianza',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: QuantixTheme.primaryBlack,
                ),
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: QuantixTheme.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Barra de confianza
          LinearProgressIndicator(
            value: confidence / 100,
            backgroundColor: QuantixTheme.primaryBlack.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              confidence > 80 
                  ? QuantixTheme.strongBuy
                  : confidence > 60 
                      ? QuantixTheme.buy 
                      : QuantixTheme.hold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recomendación principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getRecommendationColor(recommendation),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'RECOMENDACIÓN',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentAnalysis['timeframe'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: QuantixTheme.primaryBlack.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Análisis de estrategias
  Widget _buildStrategiesAnalysis() {
    final strategies = _currentAnalysis['strategies'] as List<Map<String, dynamic>>;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnóstico por Estrategia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: QuantixTheme.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ...strategies.map((strategy) => _buildStrategyCard(strategy)),
        ],
      ),
    );
  }

  /// Card de estrategia individual
  Widget _buildStrategyCard(Map<String, dynamic> strategy) {
    final confidence = strategy['confidence'] as double;
    final signal = strategy['signal'] as String;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getSignalColor(signal).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la estrategia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strategy['name'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: QuantixTheme.primaryBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSignalColor(signal),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      signal.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: QuantixTheme.primaryBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${confidence.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: QuantixTheme.primaryBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Razón de la señal
          Text(
            strategy['reason'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: QuantixTheme.primaryBlack.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Puntos clave del análisis
  Widget _buildKeyPoints() {
    final keyPoints = _currentAnalysis['keyPoints'] as List<String>;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuantixTheme.primaryBlack.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Puntos Clave',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: QuantixTheme.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          ...keyPoints.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: const BoxDecoration(
                    color: QuantixTheme.primaryBlack,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: QuantixTheme.primaryBlack.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Controles del analizador
  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Botón de re-análisis
          Expanded(
            child: TextButton.icon(
              onPressed: _isAnalyzing ? null : _triggerAnalysis,
              icon: _isAnalyzing 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isAnalyzing ? 'Analizando...' : 'Re-analizar'),
              style: TextButton.styleFrom(
                backgroundColor: QuantixTheme.primaryBlack.withOpacity(0.1),
                foregroundColor: QuantixTheme.primaryBlack,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Botón de configuración
          TextButton(
            onPressed: () {
              // TODO: Abrir configuración de IA
            },
            style: TextButton.styleFrom(
              backgroundColor: QuantixTheme.primaryBlack.withOpacity(0.1),
              foregroundColor: QuantixTheme.primaryBlack,
              padding: const EdgeInsets.all(12),
            ),
            child: const Icon(Icons.tune),
          ),
        ],
      ),
    );
  }

  /// Estado vacío
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: QuantixTheme.primaryBlack.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Listo para Analizar',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: QuantixTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón para iniciar el análisis inteligente del mercado',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: QuantixTheme.primaryBlack.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _triggerAnalysis,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('INICIAR ANÁLISIS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: QuantixTheme.primaryBlack,
              foregroundColor: QuantixTheme.electricBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Activar análisis
  void _triggerAnalysis() {
    setState(() => _isAnalyzing = true);
    
    // Simular análisis de IA (en producción sería llamada real a Groq)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasAnalysis = true;
        });
      }
    });
  }

  /// Obtener color de recomendación
  Color _getRecommendationColor(String recommendation) {
    switch (recommendation.toLowerCase()) {
      case 'strong buy':
        return QuantixTheme.strongBuy;
      case 'buy':
        return QuantixTheme.buy;
      case 'hold':
        return QuantixTheme.hold;
      case 'sell':
        return QuantixTheme.sell;
      case 'strong sell':
        return QuantixTheme.strongSell;
      default:
        return QuantixTheme.neutralGray;
    }
  }

  /// Obtener color de señal
  Color _getSignalColor(String signal) {
    switch (signal.toLowerCase()) {
      case 'strong_buy':
        return QuantixTheme.strongBuy;
      case 'buy':
        return QuantixTheme.buy;
      case 'hold':
        return QuantixTheme.hold;
      case 'sell':
        return QuantixTheme.sell;
      case 'strong_sell':
        return QuantixTheme.strongSell;
      default:
        return QuantixTheme.neutralGray;
    }
  }
}
