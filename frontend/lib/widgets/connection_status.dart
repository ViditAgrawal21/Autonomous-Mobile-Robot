import 'package:flutter/material.dart';

class ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final String? message;

  const ConnectionStatus({
    Key? key,
    required this.isConnected,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isConnected ? Icons.check_circle : Icons.error,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (message != null) ...[
          const SizedBox(width: 8),
          Text(
            message!,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ],
    );
  }
}