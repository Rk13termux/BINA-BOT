import 'package:flutter/material.dart';
import '../../ui/theme/colors.dart';
import '../../plugins/strategies/base_strategy.dart';
import '../../plugins/strategies/scalping_bot.dart';
import '../../plugins/strategies/swing_trading_ai.dart';
import '../../utils/logger.dart';

/// Pantalla de selección de estrategias
class StrategySelectorScreen extends StatefulWidget {
  final String selectedCoin;
  final Function(BaseStrategy, bool) onStrategySelected;

  const StrategySelectorScreen({
    super.key,
    required this.selectedCoin,
    required this.onStrategySelected,
  });

  @override
  State<StrategySelectorScreen> createState() => _StrategySelectorScreenState();
}

class _StrategySelectorScreenState extends State<StrategySelectorScreen> {
  final AppLogger _logger = AppLogger();
  bool _useAI = true;
  StrategyType? _selectedType;

  final List<BaseStrategy> _strategies = [
    ScalpingBotStrategy(),
    SwingTradingAIStrategy(),
    // Aquí se pueden agregar más estrategias
  ];

  List<BaseStrategy> get _filteredStrategies {
    if (_selectedType == null) {
      return _strategies;
    }
    return _strategies.where((strategy) => strategy.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar Estrategia',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Para ${widget.selectedCoin}',
            style: TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildAIToggle(),
        _buildFilterTabs(),
        Expanded(child: _buildStrategyGrid()),
      ],
    );
  }

  Widget _buildAIToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.goldPrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: _useAI ? AppColors.goldPrimary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inteligencia Artificial',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _useAI 
                      ? 'Las estrategias usarán análisis de IA'
                      : 'Solo análisis técnico tradicional',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _useAI,
            onChanged: (value) {
              setState(() {
                _useAI = value;
              });
            },
            activeColor: AppColors.goldPrimary,
            activeTrackColor: AppColors.goldPrimary.withOpacity(0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.neutral.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final types = [
      {'type': null, 'name': 'Todas', 'icon': Icons.all_inclusive},
      {'type': StrategyType.scalping, 'name': 'Scalping', 'icon': Icons.speed},
      {'type': StrategyType.swing, 'name': 'Swing', 'icon': Icons.timeline},
      {'type': StrategyType.grid, 'name': 'Grid', 'icon': Icons.grid_on},
      {'type': StrategyType.sentiment, 'name': 'Sentiment', 'icon': Icons.sentiment_satisfied},
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        itemBuilder: (context, index) {
          final typeData = types[index];
          final isSelected = _selectedType == typeData['type'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = typeData['type'] as StrategyType?;
                  });
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.goldPrimary.withOpacity(0.2)
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.goldPrimary
                          : AppColors.goldPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        typeData['icon'] as IconData,
                        color: isSelected 
                            ? AppColors.goldPrimary
                            : AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        typeData['name'] as String,
                        style: TextStyle(
                          color: isSelected 
                              ? AppColors.goldPrimary
                              : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrategyGrid() {
    final filteredStrategies = _filteredStrategies;

    if (filteredStrategies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay estrategias disponibles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredStrategies.length,
      itemBuilder: (context, index) {
        final strategy = filteredStrategies[index];
        return _buildStrategyCard(strategy);
      },
    );
  }

  Widget _buildStrategyCard(BaseStrategy strategy) {
    final supportsAI = strategy.supportsAI;
    final isAICompatible = !_useAI || supportsAI;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAICompatible 
            ? () => _selectStrategy(strategy)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isAICompatible 
                ? AppColors.surfaceDark
                : AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: strategy.color.withOpacity(isAICompatible ? 0.5 : 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: strategy.color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con ícono y tipo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: strategy.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      strategy.icon,
                      color: strategy.color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (supportsAI)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'AI',
                        style: TextStyle(
                          color: AppColors.goldPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Nombre de la estrategia
              Text(
                strategy.name,
                style: TextStyle(
                  color: isAICompatible 
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Descripción
              Expanded(
                child: Text(
                  strategy.description,
                  style: TextStyle(
                    color: isAICompatible 
                        ? AppColors.textSecondary
                        : AppColors.textSecondary.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botón de selección
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAICompatible 
                      ? () => _selectStrategy(strategy)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAICompatible 
                        ? strategy.color
                        : AppColors.neutral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isAICompatible ? 'Seleccionar' : 'No Compatible',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Warning para estrategias no compatibles con IA
              if (!isAICompatible)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'No soporta IA',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectStrategy(BaseStrategy strategy) {
    _logger.info('Selected strategy: ${strategy.name} with AI: $_useAI for coin: ${widget.selectedCoin}');
    widget.onStrategySelected(strategy, _useAI);
  }
}
