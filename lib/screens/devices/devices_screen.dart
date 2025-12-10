import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/device_provider.dart';
import '../../widgets/device_card.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<DeviceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Dispositivos")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: agregar formulario añadir dispositivo
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          for (final d in prov.devices)
            DeviceCard(device: d),
        ],
      ),
    );
  }
}
