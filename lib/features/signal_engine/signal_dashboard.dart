import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 🚨 Dashboard de Señales - QUANTIX AI CORE
/// Motor de señales profesional con alertas inteligentes
class SignalDashboard extends StatefulWidget {
  const SignalDashboard({super.key});

  @override
  State<SignalDashboard> createState() => _SignalDashboardState();
}

class _SignalDashboardState extends State<SignalDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Señales activas simuladas
  final List<Map<String, dynamic>> _activeSignals = [
    {
      'symbol': 'BTCUSDT',
      'type': 'BUY',
      'confidence': 94.5,
      'strategy': 'Breakout + Volume',
      'entry': 42350.00,
      'target': 45200.00,
      'stop': 40100.00,
      'time': '2 min ago',
      'status': 'active',
    },
    {
      'symbol': 'ETHUSDT',
      'type': 'STRONG_BUY',
      'confidence': 87.3,
      'strategy': 'Golden Cross',
      'entry': 2845.50,
      'target': 3100.00,
      'stop': 2650.00,
      'time': '15 min ago',
      'status': 'active',
    },
    {
      'symbol': 'BNBUSDT',
      'type': 'SELL',
      'confidence': 76.8,
      'strategy': 'RSI Divergence',
      'entry': 315.20,
      'target': 295.00,
      'stop': 325.00,
      'time': '1h ago',
      'status': 'triggered',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header del motor de señales
        _buildSignalHeader(),
        
        const SizedBox(height: 20),
        
        // Métricas del motor
        _buildSignalMetrics(),
        
        const SizedBox(height: 20),
        
        // Señales activas
        _buildActiveSignals(),
        
        const SizedBox(height: 20),
        
        // Configuración de alertas
        _buildAlertSettings(),
      ],
    );
  }

  /// Header del motor de señales
  Widget _buildSignalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Row(
        children: [
          // Ícono animado
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: QuantixTheme.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: QuantixTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.radar,
                color: QuantixTheme.primaryBlack,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signal Engine',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Detectando oportunidades en tiempo real',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: QuantixTheme.neutralGray,
                  ),
                ),
              ],
            ),
          ),
          
          // Estado del motor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: QuantixTheme.bullishGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: QuantixTheme.primaryBlack,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'ACTIVO',
                  style: TextStyle(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Métricas del motor de señales
  Widget _buildSignalMetrics() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Señales Hoy', '23', QuantixTheme.primaryGold)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('Precisión', '89.4%', QuantixTheme.bullishGreen)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard('Activas', '3', QuantixTheme.electricBlue)),
      ],
    );
  }

  /// Card de métrica individual
  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: QuantixTheme.neutralGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Lista de señales activas
  Widget _buildActiveSignals() {
    return Container(
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: QuantixTheme.cardBlack,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Señales Activas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: QuantixTheme.electricBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_activeSignals.length} activas',
                    style: const TextStyle(
                      color: QuantixTheme.electricBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de señales
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeSignals.length,
            itemBuilder: (context, index) {
              return _buildSignalCard(_activeSignals[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Card de señal individual
  Widget _buildSignalCard(Map<String, dynamic> signal) {
    final Color signalColor = _getSignalColor(signal['type']);
    final bool isActive = signal['status'] == 'active';
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuantixTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signalColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Header de la señal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Indicador de estado
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isActive ? QuantixTheme.bullishGreen : QuantixTheme.hold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Símbolo
                  Text(
                    signal['symbol'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Tipo de señal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: signalColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  signal['type'].toString().replaceAll('_', ' '),
                  style: const TextStyle(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Estrategia y confianza
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                signal['strategy'],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: QuantixTheme.electricBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${signal['confidence']}% confianza',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: QuantixTheme.primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Niveles de precio
          Row(
            children: [
              Expanded(child: _buildPriceLevel('Entry', signal['entry'], QuantixTheme.electricBlue)),
              const SizedBox(width: 8),
              Expanded(child: _buildPriceLevel('Target', signal['target'], QuantixTheme.bullishGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildPriceLevel('Stop', signal['stop'], QuantixTheme.bearishRed)),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Tiempo
          Text(
            signal['time'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: QuantixTheme.neutralGray,
            ),
          ),
        ],
      ),
    );
  }

  /// Nivel de precio
  Widget _buildPriceLevel(String label, double price, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Configuración de alertas
  Widget _buildAlertSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuración de Alertas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Opciones de alertas
          _buildAlertOption('Notificaciones Push', true),
          _buildAlertOption('Alertas de Audio', true),
          _buildAlertOption('Solo Señales de Alta Confianza', false),
          _buildAlertOption('Alertas de Noticias de Alto Impacto', true),
          
          const SizedBox(height: 16),
          
          // Botón de configuración avanzada
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // TODO: Abrir configuración avanzada
              },
              style: TextButton.styleFrom(
                backgroundColor: QuantixTheme.electricBlue.withOpacity(0.1),
                foregroundColor: QuantixTheme.electricBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Configuración Avanzada'),
            ),
          ),
        ],
      ),
    );
  }

  /// Opción de alerta
  Widget _buildAlertOption(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // TODO: Implementar cambio de configuración
            },
          ),
        ],
      ),
    );
  }

  /// Obtener color de la señal
  Color _getSignalColor(String type) {
    switch (type.toLowerCase()) {
      case 'strong_buy':
        return QuantixTheme.strongBuy;
      case 'buy':
        return QuantixTheme.buy;
      case 'hold':
        return QuantixTheme.hold;
      case 'sell':
        return QuantixTheme.sell;
      case 'strong_sell':
        return QuantixTheme.strongSell;
      default:
        return QuantixTheme.neutralGray;
    }
  }
}
