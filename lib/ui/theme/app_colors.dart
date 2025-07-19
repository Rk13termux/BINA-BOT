import 'package:flutter/material.dart';

/// Paleta de colores profesional para Invictus Trader Pro
class AppColors {
  // === COLORES PRINCIPALES ===
  
  /// Color negro principal - Fondo principal de la aplicación
  static const Color primaryDark = Color(0xFF000000);
  
  /// Color dorado principal - Acentos y elementos importantes
  static const Color goldPrimary = Color(0xFFFFD700);
  
  /// Variante dorada más oscura
  static const Color goldSecondary = Color(0xFFB8860B);
  
  /// Color dorado suave para fondos
  static const Color goldLight = Color(0xFFFFF8DC);

  // === COLORES DE TRADING ===
  
  /// Verde alcista - Para precios en alza y señales positivas
  static const Color bullishGreen = Color(0xFF00FF88);
  
  /// Verde alcista oscuro
  static const Color bullishGreenDark = Color(0xFF00CC6A);
  
  /// Rojo bajista - Para precios en baja y señales negativas
  static const Color bearishRed = Color(0xFFFF4444);
  
  /// Rojo bajista oscuro
  static const Color bearishRedDark = Color(0xFFCC3333);
  
  /// Alias para verde alcista (compatibilidad con widgets)
  static const Color bullish = bullishGreen;
  
  /// Alias para rojo bajista (compatibilidad con widgets)
  static const Color bearish = bearishRed;
  
  /// Fondo oscuro para dashboards/widgets
  static const Color surfaceDark = backgroundTertiary;

  // === COLORES DE FONDO ===
  
  /// Fondo secundario - Cards y contenedores
  static const Color backgroundSecondary = Color(0xFF0A0A0A);
  
  /// Fondo terciario - Elementos elevados
  static const Color backgroundTertiary = Color(0xFF1A1A1A);
  
  /// Fondo para surfaces
  static const Color surface = Color(0xFF000000);
  
  /// Fondo para elementos flotantes
  static const Color surfaceVariant = Color(0xFF0F0F0F);

  // === COLORES DE TEXTO ===
  
  /// Texto principal - Blanco puro
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// Texto secundario - Blanco con opacidad
  static const Color textSecondary = Color(0xB3FFFFFF);
  
  /// Texto terciario - Blanco con menos opacidad
  static const Color textTertiary = Color(0x80FFFFFF);
  
  /// Texto deshabilitado
  static const Color textDisabled = Color(0x4DFFFFFF);

  // === COLORES DE CATEGORÍAS DE INDICADORES ===
  
  /// Azul para indicadores de tendencia
  static const Color trendBlue = Color(0xFF2196F3);
  
  /// Naranja para indicadores de momentum
  static const Color momentumOrange = Color(0xFFFF9800);
  
  /// Verde para indicadores de volumen
  static const Color volumeGreen = Color(0xFF4CAF50);
  
  /// Púrpura para indicadores de volatilidad
  static const Color volatilityPurple = Color(0xFF9C27B0);
  
  /// Rojo para indicadores compuestos/IA
  static const Color compositeRed = Color(0xFFE91E63);

  // === COLORES DE ESTADO ===
  
  /// Éxito - Verde estándar
  static const Color success = Color(0xFF4CAF50);
  
  /// Advertencia - Ámbar estándar
  static const Color warning = Color(0xFFFFC107);
  
  /// Error - Rojo estándar
  static const Color error = Color(0xFFF44336);
  
  /// Información - Azul estándar
  static const Color info = Color(0xFF2196F3);

  // === COLORES DE BORDES Y DIVISORES ===
  
  /// Borde principal
  static const Color border = Color(0xFF222222);
  
  /// Borde secundario
  static const Color borderSecondary = Color(0xFF333333);
  
  /// Divisor
  static const Color divider = Color(0xFF111111);

  // === GRADIENTES PREDEFINIDOS ===
  
