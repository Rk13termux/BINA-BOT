import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/account_info.dart';
import '../services/binance_service.dart';
import '../services/professional_ai_service.dart';
import '../utils/logger.dart';

/// Modelo para análisis de portfolio
class PortfolioAnalysis {
  final double totalValueUSDT;
  final double totalBTC;
  final double totalChangePercent24h;
  final List<AssetAnalysis> assets;
  final Map<String, double> allocation;
  final String riskLevel;
  final String aiRecommendation;
  final DateTime timestamp;

  PortfolioAnalysis({
    required this.totalValueUSDT,
    required this.totalBTC,
    required this.totalChangePercent24h,
    required this.assets,
    required this.allocation,
    required this.riskLevel,
    required this.aiRecommendation,
    required this.timestamp,
  });
}

/// Modelo para análisis de activo individual
class AssetAnalysis {
  final String symbol;
  final double amount;
  final double valueUSDT;
  final double currentPrice;
  final double changePercent24h;
  final double allocation;
  final String trend;
  final bool isProfit;

  AssetAnalysis({
    required this.symbol,
    required this.amount,
    required this.valueUSDT,
    required this.currentPrice,
    required this.changePercent24h,
    required this.allocation,
    required this.trend,
    required this.isProfit,
  });
}

/// Servicio para análisis integral del portfolio con IA
class PortfolioAIAnalysisService extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  
  final BinanceService _binanceService;
  final ProfessionalAIService _aiService;
  
  PortfolioAnalysis? _currentAnalysis;
  bool _isAnalyzing = false;
  String? _errorMessage;
  
  // Cache de precios para optimizar llamadas
  final Map<String, double> _priceCache = {};
  final Map<String, double> _changeCache = {};
  Timer? _cacheTimer;

  PortfolioAIAnalysisService(this._binanceService, this._aiService) {
    _startPriceCacheUpdate();
  }

  // Getters
  PortfolioAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;

  /// Iniciar actualización automática del cache de precios
  void _startPriceCacheUpdate() {
    _cacheTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _updatePriceCache();
    });
  }

  /// Analizar portfolio completo con IA
  Future<PortfolioAnalysis?> analyzePortfolio() async {
    if (!_binanceService.isAuthenticated) {
      _errorMessage = 'Binance API no configurada';
      notifyListeners();
      return null;
    }

    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Obtener información de la cuenta
      final accountInfo = await _binanceService.getAccountInfo();

      // 2. Procesar balances
      final balances = accountInfo.balances;
      final assets = await _processBalances(balances);

      // 3. Calcular métricas del portfolio
      final totalValueUSDT = assets.fold(0.0, (sum, asset) => sum + asset.valueUSDT);
      final totalBTC = totalValueUSDT / (_priceCache['BTCUSDT'] ?? 50000);
      
      // 4. Calcular cambio total 24h
      final totalChangePercent24h = _calculateTotalChange(assets, totalValueUSDT);

      // 5. Calcular distribución de activos
      final allocation = _calculateAllocation(assets, totalValueUSDT);

      // 6. Evaluar riesgo del portfolio
      final riskLevel = _evaluateRisk(assets, allocation);

      // 7. Obtener recomendación de IA
      final aiRecommendation = await _getAIRecommendation(assets, allocation, riskLevel);

      _currentAnalysis = PortfolioAnalysis(
        totalValueUSDT: totalValueUSDT,
        totalBTC: totalBTC,
        totalChangePercent24h: totalChangePercent24h,
        assets: assets,
        allocation: allocation,
        riskLevel: riskLevel,
        aiRecommendation: aiRecommendation,
        timestamp: DateTime.now(),
      );

      _logger.info('Portfolio analysis completed successfully');
      return _currentAnalysis;

    } catch (e) {
      _errorMessage = 'Error analizando portfolio: $e';
      _logger.error('Portfolio analysis error: $e');
      return null;
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  /// Procesar balances de la cuenta
  Future<List<AssetAnalysis>> _processBalances(List<Balance> balances) async {
    final List<AssetAnalysis> assets = [];
    
    // Obtener precios actuales si no están en cache
    await _updatePriceCache();

    for (final balance in balances) {
      final asset = balance.asset;
      final totalAmount = balance.total;

      if (totalAmount < 0.0001) continue; // Ignorar balances muy pequeños

      // Calcular valor en USDT
      double valueUSDT = 0.0;
      double currentPrice = 0.0;
      double changePercent24h = 0.0;

      if (asset == 'USDT') {
        valueUSDT = totalAmount;
        currentPrice = 1.0;
        changePercent24h = 0.0;
      } else {
        final symbol = '${asset}USDT';
        currentPrice = _priceCache[symbol] ?? 0.0;
        valueUSDT = totalAmount * currentPrice;
        changePercent24h = _changeCache[symbol] ?? 0.0;
      }

      if (valueUSDT < 1.0) continue; // Ignorar activos con valor menor a $1

      assets.add(AssetAnalysis(
        symbol: asset,
        amount: totalAmount,
        valueUSDT: valueUSDT,
        currentPrice: currentPrice,
        changePercent24h: changePercent24h,
        allocation: 0.0, // Se calculará después
        trend: _determineTrend(changePercent24h),
        isProfit: changePercent24h > 0,
      ));
    }

    // Ordenar por valor descendente
    assets.sort((a, b) => b.valueUSDT.compareTo(a.valueUSDT));
    
    return assets;
  }

  /// Actualizar cache de precios para símbolos específicos
  Future<void> _updatePriceCache([List<String>? symbols]) async {
    try {
      // Lista de símbolos comunes para obtener precios
      final defaultSymbols = [
        'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT',
        'SOLUSDT', 'DOTUSDT', 'LINKUSDT', 'LTCUSDT', 'BCHUSDT'
      ];
      
      final symbolsToUpdate = symbols ?? defaultSymbols;
      
      for (final symbol in symbolsToUpdate) {
        try {
          final ticker = await _binanceService.get24hrTicker(symbol);
          if (ticker.isNotEmpty) {
            final price = double.tryParse(ticker['lastPrice']?.toString() ?? '0') ?? 0.0;
            final change = double.tryParse(ticker['priceChangePercent']?.toString() ?? '0') ?? 0.0;
            
            _priceCache[symbol] = price;
            _changeCache[symbol] = change;
          }
        } catch (e) {
          _logger.warning('Error getting ticker for $symbol: $e');
        }
      }
    } catch (e) {
      _logger.error('Error updating price cache: $e');
    }
  }

  /// Calcular cambio total del portfolio en 24h
  double _calculateTotalChange(List<AssetAnalysis> assets, double totalValue) {
    if (totalValue == 0) return 0.0;
    
    double weightedChange = 0.0;
    for (final asset in assets) {
      final weight = asset.valueUSDT / totalValue;
      weightedChange += asset.changePercent24h * weight;
    }
    
    return weightedChange;
  }

  /// Calcular distribución de activos
  Map<String, double> _calculateAllocation(List<AssetAnalysis> assets, double totalValue) {
    final allocation = <String, double>{};
    
    for (final asset in assets) {
      allocation[asset.symbol] = (asset.valueUSDT / totalValue) * 100;
    }
    
    return allocation;
  }

  /// Evaluar nivel de riesgo del portfolio
  String _evaluateRisk(List<AssetAnalysis> assets, Map<String, double> allocation) {
    double riskScore = 0.0;
    
    // Factor 1: Concentración (máximo 40 puntos)
    final maxAllocation = allocation.values.isNotEmpty ? allocation.values.reduce((a, b) => a > b ? a : b) : 0.0;
    if (maxAllocation > 70) riskScore += 40;
    else if (maxAllocation > 50) riskScore += 30;
    else if (maxAllocation > 30) riskScore += 20;
    else riskScore += 10;
    
    // Factor 2: Volatilidad (máximo 30 puntos)
    final avgVolatility = assets.fold(0.0, (sum, asset) => sum + asset.changePercent24h.abs()) / assets.length;
    if (avgVolatility > 15) riskScore += 30;
    else if (avgVolatility > 10) riskScore += 20;
    else if (avgVolatility > 5) riskScore += 15;
    else riskScore += 10;
    
    // Factor 3: Diversificación (máximo 30 puntos)
    if (assets.length < 3) riskScore += 30;
    else if (assets.length < 5) riskScore += 20;
    else if (assets.length < 8) riskScore += 15;
    else riskScore += 10;
    
    // Clasificar riesgo
    if (riskScore >= 80) return 'VERY_HIGH';
    else if (riskScore >= 60) return 'HIGH';
    else if (riskScore >= 40) return 'MEDIUM';
    else if (riskScore >= 25) return 'LOW';
    else return 'VERY_LOW';
  }

  /// Obtener recomendación de IA
  Future<String> _getAIRecommendation(List<AssetAnalysis> assets, Map<String, double> allocation, String riskLevel) async {
    if (!_aiService.isConnected) {
      return _getDefaultRecommendation(riskLevel);
    }

    try {
      final portfolioContext = _buildPortfolioContext(assets, allocation, riskLevel);
      final response = await _aiService.chatWithAssistant(
        'Analiza mi portfolio y dame una recomendación profesional personalizada.',
        context: portfolioContext,
      );
      
      return response ?? _getDefaultRecommendation(riskLevel);
    } catch (e) {
      _logger.warning('Error getting AI recommendation: $e');
      return _getDefaultRecommendation(riskLevel);
    }
  }

  /// Construir contexto del portfolio para la IA
  String _buildPortfolioContext(List<AssetAnalysis> assets, Map<String, double> allocation, String riskLevel) {
    final buffer = StringBuffer();
    buffer.writeln('ANÁLISIS DE PORTFOLIO:');
    buffer.writeln('Nivel de Riesgo: $riskLevel');
    buffer.writeln('Número de activos: ${assets.length}');
    buffer.writeln('\\nDISTRIBUCIÓN:');
    
    for (final asset in assets.take(10)) { // Top 10 activos
      buffer.writeln('${asset.symbol}: ${asset.allocation.toStringAsFixed(1)}% (${asset.changePercent24h.toStringAsFixed(2)}% 24h)');
    }
    
    buffer.writeln('\\nRENDIMIENTO 24H:');
    final profitable = assets.where((a) => a.isProfit).length;
    final losing = assets.length - profitable;
    buffer.writeln('Activos en ganancia: $profitable');
    buffer.writeln('Activos en pérdida: $losing');
    
    return buffer.toString();
  }

  /// Recomendación por defecto basada en riesgo
  String _getDefaultRecommendation(String riskLevel) {
    switch (riskLevel) {
      case 'VERY_HIGH':
        return '⚠️ Tu portfolio tiene un riesgo muy alto. Considera diversificar más y reducir la concentración en activos individuales. La gestión de riesgo es fundamental para el éxito a largo plazo.';
      case 'HIGH':
        return '📊 Portfolio de alto riesgo detectado. Evalúa rebalancear para reducir exposición. Recuerda que las ganancias grandes vienen con riesgos grandes - mantén la disciplina.';
      case 'MEDIUM':
        return '⚖️ Portfolio equilibrado con riesgo moderado. Continúa monitoreando y ajustando según las condiciones del mercado. ¡Vas por buen camino!';
      case 'LOW':
        return '✅ Portfolio conservador con buen balance. Considera oportunidades de crecimiento medido manteniendo tu estrategia de riesgo controlado.';
      default:
        return '🛡️ Portfolio muy conservador. Si buscas mayor rendimiento, evalúa aumentar gradualmente la exposición a activos con mayor potencial, siempre con gestión de riesgo.';
    }
  }

  /// Determinar tendencia basada en cambio 24h
  String _determineTrend(double changePercent) {
    if (changePercent > 5) return 'STRONG_BULLISH';
    else if (changePercent > 2) return 'BULLISH';
    else if (changePercent > -2) return 'NEUTRAL';
    else if (changePercent > -5) return 'BEARISH';
    else return 'STRONG_BEARISH';
  }

  /// Obtener análisis detallado de un activo específico
  Future<String> getAssetAIAnalysis(String symbol) async {
    if (!_aiService.isConnected) return 'IA no disponible';

    try {
      final response = await _aiService.chatWithAssistant(
        'Dame un análisis detallado de $symbol incluyendo perspectivas técnicas y fundamentales.',
        context: 'Análisis individual de activo del portfolio',
      );
      
      return response ?? 'No se pudo obtener análisis del activo';
    } catch (e) {
      return 'Error obteniendo análisis: $e';
    }
  }

  @override
  void dispose() {
    _cacheTimer?.cancel();
    super.dispose();
  }
}
