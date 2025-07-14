import 'package:flutter/material.dart';
import 'dart:math';

/// Componente de menú orbital flotante para navegación principal
class OrbitalMenu extends StatefulWidget {
  final List<OrbitalMenuItem> items;
  final Color primaryColor;
  final Color secondaryColor;
  final double orbitRadius;
  final Duration animationDuration;
  final Function(int index)? onItemTap;

  const OrbitalMenu({
    super.key,
    required this.items,
    this.primaryColor = const Color(0xFFFFD700),
    this.secondaryColor = const Color(0xFF1A1A1A),
    this.orbitRadius = 120.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onItemTap,
  });

  @override
  State<OrbitalMenu> createState() => _OrbitalMenuState();
}

class _OrbitalMenuState extends State<OrbitalMenu>
    with TickerProviderStateMixin {
  
  late AnimationController _rotationController;
  late AnimationController _expansionController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _expansionAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isExpanded = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Controlador de rotación continua
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    // Controlador de expansión/contracción
    _expansionController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Animación de rotación continua
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Animación de expansión
    _expansionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.elasticOut,
    ));

    // Animación de escala del botón central
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _expansionController,
      curve: Curves.elasticOut,
    ));

    // Iniciar rotación continua
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _expansionController.dispose();
    super.dispose();
  }

  void _toggleMenu() async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      await _expansionController.forward();
    } else {
      await _expansionController.reverse();
    }

    setState(() {
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _expansionAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return SizedBox(
          width: widget.orbitRadius * 3,
          height: widget.orbitRadius * 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Órbita de fondo
              _buildOrbitBackground(),
              
              // Elementos orbitales
              ..._buildOrbitalItems(),
              
              // Botón central
              _buildCentralButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitBackground() {
    return Container(
      width: widget.orbitRadius * 2,
      height: widget.orbitRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitalItems() {
    List<Widget> items = [];
    
    for (int i = 0; i < widget.items.length; i++) {
      final angle = (2 * pi / widget.items.length) * i;
      final item = widget.items[i];
      
      // Posición del elemento en la órbita
      final x = widget.orbitRadius * cos(angle + _rotationAnimation.value);
      final y = widget.orbitRadius * sin(angle + _rotationAnimation.value);
      
      items.add(
        Positioned(
          left: (widget.orbitRadius * 3 / 2) + x - 30,
          top: (widget.orbitRadius * 3 / 2) + y - 30,
          child: Transform.scale(
            scale: _expansionAnimation.value,
            child: _buildOrbitalItem(item, i),
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildOrbitalItem(OrbitalMenuItem item, int index) {
    return GestureDetector(
      onTap: () => _onItemTap(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              item.color ?? widget.primaryColor,
              (item.color ?? widget.primaryColor).withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: (item.color ?? widget.primaryColor).withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: Colors.white,
              size: 24,
            ),
            if (item.label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCentralButton() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.primaryColor,
                widget.primaryColor.withValues(alpha: 0.8),
                widget.secondaryColor,
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withValues(alpha: 0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            _isExpanded ? Icons.close : Icons.menu,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _onItemTap(int index) {
    if (!_isExpanded || _isAnimating) return;
    
    // Animación de feedback
    final item = widget.items[index];
    
    // Cerrar menú
    _toggleMenu();
    
    // Callback
    widget.onItemTap?.call(index);
  }
}

/// Elemento del menú orbital
class OrbitalMenuItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const OrbitalMenuItem({
    required this.icon,
    this.label = '',
    this.color,
    this.onTap,
  });
}

/// Widget de posicionamiento para el menú orbital
class OrbitalMenuWidget extends StatelessWidget {
  final Widget child;
  final OrbitalMenu orbitalMenu;
  final Alignment alignment;

  const OrbitalMenuWidget({
    super.key,
    required this.child,
    required this.orbitalMenu,
    this.alignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal
          child,
          
          // Menú orbital posicionado
          Positioned(
            right: alignment == Alignment.bottomRight ? 20 : null,
            bottom: alignment == Alignment.bottomRight ? 80 : null,
            left: alignment == Alignment.bottomLeft ? 20 : null,
            top: alignment == Alignment.topRight ? 80 : null,
            child: orbitalMenu,
          ),
        ],
      ),
    );
  }
}

/// Configuración predeterminada para Invictus Trader Pro
class InvictusOrbitalMenu {
  static List<OrbitalMenuItem> getDefaultItems() {
    return [
      const OrbitalMenuItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        color: Color(0xFF2196F3),
      ),
      const OrbitalMenuItem(
        icon: Icons.trending_up,
        label: 'Trading',
        color: Color(0xFF4CAF50),
      ),
      const OrbitalMenuItem(
        icon: Icons.notifications,
        label: 'Alertas',
        color: Color(0xFFFF9800),
      ),
      const OrbitalMenuItem(
        icon: Icons.newspaper,
        label: 'Noticias',
        color: Color(0xFF9C27B0),
      ),
      const OrbitalMenuItem(
        icon: Icons.extension,
        label: 'Plugins',
        color: Color(0xFFE91E63),
      ),
      const OrbitalMenuItem(
        icon: Icons.settings,
        label: 'Config',
        color: Color(0xFF607D8B),
      ),
    ];
  }

  static OrbitalMenu create({
    required Function(int index) onItemTap,
  }) {
    return OrbitalMenu(
      items: getDefaultItems(),
      primaryColor: const Color(0xFFFFD700),
      secondaryColor: const Color(0xFF1A1A1A),
      orbitRadius: 100.0,
      animationDuration: const Duration(milliseconds: 600),
      onItemTap: onItemTap,
    );
  }
}

/// Extensiones para efectos adicionales
extension OrbitalMenuEffects on _OrbitalMenuState {
  
  /// Efecto de pulso para el botón central
  void startPulseEffect() {
    _expansionController.repeat(reverse: true);
  }
  
  /// Detener efecto de pulso
  void stopPulseEffect() {
    _expansionController.stop();
    _expansionController.reset();
  }
  
  /// Cambiar velocidad de rotación
  void setRotationSpeed(Duration duration) {
    _rotationController.duration = duration;
    if (_rotationController.isAnimating) {
      _rotationController.repeat();
    }
  }
}

/// Indicador de estado para elementos del menú
class OrbitalMenuBadge extends StatelessWidget {
  final Widget child;
  final int? count;
  final bool showDot;
  final Color badgeColor;

  const OrbitalMenuBadge({
    super.key,
    required this.child,
    this.count,
    this.showDot = false,
    this.badgeColor = const Color(0xFFFF4444),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showDot || (count != null && count! > 0))
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: count != null && count! > 0
                  ? Text(
                      count! > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}
