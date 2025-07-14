import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../services/data_stream_service.dart';
import '../../services/binance_service.dart';
import '../../services/ai_service.dart';
import '../../ui/theme/app_theme.dart';
import '../../utils/logger.dart';

/// Dashboard principal con 30+ indicadores técnicos profesionales
class IndicatorsBoard extends StatefulWidget {
  const IndicatorsBoard({super.key});

  @override
  State<IndicatorsBoard> createState() => _IndicatorsBoardState();
}

class _IndicatorsBoardState extends State<IndicatorsBoard>
    with TickerProviderStateMixin {
  
  static final AppLogger _logger = AppLogger();
  
  // Controladores de animación
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  // Estado del dashboard
  String _selectedSymbol = 'BTCUSDT';
  String _selectedTimeframe = '1m';
  bool _isRealTimeMode = true;
  Timer? _refreshTimer;
  
  // Configuración de símbolos disponibles
  final List<String> _availableSymbols = [
    'BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'XRPUSDT',
    'SOLUSDT', 'DOTUSDT', 'DOGEUSDT', 'AVAXUSDT', 'SHIBUSDT',
    'MATICUSDT', 'LTCUSDT', 'UNIUSDT', 'LINKUSDT', 'ATOMUSDT',
    'FTMUSDT', 'MANAUSDT', 'SANDUSDT', 'AXSUSDT', 'CHZUSDT'
  ];
  
  // Timeframes disponibles
  final List<String> _availableTimeframes = [
    '1m', '3m', '5m', '15m', '30m', '1h', '2h', '4h', '6h', '8h', '12h', '1d'
  ];

  // Categorización de indicadores por tipo
  final Map<String, List<String>> _indicatorCategories = {
    'Tendencia': [
      'SMA_20', 'SMA_50', 'EMA_12', 'EMA_26', 'VWAP', 
      'ICHIMOKU_TENKAN', 'ICHIMOKU_KIJUN', 'PARABOLIC_SAR'
    ],
    'Momentum': [
      'RSI_14', 'STOCH_K', 'STOCH_D', 'WILLIAMS_R', 'MFI_14',
      'CCI_20', 'ULTIMATE_OSCILLATOR', 'ADX_14'
    ],
    'Volatilidad': [
      'BB_UPPER', 'BB_LOWER', 'ATR_14', 'CHAIKIN_OSCILLATOR'
    ],
    'Volumen': [
      'OBV', 'VOLUME_SMA', 'PRICE_VOLUME_TREND', 'COMMODITY_CHANNEL'
    ],
    'Soporte/Resistencia': [
      'PIVOT_POINT', 'SUPPORT_1', 'RESISTANCE_1', 
      'FIBONACCI_382', 'FIBONACCI_618'
    ],
    'MACD': [
      'MACD_LINE', 'MACD_SIGNAL', 'MACD_HISTOGRAM'
    ]
  };

  // Colores por categoría
  final Map<String, Color> _categoryColors = {
    'Tendencia': const Color(0xFF4CAF50),      // Verde
    'Momentum': const Color(0xFF2196F3),       // Azul
    'Volatilidad': const Color(0xFFFF9800),    // Naranja
    'Volumen': const Color(0xFF9C27B0),        // Púrpura
    'Soporte/Resistencia': const Color(0xFFFFD700), // Oro
    'MACD': const Color(0xFFE91E63),           // Rosa
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeDataStream();
    _startRealTimeUpdates();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));
    
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  void _initializeDataStream() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataService = context.read<DataStreamService>();
      dataService.setSymbol(_selectedSymbol);
      dataService.setTimeframe(_selectedTimeframe);
      
      if (!dataService.isRunning) {
        dataService.startDataStream();
      }
    });
  }

  void _startRealTimeUpdates() {
    if (_isRealTimeMode) {
      _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildControlPanel(),
          Expanded(child: _buildIndicatorsGrid()),
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value,
                child: Icon(
                  Icons.analytics_rounded,
                  color: const Color(0xFFFFD700),
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INDICADORES PROFESIONALES',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Consumer<DataStreamService>(
                builder: (context, dataService, _) {
                  return Text(
                    '${dataService.currentSymbol} • ${dataService.currentTimeframe} • ${dataService.technicalIndicators.length} Indicadores',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          Consumer<DataStreamService>(
            builder: (context, dataService, _) {
              return AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: dataService.isRunning 
                            ? const Color(0xFF4CAF50) 
                            : const Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            dataService.isRunning 
                                ? Icons.radio_button_checked 
                                : Icons.radio_button_off,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dataService.isRunning ? 'EN VIVO' : 'PAUSADO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Selector de símbolo
          Expanded(
            flex: 2,
            child: _buildSymbolSelector(),
          ),
          const SizedBox(width: 16),
          
          // Selector de timeframe
          Expanded(
            flex: 1,
            child: _buildTimeframeSelector(),
          ),
          const SizedBox(width: 16),
          
          // Precio actual
          Expanded(
            flex: 2,
            child: _buildCurrentPrice(),
          ),
          const SizedBox(width: 16),
          
          // Controles
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSymbol,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
              items: _availableSymbols.map((symbol) {
                return DropdownMenuItem<String>(
                  value: symbol,
                  child: Text(
                    symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newSymbol) {
                if (newSymbol != null) {
                  setState(() {
                    _selectedSymbol = newSymbol;
                  });
                  dataService.setSymbol(newSymbol);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeframeSelector() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeframe,
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700)),
              items: _availableTimeframes.map((timeframe) {
                return DropdownMenuItem<String>(
                  value: timeframe,
                  child: Text(
                    timeframe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newTimeframe) {
                if (newTimeframe != null) {
                  setState(() {
                    _selectedTimeframe = newTimeframe;
                  });
                  dataService.setTimeframe(newTimeframe);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPrice() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        final price = dataService.currentPrice;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4CAF50).withValues(alpha: 0.2),
                const Color(0xFF4CAF50).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRECIO ACTUAL',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price > 0 ? '\$${price.toStringAsFixed(2)}' : 'Cargando...',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        return Row(
          children: [
            // Botón play/pause
            IconButton(
              onPressed: () {
                if (dataService.isRunning) {
                  dataService.stopDataStream();
                  _refreshTimer?.cancel();
                } else {
                  dataService.startDataStream();
                  _startRealTimeUpdates();
                }
              },
              icon: Icon(
                dataService.isRunning ? Icons.pause_circle : Icons.play_circle,
                color: const Color(0xFFFFD700),
                size: 32,
              ),
            ),
            
            // Botón refresh
            IconButton(
              onPressed: () async {
                await dataService.initialize();
              },
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFFFFD700),
                size: 28,
              ),
            ),
            
            // Toggle tiempo real
            IconButton(
              onPressed: () {
                setState(() {
                  _isRealTimeMode = !_isRealTimeMode;
                });
                
                if (_isRealTimeMode) {
                  _startRealTimeUpdates();
                } else {
                  _refreshTimer?.cancel();
                }
              },
              icon: Icon(
                _isRealTimeMode ? Icons.update : Icons.update_disabled,
                color: _isRealTimeMode 
                    ? const Color(0xFF4CAF50) 
                    : Colors.grey,
                size: 28,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIndicatorsGrid() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: _indicatorCategories.entries.map((categoryEntry) {
              final categoryName = categoryEntry.key;
              final indicators = categoryEntry.value;
              final categoryColor = _categoryColors[categoryName]!;
              
              return _buildCategorySection(
                categoryName, 
                indicators, 
                categoryColor, 
                dataService.technicalIndicators,
                dataService.enabledIndicators,
                dataService,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(
    String categoryName,
    List<String> indicators,
    Color categoryColor,
    Map<String, double> indicatorValues,
    Map<String, bool> enabledIndicators,
    DataStreamService dataService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: categoryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de categoría
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withValues(alpha: 0.2),
                  categoryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(categoryName),
                  color: categoryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  categoryName.toUpperCase(),
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${indicators.where((i) => enabledIndicators[i] == true).length}/${indicators.length}',
                  style: TextStyle(
                    color: categoryColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Grid de indicadores
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: indicators.length,
              itemBuilder: (context, index) {
                final indicator = indicators[index];
                final value = indicatorValues[indicator];
                final isEnabled = enabledIndicators[indicator] == true;
                
                return _buildIndicatorCard(
                  indicator,
                  value,
                  isEnabled,
                  categoryColor,
                  dataService,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(
    String indicator,
    double? value,
    bool isEnabled,
    Color categoryColor,
    DataStreamService dataService,
  ) {
    final displayName = _getDisplayName(indicator);
    final formattedValue = _formatIndicatorValue(indicator, value);
    final signalColor = _getSignalColor(indicator, value);
    
    return GestureDetector(
      onTap: () {
        dataService.toggleIndicator(indicator, !isEnabled);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled 
              ? categoryColor.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled 
                ? categoryColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicador activo/inactivo
            Row(
              children: [
                Icon(
                  isEnabled ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isEnabled ? categoryColor : Colors.grey,
                  size: 16,
                ),
                const Spacer(),
                if (value != null && isEnabled)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: signalColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Nombre del indicador
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Valor del indicador
            Text(
              formattedValue,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isEnabled && value != null ? signalColor : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Consumer<DataStreamService>(
      builder: (context, dataService, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildInfoItem(
                'VELAS',
                '${dataService.candleData.length}',
                Icons.candlestick_chart,
              ),
              _buildInfoItem(
                'INDICADORES',
                '${dataService.technicalIndicators.length}',
                Icons.analytics,
              ),
              _buildInfoItem(
                'ANÁLISIS IA',
                dataService.aiAnalysis.isNotEmpty ? 'ACTIVO' : 'INACTIVO',
                Icons.psychology,
              ),
              const Spacer(),
              Consumer<AIService>(
                builder: (context, aiService, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: aiService.isAvailable 
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : const Color(0xFFFF5722).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: aiService.isAvailable 
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFF5722),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology,
                          color: aiService.isAvailable 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFFF5722),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          aiService.isAvailable ? 'IA CONECTADA' : 'IA DESCONECTADA',
                          style: TextStyle(
                            color: aiService.isAvailable 
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFFF5722),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD700),
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // === MÉTODOS HELPER ===

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tendencia':
        return Icons.trending_up;
      case 'Momentum':
        return Icons.speed;
      case 'Volatilidad':
        return Icons.waves;
      case 'Volumen':
        return Icons.bar_chart;
      case 'Soporte/Resistencia':
        return Icons.horizontal_rule;
      case 'MACD':
        return Icons.show_chart;
      default:
        return Icons.analytics;
    }
  }

  String _getDisplayName(String indicator) {
    final names = {
      'SMA_20': 'SMA 20',
      'SMA_50': 'SMA 50',
      'EMA_12': 'EMA 12',
      'EMA_26': 'EMA 26',
      'RSI_14': 'RSI 14',
      'MACD_LINE': 'MACD',
      'MACD_SIGNAL': 'Signal',
      'MACD_HISTOGRAM': 'Histogram',
      'BB_UPPER': 'BB Superior',
      'BB_LOWER': 'BB Inferior',
      'ATR_14': 'ATR 14',
      'OBV': 'OBV',
      'STOCH_K': 'Stoch %K',
      'STOCH_D': 'Stoch %D',
      'WILLIAMS_R': 'Williams %R',
      'MFI_14': 'MFI 14',
      'CCI_20': 'CCI 20',
      'ADX_14': 'ADX 14',
      'VWAP': 'VWAP',
      'PIVOT_POINT': 'Pivot',
      'SUPPORT_1': 'Soporte 1',
      'RESISTANCE_1': 'Resistencia 1',
      'FIBONACCI_382': 'Fib 38.2%',
      'FIBONACCI_618': 'Fib 61.8%',
      'ICHIMOKU_TENKAN': 'Ichimoku T',
      'ICHIMOKU_KIJUN': 'Ichimoku K',
      'PARABOLIC_SAR': 'SAR',
      'VOLUME_SMA': 'Vol SMA',
      'PRICE_VOLUME_TREND': 'PVT',
      'CHAIKIN_OSCILLATOR': 'Chaikin',
      'ULTIMATE_OSCILLATOR': 'Ultimate',
      'COMMODITY_CHANNEL': 'CCI',
    };
    
    return names[indicator] ?? indicator;
  }

  String _formatIndicatorValue(String indicator, double? value) {
    if (value == null) return 'N/A';
    
    // Formateo específico según el tipo de indicador
    if (indicator.contains('RSI') || indicator.contains('STOCH') || 
        indicator.contains('WILLIAMS') || indicator.contains('MFI')) {
      return value.toStringAsFixed(1);
    }
    
    if (indicator.contains('PRICE') || indicator.contains('SMA') || 
        indicator.contains('EMA') || indicator.contains('BB') ||
        indicator.contains('PIVOT') || indicator.contains('SUPPORT') ||
        indicator.contains('RESISTANCE') || indicator.contains('VWAP')) {
      return value.toStringAsFixed(2);
    }
    
    if (indicator.contains('ATR') || indicator.contains('MACD')) {
      return value.toStringAsFixed(4);
    }
    
    if (indicator.contains('OBV') || indicator.contains('VOLUME')) {
      return _formatVolume(value);
    }
    
    return value.toStringAsFixed(3);
  }

  String _formatVolume(double volume) {
    if (volume >= 1e9) {
      return '${(volume / 1e9).toStringAsFixed(1)}B';
    } else if (volume >= 1e6) {
      return '${(volume / 1e6).toStringAsFixed(1)}M';
    } else if (volume >= 1e3) {
      return '${(volume / 1e3).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  Color _getSignalColor(String indicator, double? value) {
    if (value == null) return Colors.grey;
    
    // RSI signals
    if (indicator.contains('RSI')) {
      if (value > 70) return const Color(0xFFFF5722); // Sobrecompra
      if (value < 30) return const Color(0xFF4CAF50); // Sobreventa
      return const Color(0xFFFFD700); // Neutral
    }
    
    // Stochastic signals
    if (indicator.contains('STOCH')) {
      if (value > 80) return const Color(0xFFFF5722);
      if (value < 20) return const Color(0xFF4CAF50);
      return const Color(0xFFFFD700);
    }
    
    // Williams %R signals
    if (indicator.contains('WILLIAMS')) {
      if (value > -20) return const Color(0xFFFF5722);
      if (value < -80) return const Color(0xFF4CAF50);
      return const Color(0xFFFFD700);
    }
    
    // MFI signals
    if (indicator.contains('MFI')) {
      if (value > 80) return const Color(0xFFFF5722);
      if (value < 20) return const Color(0xFF4CAF50);
      return const Color(0xFFFFD700);
    }
    
    // MACD signals
    if (indicator.contains('MACD')) {
      if (value > 0) return const Color(0xFF4CAF50);
      if (value < 0) return const Color(0xFFFF5722);
      return const Color(0xFFFFD700);
    }
    
    // Default: positive/negative/neutral
    if (value > 0) return const Color(0xFF4CAF50);
    if (value < 0) return const Color(0xFFFF5722);
    return const Color(0xFFFFD700);
  }
}
