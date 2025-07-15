import 'package:flutter/material.dart';
import '../../../ui/theme/app_colors.dart';

/// Widget flotante estilo menu desplegable para acceso rápido a funciones
class FloatingMenuWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onApiConfig;
  final VoidCallback onIndicatorConfig;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  const FloatingMenuWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onApiConfig,
    required this.onIndicatorConfig,
    required this.onSettings,
    required this.onHelp,
  });

  @override
  State<FloatingMenuWidget> createState() => _FloatingMenuWidgetState();
}

class _FloatingMenuWidgetState extends State<FloatingMenuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animation);
  }

  @override
  void didUpdateWidget(FloatingMenuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Opciones del menú
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _animation,
              axisAlignment: 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuOption(
                    'Configurar APIs',
                    Icons.api,
                    Colors.blue,
                    widget.onApiConfig,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuOption(
                    'Indicadores',
                    Icons.show_chart,
                    Colors.green,
                    widget.onIndicatorConfig,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuOption(
                    'Configuración',
                    Icons.settings,
                    Colors.orange,
                    widget.onSettings,
                  ),
                  const SizedBox(height: 8),
                  _buildMenuOption(
                    'Ayuda',
                    Icons.help,
                    Colors.purple,
                    widget.onHelp,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
        
        // Botón principal del menú
        GestureDetector(
          onTap: widget.onToggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.goldPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: widget.isExpanded ? 0.375 : 0.0, // 135 grados
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.add,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          onTap();
          widget.onToggle(); // Cerrar menú después de seleccionar
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
