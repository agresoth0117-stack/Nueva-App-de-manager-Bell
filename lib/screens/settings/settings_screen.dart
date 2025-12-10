import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text("Estado de conexión"),
            subtitle: Text(deviceProvider.isConnected ? "Conectado" : "Desconectado"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text("Recargar dispositivos"),
            onTap: () {
              deviceProvider.loadMockDevices();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("Limpiar selección"),
            onTap: () {
              deviceProvider.clearSelection();
            },
          ),
        ],
      ),
    );
  }
}
