import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget que posiciona elementos en órbita circular animada
class OrbitalWidget extends StatelessWidget {
  final Offset center;
  final double radius;
  final double angle;
  final Widget child;

  const OrbitalWidget({
    Key? key,
    required this.center,
    required this.radius,
    required this.angle,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular posición basada en el centro, radio y ángulo
        final centerX = constraints.maxWidth * center.dx;
        final centerY = constraints.maxHeight * center.dy;
        
        final orbitalRadius = math.min(constraints.maxWidth, constraints.maxHeight) * radius;
        
        final x = centerX + orbitalRadius * math.cos(angle);
        final y = centerY + orbitalRadius * math.sin(angle);
        
        return Stack(
          children: [
            Positioned(
              left: x - 35, // Ajustar por el tamaño del widget hijo
              top: y - 35,
              child: child,
            ),
          ],
        );
      },
    );
  }
}

/// Widget para crear una órbita completa con múltiples elementos
class MultiOrbitalWidget extends StatelessWidget {
  final List<OrbitalElement> elements;
  final Offset center;
  final double baseRadius;
  final double animationValue;

  const MultiOrbitalWidget({
    Key? key,
    required this.elements,
    required this.center,
    required this.baseRadius,
    required this.animationValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: elements.asMap().entries.map((entry) {
        final index = entry.key;
        final element = entry.value;
        
        final angleOffset = (2 * math.pi / elements.length) * index;
        final totalAngle = (animationValue * 2 * math.pi) + angleOffset + element.baseAngle;
        
        return OrbitalWidget(
          center: center,
          radius: baseRadius * element.radiusMultiplier,
          angle: totalAngle,
          child: element.child,
        );
      }).toList(),
    );
  }
}

/// Elemento individual de una órbita
class OrbitalElement {
  final Widget child;
  final double radiusMultiplier;
  final double baseAngle;

  const OrbitalElement({
    required this.child,
    this.radiusMultiplier = 1.0,
    this.baseAngle = 0.0,
  });
}

/// Widget especializado para indicadores técnicos orbitales
class TechnicalIndicatorOrbit extends StatelessWidget {
  final double animationValue;
  final List<IndicatorOrbData> indicators;

  const TechnicalIndicatorOrbit({
    Key? key,
    required this.animationValue,
    required this.indicators,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiOrbitalWidget(
      center: const Offset(0.5, 0.5),
      baseRadius: 0.3,
      animationValue: animationValue,
      elements: indicators.map((indicator) {
        return OrbitalElement(
          child: _buildIndicatorOrb(indicator),
          radiusMultiplier: indicator.radiusMultiplier,
          baseAngle: indicator.baseAngle,
        );
      }).toList(),
    );
  }

  Widget _buildIndicatorOrb(IndicatorOrbData indicator) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: indicator.color.withOpacity(0.1),
        border: Border.all(
          color: indicator.color.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: indicator.color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            indicator.name,
            style: TextStyle(
              color: indicator.color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            indicator.value,
            style: TextStyle(
              color: indicator.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Datos para un indicador orbital
class IndicatorOrbData {
  final String name;
  final String value;
  final Color color;
  final double radiusMultiplier;
  final double baseAngle;

  const IndicatorOrbData({
    required this.name,
    required this.value,
    required this.color,
    this.radiusMultiplier = 1.0,
    this.baseAngle = 0.0,
  });
}

/// Widget para crear patrones de órbita más complejos
class AdvancedOrbitalSystem extends StatelessWidget {
  final double primaryAnimationValue;
  final double secondaryAnimationValue;
  final Widget centerWidget;
  final List<OrbitalRing> rings;

  const AdvancedOrbitalSystem({
    Key? key,
    required this.primaryAnimationValue,
    required this.secondaryAnimationValue,
    required this.centerWidget,
    required this.rings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Renderizar cada anillo orbital
        ...rings.map((ring) {
          return MultiOrbitalWidget(
            center: const Offset(0.5, 0.5),
            baseRadius: ring.radius,
            animationValue: ring.clockwise 
                ? primaryAnimationValue * ring.speed
                : -primaryAnimationValue * ring.speed,
            elements: ring.elements,
          );
        }),
        
        // Widget central
        Center(child: centerWidget),
      ],
    );
  }
}

/// Anillo orbital con múltiples elementos
class OrbitalRing {
  final double radius;
  final double speed;
  final bool clockwise;
  final List<OrbitalElement> elements;

  const OrbitalRing({
    required this.radius,
    required this.elements,
    this.speed = 1.0,
    this.clockwise = true,
  });
}

/// Widget con efectos de pulsación orbital
class PulsatingOrbitalWidget extends StatelessWidget {
  final double animationValue;
  final double pulseValue;
  final Widget child;
  final Offset center;
  final double radius;
  final double angle;

  const PulsatingOrbitalWidget({
    Key? key,
    required this.animationValue,
    required this.pulseValue,
    required this.child,
    required this.center,
    required this.radius,
    required this.angle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pulsatingRadius = radius * (1.0 + (pulseValue * 0.2));
    
    return OrbitalWidget(
      center: center,
      radius: pulsatingRadius,
      angle: angle,
      child: Transform.scale(
        scale: 1.0 + (pulseValue * 0.3),
        child: child,
      ),
    );
  }
}
