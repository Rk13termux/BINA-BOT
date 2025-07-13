import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';
import '../../utils/logger.dart';
import 'base_strategy.dart';

/// Estrategia de Scalping Profesional
class ScalpingBotStrategy extends BaseStrategy {
  final AppLogger _logger = AppLogger();
  StrategyStatus _status = StrategyStatus.idle;
  Map<String, dynamic> _configuration = {};
  bool _useAI = false;

  @override
  String get name => 'Scalping Bot Pro';

  @override
  String get description => 'Estrategia de scalping de alta frecuencia para ganancias rápidas en movimientos pequeños del mercado';

  @override
  IconData get icon => Icons.speed;

  @override
  Color get color => AppColors.bullish;

  @override
  StrategyType get type => StrategyType.scalping;

  @override
  bool get supportsAI => true;

  @override
  Map<String, StrategyParameter> get parameters => {
    'timeframe': const StrategyParameter(
      name: 'Timeframe',
      description: 'Intervalo de tiempo para análisis',
      type: ParameterType.dropdown,
      defaultValue: '1m',
      options: ['1m', '3m', '5m', '15m'],
    ),
    'profit_target': const StrategyParameter(
      name: 'Objetivo de Ganancia',
      description: 'Porcentaje de ganancia objetivo por operación',
      type: ParameterType.percentage,
      defaultValue: 0.5,
      minValue: 0.1,
      maxValue: 2.0,
    ),
    'stop_loss': const StrategyParameter(
      name: 'Stop Loss',
      description: 'Porcentaje de pérdida máxima por operación',
      type: ParameterType.percentage,
      defaultValue: 0.3,
      minValue: 0.1,
      maxValue: 1.0,
    ),
    'position_size': const StrategyParameter(
      name: 'Tamaño de Posición',
      description: 'Porcentaje del capital a usar por operación',
      type: ParameterType.percentage,
      defaultValue: 10.0,
      minValue: 1.0,
      maxValue: 50.0,
    ),
    'max_positions': const StrategyParameter(
      name: 'Máximo de Posiciones',
      description: 'Número máximo de posiciones simultáneas',
      type: ParameterType.number,
      defaultValue: 3,
      minValue: 1,
      maxValue: 10,
    ),
    'rsi_oversold': const StrategyParameter(
      name: 'RSI Sobreventa',
      description: 'Nivel de RSI para considerar sobreventa',
      type: ParameterType.number,
      defaultValue: 30,
      minValue: 20,
      maxValue: 40,
    ),
    'rsi_overbought': const StrategyParameter(
      name: 'RSI Sobrecompra',
      description: 'Nivel de RSI para considerar sobrecompra',
      type: ParameterType.number,
      defaultValue: 70,
      minValue: 60,
      maxValue: 80,
    ),
  };

  @override
  Widget buildConfigurationWidget(BuildContext context, Function(Map<String, dynamic>) onConfigurationChanged) {
    return ScalpingConfigurationWidget(
      parameters: parameters,
      onConfigurationChanged: onConfigurationChanged,
    );
  }

  @override
  Widget buildDashboardWidget(BuildContext context, Map<String, dynamic> configuration) {
    return ScalpingDashboardWidget(
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
      
      _logger.info('Scalping Strategy initialized with AI: $useAI');
      _status = StrategyStatus.idle;
    } catch (e) {
      _logger.error('Failed to initialize Scalping Strategy: $e');
      _status = StrategyStatus.error;
      rethrow;
    }
  }

  @override
  Future<void> execute() async {
    try {
      _status = StrategyStatus.running;
      _logger.info('Scalping Strategy execution started');
      
      // Aquí iría la lógica de ejecución del scalping
      // Conectar con Binance WebSocket para datos en tiempo real
      // Aplicar indicadores técnicos
      // Ejecutar órdenes de compra/venta
      
    } catch (e) {
      _logger.error('Scalping Strategy execution failed: $e');
      _status = StrategyStatus.error;
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      _status = StrategyStatus.stopped;
      _logger.info('Scalping Strategy stopped');
    } catch (e) {
      _logger.error('Failed to stop Scalping Strategy: $e');
      rethrow;
    }
  }

  @override
  bool validateConfiguration(Map<String, dynamic> configuration) {
    // Validar que todos los parámetros requeridos estén presentes
    for (final param in parameters.values) {
      if (param.required && !configuration.containsKey(param.name)) {
        return false;
      }
    }
    return true;
  }

  StrategyStatus get status => _status;
}

/// Widget de configuración para Scalping
class ScalpingConfigurationWidget extends StatefulWidget {
  final Map<String, StrategyParameter> parameters;
  final Function(Map<String, dynamic>) onConfigurationChanged;

  const ScalpingConfigurationWidget({
    super.key,
    required this.parameters,
    required this.onConfigurationChanged,
  });

  @override
  State<ScalpingConfigurationWidget> createState() => _ScalpingConfigurationWidgetState();
}

class _ScalpingConfigurationWidgetState extends State<ScalpingConfigurationWidget> {
  final Map<String, dynamic> _configuration = {};

  @override
  void initState() {
    super.initState();
    // Inicializar con valores por defecto
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
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Scalping',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.parameters.entries.map((entry) => _buildParameterWidget(entry.key, entry.value)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onConfigurationChanged(_configuration),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: Colors.black,
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
              borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
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
              borderSide: BorderSide(color: AppColors.goldPrimary.withOpacity(0.3)),
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

/// Widget del dashboard para Scalping
class ScalpingDashboardWidget extends StatelessWidget {
  final ScalpingBotStrategy strategy;
  final Map<String, dynamic> configuration;

  const ScalpingDashboardWidget({
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
          // Header con estado
          _buildStatusHeader(),
          const SizedBox(height: 20),
          
          // Métricas principales
          _buildMetricsGrid(),
          const SizedBox(height: 20),
          
          // Gráfico de rendimiento
          _buildPerformanceChart(),
          const SizedBox(height: 20),
          
          // Órdenes activas
          _buildActiveOrders(),
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
        border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            strategy.icon,
            color: strategy.color,
            size: 24,
          ),
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
          _buildControlButtons(),
        ],
      ),
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
        _buildMetricCard('Ganancia Total', '+\$1,247.89', AppColors.bullish),
        _buildMetricCard('Trades Exitosos', '23/30', AppColors.goldPrimary),
        _buildMetricCard('Ratio de Éxito', '76.7%', AppColors.bullish),
        _buildMetricCard('Tiempo Activo', '4h 32m', AppColors.info),
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

  Widget _buildPerformanceChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'Gráfico de Rendimiento\n(Implementar con fl_chart)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Órdenes Activas',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No hay órdenes activas',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: strategy.status == StrategyStatus.running 
              ? () => strategy.stop()
              : () => strategy.execute(),
          icon: Icon(
            strategy.status == StrategyStatus.running 
                ? Icons.stop 
                : Icons.play_arrow,
            color: strategy.status == StrategyStatus.running 
                ? AppColors.bearish 
                : AppColors.bullish,
          ),
        ),
        IconButton(
          onPressed: () {
            // Pausar/reanudar estrategia
          },
          icon: Icon(
            Icons.pause,
            color: AppColors.goldPrimary,
          ),
        ),
      ],
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
