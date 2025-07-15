/// Recomendación de la IA
enum AIRecommendation {
  strongBuy('🟢', 'COMPRAR FUERTE', 'Señal muy alcista'),
  buy('🔵', 'COMPRAR', 'Señal alcista'),
  hold('🟡', 'MANTENER', 'Señal neutral'),
  sell('🟠', 'VENDER', 'Señal bajista'),
  strongSell('🔴', 'VENDER FUERTE', 'Señal muy bajista');

  const AIRecommendation(this.emoji, this.displayName, this.description);
  final String emoji;
  final String displayName;
  final String description;
}

/// Nivel de confianza de la IA (1-5 estrellas)
enum ConfidenceLevel {
  veryLow(1, '⭐☆☆☆☆', 'Muy baja confianza'),
  low(2, '⭐⭐☆☆☆', 'Baja confianza'),
  medium(3, '⭐⭐⭐☆☆', 'Confianza media'),
  high(4, '⭐⭐⭐⭐☆', 'Alta confianza'),
  veryHigh(5, '⭐⭐⭐⭐⭐', 'Muy alta confianza');

  const ConfidenceLevel(this.level, this.stars, this.description);
  final int level;
  final String stars;
  final String description;
  
  /// Alias para level para compatibilidad
  int get value => level;
}

/// Análisis estratégico generado por IA
class AIAnalysis {
  final String id;
  final String symbol;
  final AIRecommendation recommendation;
  final ConfidenceLevel confidence;
  final String briefSummary;
  final String fullReasoning;
  final List<String> keyFactors;
  final Map<String, dynamic> technicalData;
  final double estimatedPriceTarget;
  final double stopLossLevel;
  final DateTime timestamp;
  final Duration analysisTime;
  final String model; // ej: "mistral-7b-8k"

  AIAnalysis({
    required this.id,
    required this.symbol,
    required this.recommendation,
    required this.confidence,
    required this.briefSummary,
    required this.fullReasoning,
    required this.keyFactors,
    required this.technicalData,
    required this.estimatedPriceTarget,
    required this.stopLossLevel,
    required this.timestamp,
    required this.analysisTime,
    required this.model,
  });

  /// Determina si el análisis es reciente (menos de 5 minutos)
  bool get isRecent {
    return DateTime.now().difference(timestamp).inMinutes < 5;
  }

  /// Obtiene el color asociado a la recomendación
  String get recommendationColor {
    switch (recommendation) {
      case AIRecommendation.strongBuy:
        return '#00FF88';
      case AIRecommendation.buy:
        return '#4CAF50';
      case AIRecommendation.hold:
        return '#FFD700';
      case AIRecommendation.sell:
        return '#FF9800';
      case AIRecommendation.strongSell:
        return '#FF4444';
    }
  }

  /// Copia el análisis con nuevos valores
  AIAnalysis copyWith({
    String? id,
    String? symbol,
    AIRecommendation? recommendation,
    ConfidenceLevel? confidence,
    String? briefSummary,
    String? fullReasoning,
    List<String>? keyFactors,
    Map<String, dynamic>? technicalData,
    double? estimatedPriceTarget,
    double? stopLossLevel,
    DateTime? timestamp,
    Duration? analysisTime,
    String? model,
  }) {
    return AIAnalysis(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      recommendation: recommendation ?? this.recommendation,
      confidence: confidence ?? this.confidence,
      briefSummary: briefSummary ?? this.briefSummary,
      fullReasoning: fullReasoning ?? this.fullReasoning,
      keyFactors: keyFactors ?? this.keyFactors,
      technicalData: technicalData ?? this.technicalData,
      estimatedPriceTarget: estimatedPriceTarget ?? this.estimatedPriceTarget,
      stopLossLevel: stopLossLevel ?? this.stopLossLevel,
      timestamp: timestamp ?? this.timestamp,
      analysisTime: analysisTime ?? this.analysisTime,
      model: model ?? this.model,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'recommendation': recommendation.name,
      'confidence': confidence.name,
      'briefSummary': briefSummary,
      'fullReasoning': fullReasoning,
      'keyFactors': keyFactors,
      'technicalData': technicalData,
      'estimatedPriceTarget': estimatedPriceTarget,
      'stopLossLevel': stopLossLevel,
      'timestamp': timestamp.toIso8601String(),
      'analysisTime': analysisTime.inMilliseconds,
      'model': model,
    };
  }

  /// Crea desde JSON
  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      recommendation: AIRecommendation.values.firstWhere(
        (r) => r.name == json['recommendation'],
        orElse: () => AIRecommendation.hold,
      ),
      confidence: ConfidenceLevel.values.firstWhere(
        (c) => c.name == json['confidence'],
        orElse: () => ConfidenceLevel.medium,
      ),
      briefSummary: json['briefSummary'] as String,
      fullReasoning: json['fullReasoning'] as String,
      keyFactors: List<String>.from(json['keyFactors'] ?? []),
      technicalData: Map<String, dynamic>.from(json['technicalData'] ?? {}),
      estimatedPriceTarget: (json['estimatedPriceTarget'] as num).toDouble(),
      stopLossLevel: (json['stopLossLevel'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      analysisTime: Duration(milliseconds: json['analysisTime'] as int),
      model: json['model'] as String,
    );
  }
}

/// Estado del análisis de IA
class AIAnalysisState {
  final bool isAnalyzing;
  final AIAnalysis? currentAnalysis;
  final String? error;
  final DateTime? lastUpdate;

  AIAnalysisState({
    this.isAnalyzing = false,
    this.currentAnalysis,
    this.error,
    this.lastUpdate,
  });

  AIAnalysisState copyWith({
    bool? isAnalyzing,
    AIAnalysis? currentAnalysis,
    String? error,
    DateTime? lastUpdate,
  }) {
    return AIAnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}
