import 'package:flutter/material.dart';

/// Menú flotante innovador para QUANTIX
class QuantixFloatingMenu extends StatefulWidget {
  final List<QuantixMenuItem> items;
  final VoidCallback? onAIButtonPressed;
  const QuantixFloatingMenu({
    super.key,
    required this.items,
    this.onAIButtonPressed,
  });

  @override
  State<QuantixFloatingMenu> createState() => _QuantixFloatingMenuState();
}

class _QuantixFloatingMenuState extends State<QuantixFloatingMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double radius = 90;
    final double aiOffset = 70;
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Orbital menu items
        ...List.generate(widget.items.length, (i) {
          final angle = (i / widget.items.length) * 2 * 3.1416;
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final offset = Offset(
                -radius * _animation.value * (1 - i / widget.items.length) * (i.isEven ? 1 : 0.7) * (i.isEven ? 1 : -1) * (i % 2 == 0 ? 1 : 0.8),
                -radius * _animation.value * (i / widget.items.length) * (i.isEven ? 1 : 0.7),
              );
              return Positioned(
                right: 24 + offset.dx,
                bottom: 24 + offset.dy,
                child: Opacity(
                  opacity: _animation.value,
                  child: child,
                ),
              );
            },
            child: FloatingActionButton(
              heroTag: 'menu_item_$i',
              backgroundColor: Colors.yellow,
              mini: true,
              onPressed: widget.items[i].onTap,
              child: Icon(widget.items[i].icon, color: Colors.black),
              tooltip: widget.items[i].label,
            ),
          );
        }),
        // AI Button (above main FAB)
        Positioned(
          right: 24,
          bottom: 24 + aiOffset,
          child: FloatingActionButton(
            heroTag: 'ai_button',
            backgroundColor: Colors.yellow,
            mini: false,
            onPressed: widget.onAIButtonPressed,
            child: const Icon(Icons.smart_toy, color: Colors.black, size: 32),
            tooltip: 'AI Assistant',
            elevation: 6,
          ),
        ),
        // Main FAB
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            heroTag: 'main_menu',
            backgroundColor: Colors.black,
            mini: false,
            onPressed: _toggleMenu,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isOpen
                  ? const Icon(Icons.close, color: Colors.yellow, size: 32)
                  : const Icon(Icons.menu, color: Colors.yellow, size: 32),
            ),
            tooltip: 'Menú Principal',
            elevation: 8,
          ),
        ),
      ],
    );
  }
}

class QuantixMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  QuantixMenuItem({required this.icon, required this.label, required this.onTap});
}