  /// Gradiente dorado principal
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldPrimary, goldSecondary],
  );
  
  /// Gradiente de fondo principal
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000000), Color(0xFF0A0A0A)],
  );
  
  /// Gradiente alcista
  static const LinearGradient bullishGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bullishGreen, bullishGreenDark],
  );
  
  /// Gradiente bajista
  static const LinearGradient bearishGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bearishRed, bearishRedDark],
  );

  // === COLORES CON OPACIDAD ===
  
  /// Dorado con 10% de opacidad
  static Color get goldWithOpacity10 => goldPrimary.withOpacity(0.1);
  
  /// Dorado con 20% de opacidad
  static Color get goldWithOpacity20 => goldPrimary.withOpacity(0.2);
  
  /// Dorado con 30% de opacidad
  static Color get goldWithOpacity30 => goldPrimary.withOpacity(0.3);
  
  /// Verde alcista con 10% de opacidad
  static Color get bullishWithOpacity10 => bullishGreen.withOpacity(0.1);
  
  /// Verde alcista con 20% de opacidad
  static Color get bullishWithOpacity20 => bullishGreen.withOpacity(0.2);
  
  /// Rojo bajista con 10% de opacidad
  static Color get bearishWithOpacity10 => bearishRed.withOpacity(0.1);
  
  /// Rojo bajista con 20% de opacidad
  static Color get bearishWithOpacity20 => bearishRed.withOpacity(0.2);

  // === MÉTODOS AUXILIARES ===
  
  /// Obtiene color basado en cambio porcentual
  static Color getColorFromPercentage(double percentage) {
    if (percentage > 0) return bullishGreen;
    if (percentage < 0) return bearishRed;
    return textSecondary;
  }
  
  /// Obtiene color de indicador basado en tendencia
  static Color getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'bullish':
      case 'alcista':
        return bullishGreen;
      case 'bearish':
      case 'bajista':
        return bearishRed;
      default:
        return goldPrimary;
    }
  }
  
  /// Obtiene color de categoría de indicador
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'trend':
      case 'tendencia':
        return trendBlue;
      case 'momentum':
        return momentumOrange;
      case 'volume':
      case 'volumen':
        return volumeGreen;
      case 'volatility':
      case 'volatilidad':
        return volatilityPurple;
      case 'composite':
      case 'ai':
      case 'compuesto':
        return compositeRed;
      default:
        return goldPrimary;
    }
  }
  
  /// Obtiene color con opacidad personalizada
  static Color withCustomOpacity(Color color, double opacity) {
    return color.withOpacity(opacity.clamp(0.0, 1.0));
  }

  // === ESQUEMAS DE COLOR PARA TEMAS ===
  
  /// Esquema de color principal para Material 3
  static const ColorScheme colorScheme = ColorScheme.dark(
    primary: goldPrimary,
    onPrimary: primaryDark,
    secondary: goldSecondary,
    onSecondary: primaryDark,
    surface: surface,
    onSurface: textPrimary,
    background: primaryDark,
    onBackground: textPrimary,
    error: error,
    onError: textPrimary,
  );

  // === CONSTANTES PARA ANIMACIONES ===
  
  /// Duración estándar de animaciones
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  /// Duración rápida de animaciones
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  
  /// Duración lenta de animaciones
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // === SHADOWS Y ELEVACIONES ===
  
  /// Sombra dorada suave
  static BoxShadow get goldShadow => BoxShadow(
    color: goldPrimary.withOpacity(0.3),
    blurRadius: 10,
    spreadRadius: 2,
  );
  
  /// Sombra estándar
  static BoxShadow get standardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.2),
    blurRadius: 8,
    spreadRadius: 1,
    offset: const Offset(0, 2),
  );
  
  /// Sombra elevada
  static BoxShadow get elevatedShadow => BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 15,
    spreadRadius: 3,
    offset: const Offset(0, 5),
  );
}
