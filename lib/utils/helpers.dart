import 'dart:math';
import 'package:intl/intl.dart';

/// Funciones de ayuda y utilidades para la aplicación
class AppHelpers {
  
  /// Formatea números grandes con sufijos (K, M, B, T)
  static String formatLargeNumber(double number) {
    if (number < 1000) {
      return number.toStringAsFixed(2);
    } else if (number < 1000000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number < 1000000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else {
      return '${(number / 1000000000000).toStringAsFixed(1)}T';
    }
  }
  
  /// Formatea precios con la precisión adecuada
  static String formatPrice(double price, {int? decimals}) {
    if (decimals != null) {
      return price.toStringAsFixed(decimals);
    }
    
    // Auto-determinar decimales basado en el precio
    if (price >= 1000) {
      return price.toStringAsFixed(2);
    } else if (price >= 100) {
      return price.toStringAsFixed(2);
    } else if (price >= 10) {
      return price.toStringAsFixed(3);
    } else if (price >= 1) {
      return price.toStringAsFixed(4);
    } else if (price >= 0.01) {
      return price.toStringAsFixed(6);
    } else {
      return price.toStringAsFixed(8);
    }
  }
  
  /// Formatea porcentajes
  static String formatPercentage(double percentage, {int decimals = 2}) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(decimals)}%';
  }
  
  /// Formatea fecha y hora
  static String formatDateTime(DateTime dateTime, {bool includeTime = true}) {
    if (includeTime) {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
  
  /// Formatea tiempo relativo (hace X minutos, horas, etc.)
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDateTime(dateTime, includeTime: false);
    }
  }
  
  /// Calcula el cambio porcentual entre dos valores
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }
  
  /// Valida dirección de email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  /// Valida contraseña segura
  static bool isValidPassword(String password) {
    // Al menos 8 caracteres, una mayúscula, una minúscula, un número
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }
  
  /// Genera un ID único
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
           Random().nextInt(9999).toString().padLeft(4, '0');
  }
  
  /// Trunca texto con elipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Capitaliza la primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Convierte símbolo de trading a formato legible
  static String formatTradingPair(String symbol) {
    // Convierte "BTCUSDT" a "BTC/USDT"
    if (symbol.endsWith('USDT')) {
      final base = symbol.substring(0, symbol.length - 4);
      return '$base/USDT';
    } else if (symbol.endsWith('BTC')) {
      final base = symbol.substring(0, symbol.length - 3);
      return '$base/BTC';
    } else if (symbol.endsWith('ETH')) {
      final base = symbol.substring(0, symbol.length - 3);
      return '$base/ETH';
    }
    return symbol;
  }
  
  /// Calcula media móvil simple (SMA)
  static List<double> calculateSMA(List<double> prices, int period) {
    if (prices.length < period) return [];
    
    final sma = <double>[];
    for (int i = period - 1; i < prices.length; i++) {
      double sum = 0;
      for (int j = i - period + 1; j <= i; j++) {
        sum += prices[j];
      }
      sma.add(sum / period);
    }
    return sma;
  }
  
  /// Calcula media móvil exponencial (EMA)
  static List<double> calculateEMA(List<double> prices, int period) {
    if (prices.isEmpty) return [];
    
    final ema = <double>[];
    final multiplier = 2.0 / (period + 1);
    
    // Primer valor es el precio inicial
    ema.add(prices[0]);
    
    for (int i = 1; i < prices.length; i++) {
      final emaValue = (prices[i] * multiplier) + (ema[i - 1] * (1 - multiplier));
      ema.add(emaValue);
    }
    return ema;
  }
  
  /// Calcula RSI (Relative Strength Index)
  static List<double> calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return [];
    
    final rsi = <double>[];
    final gains = <double>[];
    final losses = <double>[];
    
    // Calcular ganancias y pérdidas
    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }
    
    // Calcular RSI
    for (int i = period - 1; i < gains.length; i++) {
      double avgGain = 0;
      double avgLoss = 0;
      
      // Promedio de ganancias y pérdidas
      for (int j = i - period + 1; j <= i; j++) {
        avgGain += gains[j];
        avgLoss += losses[j];
      }
      avgGain /= period;
      avgLoss /= period;
      
      final rs = avgLoss == 0 ? 100 : avgGain / avgLoss;
      final rsiValue = 100 - (100 / (1 + rs));
      rsi.add(rsiValue);
    }
    
    return rsi;
  }
  
  /// Calcula bandas de Bollinger
  static Map<String, List<double>> calculateBollingerBands(
    List<double> prices, 
    int period, 
    double standardDeviations
  ) {
    final sma = calculateSMA(prices, period);
    final upperBand = <double>[];
    final lowerBand = <double>[];
    
    for (int i = 0; i < sma.length; i++) {
      final dataIndex = i + period - 1;
      
      // Calcular desviación estándar
      double sumSquaredDiffs = 0;
      for (int j = dataIndex - period + 1; j <= dataIndex; j++) {
        final diff = prices[j] - sma[i];
        sumSquaredDiffs += diff * diff;
      }
      final stdDev = sqrt(sumSquaredDiffs / period);
      
      upperBand.add(sma[i] + (standardDeviations * stdDev));
      lowerBand.add(sma[i] - (standardDeviations * stdDev));
    }
    
    return {
      'upper': upperBand,
      'middle': sma,
      'lower': lowerBand,
    };
  }
  
  /// Valida cantidad de trading
  static bool isValidTradeAmount(double amount, double minAmount, double maxAmount) {
    return amount >= minAmount && amount <= maxAmount;
  }
  
  /// Calcula el tamaño de posición basado en el riesgo
  static double calculatePositionSize(
    double accountBalance,
    double riskPercentage,
    double entryPrice,
    double stopLossPrice,
  ) {
    final riskAmount = accountBalance * (riskPercentage / 100);
    final riskPerUnit = (entryPrice - stopLossPrice).abs();
    
    if (riskPerUnit == 0) return 0;
    
    return riskAmount / riskPerUnit;
  }
  
  /// Convierte timestamp de milisegundos a DateTime
  static DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  /// Obtiene el color hexadecimal sin el símbolo #
  static String getColorHex(String colorHex) {
    return colorHex.replaceFirst('#', '');
  }
  
  /// Verifica si un valor está dentro de un rango
  static bool isInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }
  
  /// Redondea a un número específico de decimales
  static double roundToDecimals(double value, int decimals) {
    final factor = pow(10, decimals);
    return (value * factor).round() / factor;
  }
}
