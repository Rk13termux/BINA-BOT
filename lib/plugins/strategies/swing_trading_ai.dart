import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';
import '../../utils/logger.dart';
import 'base_strategy.dart';

/// Estrategia de Swing Trading con IA
class SwingTradingAIStrategy extends BaseStrategy {
  final AppLogger _logger = AppLogger();
  StrategyStatus _status = StrategyStatus.idle;
  Map<String, dynamic> _configuration = {};
  bool _useAI = false;

  @override
  String get name => 'Swing Trading AI';

  @override
  String get description => 'Estrategia de swing trading potenciada con IA para capturar movimientos de mediano plazo';

  @override
  IconData get icon => Icons.timeline;

  @override
  Color get color => AppColors.info;

  @override
  StrategyType get type => StrategyType.swing;

  @override
  bool get supportsAI => true;

  @override
  Map<String, StrategyParameter> get parameters => {
    'holding_period': const StrategyParameter(
      name: 'Período de Retención',
      description: 'Tiempo mínimo para mantener una posición',
      type: ParameterType.dropdown,
      defaultValue: '4h',
      options: ['1h', '4h', '1d', '3d', '1w'],
    ),
    'profit_target': const StrategyParameter(
      name: 'Objetivo de Ganancia',
      description: 'Porcentaje de ganancia objetivo por operación',
      type: ParameterType.percentage,
      defaultValue: 5.0,
      minValue: 2.0,
      maxValue: 20.0,
    ),
    'stop_loss': const StrategyParameter(
      name: 'Stop Loss',
      description: 'Porcentaje de pérdida máxima por operación',
      type: ParameterType.percentage,
      defaultValue: 3.0,
      minValue: 1.0,
      maxValue: 10.0,
    ),
    'position_size': const StrategyParameter(
      name: 'Tamaño de Posición',
      description: 'Porcentaje del capital a usar por operación',
      type: ParameterType.percentage,
      defaultValue: 25.0,
      minValue: 5.0,
      maxValue: 50.0,
    ),
    'ai_confidence': const StrategyParameter(
      name: 'Confianza de IA Mínima',
      description: 'Nivel mínimo de confianza de IA para ejecutar trade',
      type: ParameterType.percentage,
      defaultValue: 75.0,
      minValue: 50.0,
      maxValue: 95.0,
    ),
    'trend_strength': const StrategyParameter(
      name: 'Fuerza de Tendencia',
      description: 'Fuerza mínima de tendencia para operar',
      type: ParameterType.dropdown,
      defaultValue: 'Medium',
      options: ['Low', 'Medium', 'High', 'Very High'],
    ),
  };

  @override
  Widget buildConfigurationWidget(BuildContext context, Function(Map<String, dynamic>) onConfigurationChanged) {
    return SwingTradingConfigurationWidget(
      parameters: parameters,
      onConfigurationChanged: onConfigurationChanged,
    );
  }

  @override
  Widget buildDashboardWidget(BuildContext context, Map<String, dynamic> configuration) {
    return SwingTradingDashboardWidget(
      strategy: this,
      configuration: configuration,
    );
  }

  @override
  Future<void> initialize(Map<String, dynamic> configuration, bool useAI) async {
    try {
      _configuration = configuration;
      _useAI = useAI;
      _status = StrategyStatus.configuring;
      
      _logger.info('Swing Trading AI Strategy initialized with AI: $useAI');
      _status = StrategyStatus.idle;
    } catch (e) {
      _logger.error('Failed to initialize Swing Trading AI Strategy: $e');
      _status = StrategyStatus.error;
      rethrow;
    }
  }

  @override
  Future<void> execute() async {
    try {
      _status = StrategyStatus.running;
      _logger.info('Swing Trading AI Strategy execution started');
      
      // Lógica de swing trading con IA
      
    } catch (e) {
      _logger.error('Swing Trading AI Strategy execution failed: $e');
      _status = StrategyStatus.error;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      _status = StrategyStatus.stopped;
      _logger.info('Swing Trading AI Strategy stopped');
    } catch (e) {
      _logger.error('Failed to stop Swing Trading AI Strategy: $e');
      rethrow;
    }
  }

  @override
  bool validateConfiguration(Map<String, dynamic> configuration) {
    for (final param in parameters.values) {
      if (param.required && !configuration.containsKey(param.name)) {
        return false;
      }
    }
    return true;
  }

  StrategyStatus get status => _status;
}

/// Widget de configuración para Swing Trading AI
class SwingTradingConfigurationWidget extends StatefulWidget {
  final Map<String, StrategyParameter> parameters;
  final Function(Map<String, dynamic>) onConfigurationChanged;

