import 'package:flutter/material.dart';

/// Paleta de colores del tema Invictus Trader Pro
class AppColors {
  // Colores principales - Dark theme con acentos dorados
  static const Color primaryDark = Color(0xFF1A1A1A);      // Negro principal
  static const Color secondaryDark = Color(0xFF2D2D2D);    // Gris oscuro
  static const Color surfaceDark = Color(0xFF1E1E1E);      // Superficie oscura
  
  // Colores de acento - Dorado premium
  static const Color goldPrimary = Color(0xFFFFD700);      // Dorado principal
  static const Color goldSecondary = Color(0xFFFFB800);    // Dorado secundario
  static const Color goldLight = Color(0xFFFFF8DC);        // Dorado claro
  
  // Colores de trading
  static const Color bullish = Color(0xFF00FF88);          // Verde alcista
  static const Color bearish = Color(0xFFFF4444);          // Rojo bajista
  static const Color warning = Color(0xFFFFB800);          // Amarillo advertencia
  static const Color neutral = Color(0xFF888888);          // Gris neutral
  
  // Colores de texto
  static const Color textPrimary = Color(0xFFFFFFFF);      // Blanco principal
  static const Color textSecondary = Color(0xFFB0B0B0);    // Gris claro
  static const Color textDisabled = Color(0xFF666666);     // Gris deshabilitado
  
  // Colores de estado
  static const Color success = Color(0xFF4CAF50);          // Verde éxito
  static const Color error = Color(0xFFF44336);            // Rojo error
  static const Color info = Color(0xFF2196F3);             // Azul información
  
  // Colores adicionales
  static const Color cardBackground = Color(0xFF252525);    // Fondo de tarjetas
  static const Color borderColor = Color(0xFF404040);      // Color de bordes
  static const Color dividerColor = Color(0xFF333333);     // Color divisores
  
  // Gradientes
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldSecondary, goldPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryDark, secondaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient bullishGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00CC66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient bearishGradient = LinearGradient(
    colors: [Color(0xFFFF4444), Color(0xFFCC2222)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Obtiene el color según el cambio de precio
  static Color getPriceChangeColor(double change) {
    if (change > 0) return bullish;
    if (change < 0) return bearish;
    return neutral;
  }

  /// Obtiene el color de confianza de señal
  static Color getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
      case 'veryhigh':
        return success;
      case 'medium':
        return warning;
      case 'low':
        return error;
      default:
        return neutral;
    }
  }

  /// Colores para gráficos
  static const List<Color> chartColors = [
    Color(0xFFFFD700), // Dorado
    Color(0xFF00FF88), // Verde
    Color(0xFF2196F3), // Azul
    Color(0xFFFF4444), // Rojo
    Color(0xFFFFB800), // Naranja
    Color(0xFF9C27B0), // Púrpura
    Color(0xFF00BCD4), // Cian
    Color(0xFFFF9800), // Naranja oscuro
  ];
}
