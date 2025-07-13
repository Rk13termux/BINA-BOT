import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data.dart';
import '../../utils/constants.dart';

class ProfessionalCandlestickChart extends StatefulWidget {
  final List<CandleData> candles;
  final String symbol;
  final ChartInterval interval;
  final bool showVolume;
  final bool showOrderBook;
  final OrderBookData? orderBook;
  final VoidCallback? onIntervalChanged;
  final Function(ChartInterval)? onIntervalSelected;
  
  const ProfessionalCandlestickChart({
    Key? key,
    required this.candles,
    required this.symbol,
    required this.interval,
    this.showVolume = true,
    this.showOrderBook = false,
    this.orderBook,
    this.onIntervalChanged,
    this.onIntervalSelected,
  }) : super(key: key);

  @override
  State<ProfessionalCandlestickChart> createState() => _ProfessionalCandlestickChartState();
}

class _ProfessionalCandlestickChartState extends State<ProfessionalCandlestickChart> {
  bool _showGrid = true;
  bool _showCrosshair = true;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildIntervalSelector(),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: widget.showOrderBook ? 7 : 1,
                  child: _buildMainChart(),
                ),
                if (widget.showOrderBook && widget.orderBook != null)
                  Expanded(
                    flex: 3,
                    child: _buildOrderBookWidget(),
                  ),
              ],
            ),
          ),
          if (widget.showVolume)
            SizedBox(
              height: 120,
              child: _buildVolumeChart(),
            ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Logo/Icon del símbolo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.currency_bitcoin,
              color: AppColors.goldPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Información del símbolo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.symbol,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.candles.isNotEmpty)
                  Text(
                    '\$${widget.candles.last.close.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: widget.candles.last.isBullish
                          ? AppColors.bullishGreen
                          : AppColors.bearishRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          
          // Controles
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showGrid = !_showGrid;
                  });
                },
                icon: Icon(
                  Icons.grid_on,
                  color: _showGrid ? AppColors.goldPrimary : Colors.grey,
                ),
                tooltip: 'Mostrar/Ocultar Grid',
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showCrosshair = !_showCrosshair;
                  });
                },
                icon: Icon(
                  Icons.add,
                  color: _showCrosshair ? AppColors.goldPrimary : Colors.grey,
                ),
                tooltip: 'Mostrar/Ocultar Crosshair',
              ),
              IconButton(
                onPressed: widget.onIntervalChanged,
                icon: Icon(
                  Icons.refresh,
                  color: AppColors.goldPrimary,
                ),
                tooltip: 'Actualizar',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildIntervalSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ChartInterval.values.map((interval) {
            final isSelected = interval == widget.interval;
            
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: Material(
                color: isSelected
                    ? AppColors.goldPrimary
                    : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => widget.onIntervalSelected?.call(interval),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.goldPrimary
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      interval.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.backgroundDark
                            : Colors.white,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildMainChart() {
    if (widget.candles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        _createCandlestickData(),
        duration: const Duration(milliseconds: 150),
        curve: Curves.linear,
      ),
    );
  }
  
  LineChartData _createCandlestickData() {
    final spots = <FlSpot>[];
    final candleSpots = <FlSpot>[];
    
    for (int i = 0; i < widget.candles.length; i++) {
      final candle = widget.candles[i];
      spots.add(FlSpot(i.toDouble(), candle.close));
      candleSpots.add(FlSpot(i.toDouble(), candle.close));
    }
    
    return LineChartData(
      gridData: FlGridData(
        show: _showGrid,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: null,
        verticalInterval: null,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: widget.candles.length / 5,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.candles.length) {
                final candle = widget.candles[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _formatTime(candle.timestamp),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 80,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _createCandlestickLineData(),
      ],
      lineTouchData: LineTouchData(
        enabled: _showCrosshair,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Callback para manejar interacciones táctiles
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.all(8),
          getTooltipColor: (spot) => AppColors.backgroundDark.withOpacity(0.9),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              if (index >= 0 && index < widget.candles.length) {
                final candle = widget.candles[index];
                return LineTooltipItem(
                  '${widget.symbol}\\n'
                  'O: \$${candle.open.toStringAsFixed(2)}\\n'
                  'H: \$${candle.high.toStringAsFixed(2)}\\n'
                  'L: \$${candle.low.toStringAsFixed(2)}\\n'
                  'C: \$${candle.close.toStringAsFixed(2)}\\n'
                  'V: ${_formatVolume(candle.volume)}\\n'
                  '${_formatDateTime(candle.timestamp)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }
  
  LineChartBarData _createCandlestickLineData() {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < widget.candles.length; i++) {
      final candle = widget.candles[i];
      spots.add(FlSpot(i.toDouble(), candle.close));
    }
    
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: AppColors.goldPrimary,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.goldPrimary.withOpacity(0.1),
      ),
    );
  }
  
  Widget _buildVolumeChart() {
    if (widget.candles.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: widget.candles.map((c) => c.volume).reduce((a, b) => a > b ? a : b),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _formatVolume(value),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: widget.candles.asMap().entries.map((entry) {
            final index = entry.key;
            final candle = entry.value;
            
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: candle.volume,
                  color: candle.isBullish
                      ? AppColors.bullishGreen.withOpacity(0.7)
                      : AppColors.bearishRed.withOpacity(0.7),
                  width: 3,
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: null,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildOrderBookWidget() {
    if (widget.orderBook == null) return const SizedBox.shrink();
    
    final orderBook = widget.orderBook!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.goldPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Order Book',
            style: TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Spread info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.goldPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spread: \$${orderBook.spread.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${orderBook.spreadPercent.toStringAsFixed(3)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Order book levels
          Expanded(
            child: Row(
              children: [
                // Asks (Sell orders)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asks',
                        style: TextStyle(
                          color: AppColors.bearishRed,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: orderBook.asks.take(10).length,
                          itemBuilder: (context, index) {
                            final ask = orderBook.asks[index];
                            return _buildOrderBookLevel(
                              ask,
                              AppColors.bearishRed,
                              isAsk: true,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Bids (Buy orders)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bids',
                        style: TextStyle(
                          color: AppColors.bullishGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: orderBook.bids.take(10).length,
                          itemBuilder: (context, index) {
                            final bid = orderBook.bids[index];
                            return _buildOrderBookLevel(
                              bid,
                              AppColors.bullishGreen,
                              isAsk: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderBookLevel(OrderBookLevel level, Color color, {required bool isAsk}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${level.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            _formatVolume(level.quantity),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    if (widget.interval.isShortTerm) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (widget.interval.isMediumTerm) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year.toString().substring(2)}';
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(2);
    }
  }
}
