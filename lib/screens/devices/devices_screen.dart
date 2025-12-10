import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/device_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deviceProvider.devices.length,
        itemBuilder: (context, index) {
          final device = deviceProvider.devices[index];
          final selected = deviceProvider.isSelected(device.id);
          return DeviceCard(
            device: device,
            isSelected: selected,
            onTap: () => deviceProvider.toggleSelection(device.id),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías abrir un diálogo para agregar un nuevo dispositivo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
