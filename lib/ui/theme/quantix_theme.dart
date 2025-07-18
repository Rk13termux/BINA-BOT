import 'package:flutter/material.dart';

/// QUANTIX AI CORE - Tema Visual Profesional
/// "Piensa como fondo, opera como elite."
class QuantixTheme {
  // 🎨 Paleta de Colores Principal
  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color cardBlack = Color(0xFF2A2A2A);
  
  // Dorado Elite
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color lightGold = Color(0xFFFFF8DC);
  static const Color darkGold = Color(0xFFB8860B);
  
  // Azul Eléctrico
  static const Color electricBlue = Color(0xFF00D4FF);
  static const Color lightElectricBlue = Color(0xFF4DE6FF);
  static const Color darkElectricBlue = Color(0xFF0099CC);
  
  // Estados del Trading
  static const Color bullishGreen = Color(0xFF00FF88);
  static const Color bearishRed = Color(0xFFFF4444);
  static const Color neutralGray = Color(0xFF6C6C6C);
  
  // 🎨 Gradientes
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, lightGold, primaryGold],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [electricBlue, lightElectricBlue],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryBlack, secondaryBlack, cardBlack],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🎨 Tema Principal
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Esquema de colores
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: electricBlue,
        surface: cardBlack,
        onPrimary: primaryBlack,
        onSecondary: primaryBlack,
        onSurface: lightGold,
        error: bearishRed,
        onError: primaryBlack,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: primaryBlack,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: secondaryBlack,
        foregroundColor: primaryGold,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: primaryGold,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: cardBlack,
        elevation: 8,
        shadowColor: primaryGold.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Botones Elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: primaryBlack,
          elevation: 8,
          shadowColor: primaryGold.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // Botones de Texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: electricBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // Botones Outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: primaryBlack,
        elevation: 12,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutralGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neutralGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 2),
        ),
        labelStyle: const TextStyle(color: neutralGray),
        hintStyle: const TextStyle(color: neutralGray),
      ),
      
      // Texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: primaryGold,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: primaryGold,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: primaryGold,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          color: lightGold,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: lightGold,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          color: lightGold,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          color: lightGold,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: lightGold,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: neutralGray,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: lightGold,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: lightGold,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: neutralGray,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: neutralGray,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: neutralGray,
          fontSize: 10,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryGold,
        size: 24,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: neutralGray.withValues(alpha: 0.3),
        thickness: 1,
      ),
      
      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGold,
        unselectedLabelColor: neutralGray,
        indicatorColor: primaryGold,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGold;
          }
          return neutralGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGold.withValues(alpha: 0.3);
          }
          return neutralGray.withValues(alpha: 0.3);
        }),
      ),
      
      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
        linearTrackColor: neutralGray,
      ),
    );
  }

  // 🎨 Decoraciones Especiales
  static BoxDecoration get eliteCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [cardBlack, secondaryBlack],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: primaryGold.withValues(alpha: 0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryGold.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get premiumCardDecoration => BoxDecoration(
    gradient: blueGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: electricBlue.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get aiCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryGold, electricBlue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryGold.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // 🎨 Colores de Indicadores Técnicos
  static const Color buySignal = bullishGreen;
  static const Color sellSignal = bearishRed;
  static const Color holdSignal = neutralGray;
  static const Color strongBuy = Color(0xFF00CC66);
  static const Color strongSell = Color(0xFFCC0000);
  
  // Alias para compatibilidad
  static const Color buy = buySignal;
  static const Color sell = sellSignal;
  static const Color hold = holdSignal;
  
  // Colores de indicadores por categorías
  static const Map<String, Color> indicatorColors = {
    'bullish': bullishGreen,
    'bearish': bearishRed,
    'neutral': neutralGray,
    'buy': buySignal,
    'sell': sellSignal,
    'hold': holdSignal,
  };
  
  // 🎨 Colores de Timeframes
  static const Color timeframe1m = Color(0xFF4CAF50);
  static const Color timeframe5m = Color(0xFF8BC34A);
  static const Color timeframe15m = Color(0xFFCDDC39);
  static const Color timeframe1h = Color(0xFFFFEB3B);
  static const Color timeframe4h = Color(0xFFFF9800);
  static const Color timeframe1d = Color(0xFFFF5722);
  
  // 🎨 Animaciones
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation = Duration(milliseconds: 800);
  
  // 🎨 Curvas de Animación
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve fastCurve = Curves.easeInOut;
}
