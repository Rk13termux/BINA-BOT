/// Sistema de logging centralizado para la aplicación
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() => _instance;

  AppLogger._internal();

  /// Log de información
  void info(String message) {
    _log('INFO', message);
  }

  /// Log de advertencia
  void warning(String message) {
    _log('WARNING', message);
  }

  /// Log de error
  void error(String message) {
    _log('ERROR', message);
  }

  /// Log de debug
  void debug(String message) {
    _log('DEBUG', message);
  }

  /// Log interno
  void _log(String level, String message) {
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[$timestamp] [$level] $message');

    // TODO: Implementar almacenamiento de logs para producción
    // Podría guardar en archivo local o enviar a servicio de logs
  }

  /// Limpia logs antiguos (para implementar en futuro)
  void clearOldLogs() {
    // TODO: Implementar limpieza de logs antiguos
  }
}
