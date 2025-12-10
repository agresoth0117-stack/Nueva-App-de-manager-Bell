import 'package:flutter/material.dart';
import '../../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isSelected; // <- nuevo parámetro
  final VoidCallback? onTap; // opcional si quieres manejar taps desde afuera

  const DeviceCard({
    super.key,
    required this.device,
    this.isSelected = false, // valor por defecto
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue.shade100 : Colors.white, // resaltar si está seleccionado
      child: ListTile(
        leading: Icon(
          device.online ? Icons.wifi : Icons.wifi_off,
          color: device.online ? Colors.green : Colors.red,
        ),
        title: Text(device.name),
        subtitle: Text(device.ip),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
