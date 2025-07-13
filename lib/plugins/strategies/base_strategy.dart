import 'package:flutter/material.dart';

/// Clase base abstracta para todas las estrategias de trading
abstract class BaseStrategy {
  /// Nombre de la estrategia
  String get name;
  
  /// Descripción de la estrategia
  String get description;
  
  /// Ícono representativo
  IconData get icon;
  
  /// Color de la estrategia
  Color get color;
  
  /// Tipo de estrategia (Scalping, Swing, Grid, etc.)
  StrategyType get type;
  
  /// Si la estrategia soporta IA
  bool get supportsAI;
  
  /// Parámetros configurables de la estrategia
  Map<String, StrategyParameter> get parameters;
  
  /// Widget de configuración de la estrategia
  Widget buildConfigurationWidget(BuildContext context, Function(Map<String, dynamic>) onConfigurationChanged);
  
  /// Widget del dashboard de la estrategia
  Widget buildDashboardWidget(BuildContext context, Map<String, dynamic> configuration);
  
  /// Inicializar la estrategia con la configuración
  Future<void> initialize(Map<String, dynamic> configuration, bool useAI);
  
  /// Ejecutar la estrategia
  Future<void> execute();
  
  /// Detener la estrategia
  Future<void> stop();
  
  /// Validar configuración
  bool validateConfiguration(Map<String, dynamic> configuration);
}

/// Tipos de estrategias disponibles
enum StrategyType {
  scalping,
  swing,
  grid,
  arbitrage,
  sentiment,
  quantitative,
  liquidity,
  momentum
}

/// Parámetro configurable de una estrategia
class StrategyParameter {
  final String name;
  final String description;
  final ParameterType type;
  final dynamic defaultValue;
  final dynamic minValue;
  final dynamic maxValue;
  final List<dynamic>? options;
  final bool required;

  const StrategyParameter({
    required this.name,
    required this.description,
    required this.type,
    required this.defaultValue,
    this.minValue,
    this.maxValue,
    this.options,
    this.required = true,
  });
}

/// Tipos de parámetros
enum ParameterType {
  number,
  percentage,
  boolean,
  text,
  dropdown,
  range,
  duration
}

/// Estado de una estrategia
enum StrategyStatus {
  idle,
  configuring,
  running,
  paused,
  stopped,
  error
}

/// Resultado de ejecución de estrategia
class StrategyResult {
  final String strategyName;
  final DateTime timestamp;
  final double profit;
  final double loss;
  final int totalTrades;
  final int successfulTrades;
  final Map<String, dynamic> metrics;

  const StrategyResult({
    required this.strategyName,
    required this.timestamp,
    required this.profit,
    required this.loss,
    required this.totalTrades,
    required this.successfulTrades,
    required this.metrics,
  });

  double get successRate => totalTrades > 0 ? (successfulTrades / totalTrades) * 100 : 0;
  double get netProfit => profit - loss;
}
