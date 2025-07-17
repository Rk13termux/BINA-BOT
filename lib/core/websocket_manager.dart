import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../utils/logger.dart';

/// Gestiona las conexiones WebSocket para datos en tiempo real
class WebSocketManager {
  static const String _binanceWsUrl = 'wss://stream.binance.com:9443/ws/';
  static const String _binanceTestnetWsUrl = 'wss://testnet.binance.vision/ws/';

  final AppLogger _logger = AppLogger();
  final Map<String, WebSocketChannel> _connections = {};
  final Map<String, StreamController> _streamControllers = {};

  bool _isTestnet = false;

  /// Configura si usar testnet
  void setTestnet(bool testnet) {
    _isTestnet = testnet;
  }

  /// Suscribe a actualizaciones de precio de un símbolo
  Stream<Map<String, dynamic>> subscribeTicker(String symbol) {
    final streamName = '${symbol.toLowerCase()}@ticker';
    return _createStream(streamName);
  }

  /// Suscribe a datos de velas en tiempo real
  Stream<Map<String, dynamic>> subscribeKline(String symbol, String interval) {
    final streamName = '${symbol.toLowerCase()}@kline_$interval';
    return _createStream(streamName);
  }

  /// Suscribe a datos del libro de órdenes
  Stream<Map<String, dynamic>> subscribeDepth(String symbol, {int levels = 5}) {
    final streamName = '${symbol.toLowerCase()}@depth$levels@100ms';
    return _createStream(streamName);
  }

  /// Suscribe a trades en tiempo real
  Stream<Map<String, dynamic>> subscribeTrade(String symbol) {
    final streamName = '${symbol.toLowerCase()}@trade';
    return _createStream(streamName);
  }

  /// Suscribe a múltiples streams
  Stream<Map<String, dynamic>> subscribeMultiple(List<String> streams) {
    final combinedStreamName = streams.join('/');
    return _createStream(combinedStreamName);
  }

  /// Crea un stream WebSocket
  Stream<Map<String, dynamic>> _createStream(String streamName) {
    if (_streamControllers.containsKey(streamName)) {
      return _streamControllers[streamName]!
          .stream
          .cast<Map<String, dynamic>>();
    }

    final controller = StreamController<Map<String, dynamic>>.broadcast();
    _streamControllers[streamName] = controller;

    _connectWebSocket(streamName, controller);

    return controller.stream.cast<Map<String, dynamic>>();
  }

  /// Conecta a WebSocket
  void _connectWebSocket(
      String streamName, StreamController<Map<String, dynamic>> controller) {
    try {
      final wsUrl = _isTestnet ? _binanceTestnetWsUrl : _binanceWsUrl;
      final uri = Uri.parse('$wsUrl$streamName');
      _logger.debug('WebSocketManager URL being used: $uri');

      final channel = WebSocketChannel.connect(uri);
      _connections[streamName] = channel;

      _logger.info('Connected to WebSocket: $streamName');

      channel.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> jsonData = json.decode(data);
            controller.add(jsonData);
          } catch (e) {
            _logger.error('Error parsing WebSocket data for $streamName: $e');
          }
        },
        onError: (error) {
          _logger.error('WebSocket error for $streamName: $error');
          controller.addError(error);
          _reconnect(streamName, controller);
        },
        onDone: () {
          _logger.info('WebSocket connection closed for $streamName');
          _reconnect(streamName, controller);
        },
      );
    } catch (e) {
      _logger.error('Error connecting WebSocket for $streamName: $e');
      controller.addError(e);
    }
  }

  /// Reconecta WebSocket después de una desconexión
  void _reconnect(
      String streamName, StreamController<Map<String, dynamic>> controller) {
    _logger.info('Attempting to reconnect WebSocket: $streamName');

    Timer(const Duration(seconds: 5), () {
      if (!controller.isClosed) {
        _connectWebSocket(streamName, controller);
      }
    });
  }

  /// Cierra una conexión específica
  void closeConnection(String streamName) {
    if (_connections.containsKey(streamName)) {
      _connections[streamName]?.sink.close(status.goingAway);
      _connections.remove(streamName);
    }

    if (_streamControllers.containsKey(streamName)) {
      _streamControllers[streamName]?.close();
      _streamControllers.remove(streamName);
    }

    _logger.info('Closed WebSocket connection: $streamName');
  }

  /// Cierra todas las conexiones
  void closeAllConnections() {
    for (final streamName in _connections.keys.toList()) {
      closeConnection(streamName);
    }
    _logger.info('All WebSocket connections closed');
  }

  /// Verifica si una conexión está activa
  bool isConnected(String streamName) {
    return _connections.containsKey(streamName) &&
        _streamControllers.containsKey(streamName) &&
        !_streamControllers[streamName]!.isClosed;
  }

  /// Obtiene el estado de todas las conexiones
  Map<String, bool> getConnectionsStatus() {
    final Map<String, bool> status = {};
    for (final streamName in _streamControllers.keys) {
      status[streamName] = isConnected(streamName);
    }
    return status;
  }

  /// Suscribe a eventos de cuenta (requiere listen key)
  Stream<Map<String, dynamic>> subscribeUserData(String listenKey) {
    final streamName = listenKey;
    return _createStream(streamName);
  }

  /// Crea un listen key para datos de usuario
  Future<String?> createListenKey() async {
    // Esta funcionalidad requiere integración con ApiManager
    // Se implementará cuando se necesite trading en tiempo real
    _logger.info('Listen key creation not implemented yet');
    return null;
  }

  /// Mantiene vivo el listen key
  Future<void> keepAliveListenKey(String listenKey) async {
    // Esta funcionalidad requiere integración con ApiManager
    _logger.info('Keep alive listen key not implemented yet');
  }

  /// Dispose de todos los recursos
  void dispose() {
    closeAllConnections();
    _logger.info('WebSocketManager disposed');
  }
}
