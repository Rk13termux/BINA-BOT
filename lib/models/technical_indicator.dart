import 'package:flutter/material.dart';

/// Tipos de categorías de indicadores técnicos
enum IndicatorCategory {
  trend('🔵', 'Tendencia', Color(0xFF2196F3)),
  momentum('🟠', 'Momentum', Color(0xFFFF9800)),
  volume('🟢', 'Volumen', Color(0xFF4CAF50)),
  volatility('🟣', 'Volatilidad', Color(0xFF9C27B0)),
  composite('🔴', 'Compuestos / IA', Color(0xFFE91E63));

  const IndicatorCategory(this.emoji, this.displayName, this.color);
  final String emoji;
  final String displayName;
  final Color color;
}

/// Tipos de tendencia para los indicadores
enum TrendDirection {
  bullish('📈', 'Alcista'),
  bearish('📉', 'Bajista'),
  neutral('➖', 'Neutral');

  const TrendDirection(this.emoji, this.displayName);
  final String emoji;
  final String displayName;
}

/// Modelo para un indicador técnico
class TechnicalIndicator {
  final String id;
  final String name;
  final String description;
  final IndicatorCategory category;
  final double value;
  final double previousValue;
  final TrendDirection trend;
  bool isEnabled;
  final DateTime lastUpdate;
  final List<double> sparklineData;
  final Map<String, dynamic> parameters;

  TechnicalIndicator({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.value,
    required this.previousValue,
    required this.trend,
    this.isEnabled = false,
    required this.lastUpdate,
    this.sparklineData = const [],
    this.parameters = const {},
  });

  /// Calcula el cambio porcentual
  double get percentageChange {
    if (previousValue == 0) return 0;
    return ((value - previousValue) / previousValue) * 100;
  }

  /// Determina si el valor está en zona de sobrecompra
  bool get isOverbought {
    switch (id) {
      case 'rsi':
        return value > 70;
      case 'mfi':
        return value > 80;
      case 'cci':
        return value > 100;
      default:
        return false;
    }
  }

  /// Determina si el valor está en zona de sobreventa
  bool get isOversold {
    switch (id) {
      case 'rsi':
        return value < 30;
      case 'mfi':
        return value < 20;
      case 'cci':
        return value < -100;
      default:
        return false;
    }
  }

  /// Copia el indicador con nuevos valores
  TechnicalIndicator copyWith({
    String? id,
    String? name,
    String? description,
    IndicatorCategory? category,
    double? value,
    double? previousValue,
    TrendDirection? trend,
    bool? isEnabled,
    DateTime? lastUpdate,
    List<double>? sparklineData,
    Map<String, dynamic>? parameters,
  }) {
    return TechnicalIndicator(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      value: value ?? this.value,
      previousValue: previousValue ?? this.previousValue,
      trend: trend ?? this.trend,
      isEnabled: isEnabled ?? this.isEnabled,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      sparklineData: sparklineData ?? this.sparklineData,
      parameters: parameters ?? this.parameters,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'value': value,
      'previousValue': previousValue,
      'trend': trend.name,
      'isEnabled': isEnabled,
      'lastUpdate': lastUpdate.toIso8601String(),
      'sparklineData': sparklineData,
      'parameters': parameters,
    };
  }

  /// Crea desde JSON
  factory TechnicalIndicator.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicator(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: IndicatorCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => IndicatorCategory.trend,
      ),
      value: (json['value'] as num).toDouble(),
      previousValue: (json['previousValue'] as num).toDouble(),
      trend: TrendDirection.values.firstWhere(
        (t) => t.name == json['trend'],
        orElse: () => TrendDirection.neutral,
      ),
      isEnabled: json['isEnabled'] as bool? ?? false,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      sparklineData: (json['sparklineData'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList() ?? [],
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }
}

/// Factory para crear indicadores predefinidos
class IndicatorFactory {
  static List<TechnicalIndicator> createDefaultIndicators() {
    final now = DateTime.now();
    
    return [
      // TENDENCIA
      TechnicalIndicator(
        id: 'ema_9',
        name: 'EMA 9',
        description: 'Media Móvil Exponencial de 9 períodos',
        category: IndicatorCategory.trend,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 9},
      ),
      TechnicalIndicator(
        id: 'ema_21',
        name: 'EMA 21',
        description: 'Media Móvil Exponencial de 21 períodos',
        category: IndicatorCategory.trend,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 21},
      ),
      TechnicalIndicator(
        id: 'ema_50',
        name: 'EMA 50',
        description: 'Media Móvil Exponencial de 50 períodos',
        category: IndicatorCategory.trend,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 50},
      ),
      TechnicalIndicator(
        id: 'ema_200',
        name: 'EMA 200',
        description: 'Media Móvil Exponencial de 200 períodos',
        category: IndicatorCategory.trend,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 200},
      ),
      TechnicalIndicator(
        id: 'supertrend',
        name: 'SuperTrend',
        description: 'Indicador de tendencia SuperTrend',
        category: IndicatorCategory.trend,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 10, 'multiplier': 3.0},
      ),

      // MOMENTUM
      TechnicalIndicator(
        id: 'rsi',
        name: 'RSI',
        description: 'Índice de Fuerza Relativa',
        category: IndicatorCategory.momentum,
        value: 50,
        previousValue: 50,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 14},
      ),
      TechnicalIndicator(
        id: 'macd',
        name: 'MACD',
        description: 'Convergencia/Divergencia de Medias Móviles',
        category: IndicatorCategory.momentum,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'fast': 12, 'slow': 26, 'signal': 9},
      ),
      TechnicalIndicator(
        id: 'cci',
        name: 'CCI',
        description: 'Índice de Canal de Materias Primas',
        category: IndicatorCategory.momentum,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 20},
      ),

      // VOLUMEN
      TechnicalIndicator(
        id: 'obv',
        name: 'OBV',
        description: 'Volumen en Balance',
        category: IndicatorCategory.volume,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
      ),
      TechnicalIndicator(
        id: 'mfi',
        name: 'MFI',
        description: 'Índice de Flujo de Dinero',
        category: IndicatorCategory.volume,
        value: 50,
        previousValue: 50,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 14},
      ),

      // VOLATILIDAD
      TechnicalIndicator(
        id: 'atr',
        name: 'ATR',
        description: 'Rango Verdadero Promedio',
        category: IndicatorCategory.volatility,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 14},
      ),
      TechnicalIndicator(
        id: 'bollinger_upper',
        name: 'Bollinger Superior',
        description: 'Banda Superior de Bollinger',
        category: IndicatorCategory.volatility,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 20, 'deviation': 2},
      ),
      TechnicalIndicator(
        id: 'bollinger_lower',
        name: 'Bollinger Inferior',
        description: 'Banda Inferior de Bollinger',
        category: IndicatorCategory.volatility,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 20, 'deviation': 2},
      ),

      // COMPUESTOS/IA
      TechnicalIndicator(
        id: 'ichimoku_tenkan',
        name: 'Ichimoku Tenkan',
        description: 'Línea Tenkan-sen de Ichimoku',
        category: IndicatorCategory.composite,
        value: 0,
        previousValue: 0,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'tenkan_period': 9},
      ),
      TechnicalIndicator(
        id: 'adx',
        name: 'ADX',
        description: 'Índice Direccional Promedio',
        category: IndicatorCategory.composite,
        value: 25,
        previousValue: 25,
        trend: TrendDirection.neutral,
        lastUpdate: now,
        parameters: {'period': 14},
      ),
    ];
  }
}
