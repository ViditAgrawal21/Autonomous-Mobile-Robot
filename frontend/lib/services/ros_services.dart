import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class ROSService {
  static WebSocketChannel? _channel;
  static String? _currentIP;

  static Future<bool> connect(String ip, {int timeoutSeconds = 5}) async {
    try {
      _currentIP = ip;
      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://$ip:8080'),
        pingInterval: const Duration(seconds: 30),
      );
      return true;
    } catch (e) {
      disconnect();
      rethrow;
    }
  }

  static void sendCommand(String topic, Map<String, dynamic> msg) {
    if (_channel == null) throw Exception('Not connected to ROS');
    _channel!.sink.add('{"op":"publish","topic":"$topic","msg":$msg}');
  }

  static Stream<String> get stream {
    return _channel?.stream.cast<String>() ?? 
      Stream.error('Not connected to ROS');
  }

  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _currentIP = null;
  }
}