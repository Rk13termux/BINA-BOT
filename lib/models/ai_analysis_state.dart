import '../models/ai_analysis.dart';

/// Estado del análisis de IA
class AIAnalysisState {
  final bool isAnalyzing;
  final AIAnalysis? currentAnalysis;
  final String? error;
  final DateTime? lastUpdate;
  final List<AIAnalysis> history;

  const AIAnalysisState({
    this.isAnalyzing = false,
    this.currentAnalysis,
    this.error,
    this.lastUpdate,
    this.history = const [],
  });

  /// Crea una copia con nuevos valores
  AIAnalysisState copyWith({
    bool? isAnalyzing,
    AIAnalysis? currentAnalysis,
    String? error,
    DateTime? lastUpdate,
    List<AIAnalysis>? history,
  }) {
    return AIAnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
      error: error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      history: history ?? this.history,
    );
  }

  /// Estado de carga
  bool get hasData => currentAnalysis != null;
  
  /// Estado de error
  bool get hasError => error != null && error!.isNotEmpty;
  
  /// Tiempo desde la última actualización
  Duration? get timeSinceLastUpdate {
    if (lastUpdate == null) return null;
    return DateTime.now().difference(lastUpdate!);
  }

  /// Indica si necesita actualización (más de 5 minutos)
  bool get needsUpdate {
    final duration = timeSinceLastUpdate;
    return duration == null || duration.inMinutes > 5;
  }

  @override
  String toString() {
    return 'AIAnalysisState(isAnalyzing: $isAnalyzing, hasData: $hasData, hasError: $hasError)';
  }
}
