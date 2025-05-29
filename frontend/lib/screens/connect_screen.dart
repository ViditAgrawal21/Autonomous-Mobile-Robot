import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../services/ros_services.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _ipController = TextEditingController(text: '10.0.2.2'); // Android emulator default
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to AGV')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'AGV IP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connectToAGV,
                child: _isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('CONNECT'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connectToAGV() async {
    setState(() => _isConnecting = true);
    try {
      await ROSService.connect(_ipController.text);
      if (mounted) Navigator.pushNamed(context, '/map');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}