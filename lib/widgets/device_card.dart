import 'package:flutter/material.dart';
import '../../models/device.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          device.online ? Icons.wifi : Icons.wifi_off,
          color: device.online ? Colors.green : Colors.red,
        ),
        title: Text(device.name),
        subtitle: Text(device.ip),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