  const SwingTradingConfigurationWidget({
    super.key,
    required this.parameters,
    required this.onConfigurationChanged,
  });

  @override
  State<SwingTradingConfigurationWidget> createState() => _SwingTradingConfigurationWidgetState();
}

class _SwingTradingConfigurationWidgetState extends State<SwingTradingConfigurationWidget> {
  final Map<String, dynamic> _configuration = {};

  @override
  void initState() {
    super.initState();
    for (final entry in widget.parameters.entries) {
      _configuration[entry.key] = entry.value.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: AppColors.info, size: 24),
              const SizedBox(width: 8),
              Text(
                'Configuración de Swing Trading AI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.parameters.entries.map((entry) => _buildParameterWidget(entry.key, entry.value)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfigurationChanged(_configuration),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Aplicar Configuración',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterWidget(String key, StrategyParameter param) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            param.name,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            param.description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          _buildParameterInput(key, param),
        ],
      ),
    );
  }

  Widget _buildParameterInput(String key, StrategyParameter param) {
    switch (param.type) {
      case ParameterType.dropdown:
        return DropdownButtonFormField<String>(
          value: _configuration[key] as String,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.info.withOpacity(0.3)),
            ),
          ),
          dropdownColor: AppColors.surfaceDark,
          style: TextStyle(color: AppColors.textPrimary),
          items: param.options!.map<DropdownMenuItem<String>>((value) {
            return DropdownMenuItem<String>(
              value: value.toString(),
              child: Text(value.toString()),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _configuration[key] = value;
            });
          },
        );
      case ParameterType.percentage:
      case ParameterType.number:
        return TextFormField(
          initialValue: _configuration[key].toString(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.info.withOpacity(0.3)),
            ),
            suffixText: param.type == ParameterType.percentage ? '%' : null,
          ),
          style: TextStyle(color: AppColors.textPrimary),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final numValue = double.tryParse(value);
            if (numValue != null) {
              setState(() {
                _configuration[key] = numValue;
              });
            }
          },
        );
      default:
        return Container();
    }
  }
}

/// Widget del dashboard para Swing Trading AI
class SwingTradingDashboardWidget extends StatelessWidget {
  final SwingTradingAIStrategy strategy;
  final Map<String, dynamic> configuration;

  const SwingTradingDashboardWidget({
    super.key,
    required this.strategy,
    required this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 20),
          _buildAIInsights(),
          const SizedBox(height: 20),
          _buildMetricsGrid(),
          const SizedBox(height: 20),
          _buildTrendAnalysis(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(strategy.icon, color: strategy.color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Estado: ${_getStatusText()}',
                  style: TextStyle(
                    color: _getStatusColor(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.psychology, color: AppColors.info, size: 16),
                const SizedBox(width: 4),
                Text(
                  'AI ACTIVO',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Insights de IA',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightItem('Tendencia del Mercado', 'Alcista', AppColors.bullish, 0.82),
          const SizedBox(height: 8),
          _buildInsightItem('Volatilidad', 'Moderada', AppColors.warning, 0.64),
          const SizedBox(height: 8),
          _buildInsightItem('Momento Óptimo', 'Compra', AppColors.bullish, 0.91),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, Color color, double confidence) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${(confidence * 100).toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildMetricCard('Ganancia Total', '+\$3,247.89', AppColors.bullish),
        _buildMetricCard('Trades Exitosos', '18/22', AppColors.goldPrimary),
        _buildMetricCard('Ratio de Éxito', '81.8%', AppColors.bullish),
        _buildMetricCard('Duración Promedio', '2d 14h', AppColors.info),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Análisis de Tendencia con IA\n(Implementar gráfico interactivo)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (strategy.status) {
      case StrategyStatus.idle:
        return 'Inactivo';
      case StrategyStatus.configuring:
        return 'Configurando';
      case StrategyStatus.running:
        return 'Ejecutando';
      case StrategyStatus.paused:
        return 'Pausado';
      case StrategyStatus.stopped:
        return 'Detenido';
      case StrategyStatus.error:
        return 'Error';
    }
  }

  Color _getStatusColor() {
    switch (strategy.status) {
      case StrategyStatus.idle:
        return AppColors.textSecondary;
      case StrategyStatus.configuring:
        return AppColors.goldPrimary;
      case StrategyStatus.running:
        return AppColors.bullish;
      case StrategyStatus.paused:
        return AppColors.warning;
      case StrategyStatus.stopped:
        return AppColors.neutral;
      case StrategyStatus.error:
        return AppColors.bearish;
    }
  }
}
