import 'package:flutter/material.dart';

/// Paleta de colores BINA-BOT PRO - Diseño profesional negro exclusivo
class AppColors {
  // Colores principales - Black theme profesional completo
  static const Color backgroundBlack = Color(0xFF000000); // Negro puro principal
  static const Color primaryDark = Color(0xFF000000); // Negro principal
  static const Color secondaryDark = Color(0xFF111111); // Negro secondary
  static const Color surfaceDark = Color(0xFF0A0A0A); // Superficie oscura

  // Colores de acento - Dorado profesional
  static const Color goldPrimary = Color(0xFFFFD700); // Dorado principal
  static const Color goldSecondary = Color(0xFFFFC107); // Dorado secundario
  static const Color goldAccent = Color(0xFFFFE082); // Dorado claro
  static const Color goldDeep = Color(0xFFB8860B); // Dorado profundo

  // Colores de trading profesionales
  static const Color bullish = Color(0xFF00FF88); // Verde neón profesional
  static const Color bearish = Color(0xFFFF4444); // Rojo profesional
  static const Color warning = Color(0xFFFF9800); // Naranja
  static const Color info = Color(0xFF2196F3); // Azul
  static const Color success = Color(0xFF4CAF50); // Verde
  static const Color neutral = Color(0xFF666666); // Gris neutral

  // Colores de texto profesionales
  static const Color textPrimary = Color(0xFFFFFFFF); // Blanco puro
  static const Color textSecondary = Color(0xFFCCCCCC); // Gris claro
  static const Color textHint = Color(0xFF666666); // Texto hint
  static const Color textDisabled = Color(0xFF333333); // Texto deshabilitado

  // Colores de superficie y bordes
  static const Color border = Color(0xFF222222); // Bordes sutiles
  static const Color borderColor = Color(0xFF222222); // Alias para border
  static const Color divider = Color(0xFF111111); // Divisores
  static const Color dividerColor = Color(0xFF111111); // Alias para divider
  static const Color cardBackground = Color(0xFF0A0A0A); // Fondo de tarjetas
  static const Color error = Color(0xFFFF4444); // Color de error
  
  // Sombras exclusivas
  static const Color premiumShadow = Color(0x40FFD700); // Sombra dorada
  static const Color darkShadow = Color(0x80000000); // Sombra negra

  // BoxShadows predefinidas para efectos premium
  static const List<BoxShadow> premiumBoxShadows = [
    BoxShadow(
      color: Color(0x40FFD700),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Gradientes exclusivos BINA-BOT PRO
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDeep, goldPrimary, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [backgroundBlack, primaryDark, secondaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bullishGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bearishGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Efectos especiales para diseño exclusivo
  static const RadialGradient logoGradient = RadialGradient(
    colors: [goldPrimary, goldSecondary, goldDeep],
    center: Alignment.center,
    radius: 0.8,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Colores específicos para el trading
  static const Color orderBuy = Color(0xFF00FF88);
  static const Color orderSell = Color(0xFFFF4444);
  static const Color profit = Color(0xFF4CAF50);
  static const Color loss = Color(0xFFFF5252);

  // Métodos de utilidad
  static Color withAlpha(Color color, int alpha) {
    return color.withValues(alpha: alpha / 255.0);
  }

  /// Obtiene el color según el cambio de precio
  static Color getPriceChangeColor(double change) {
    if (change > 0) return bullish;
    if (change < 0) return bearish;
    return neutral;
  }

  /// Obtiene el gradiente según el tipo de operación
  static LinearGradient getTradeGradient(bool isBuy) {
    return isBuy ? bullishGradient : bearishGradient;
  }

  /// Colores para gráficos
  static const List<Color> chartColors = [
    goldPrimary,
    bullish,
    bearish,
    warning,
    info,
    success,
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];
}
