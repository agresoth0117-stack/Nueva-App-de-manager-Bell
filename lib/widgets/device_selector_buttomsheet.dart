import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device.dart';

class DeviceSelectorBottomSheet extends StatelessWidget {
  final void Function(List<String>) onSelected;

  const DeviceSelectorBottomSheet({
    super.key,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeviceProvider>();
    final devices = provider.devices;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Seleccionar dispositivos",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // Lista de dispositivos
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final Device d = devices[i];
                final selected = provider.isSelected(d.id);

                return ListTile(
                  leading: Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? Colors.green : Colors.grey,
                  ),
                  title: Text(d.name),
                  subtitle: Text(d.ip),
                  onTap: () => provider.toggleSelection(d.id), // 🔥 CORREGIDO
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              onSelected(provider.selected.map((d) => d.id).toList());
              Navigator.pop(context);
            },
            child: const Text("Confirmar selección"),
          ),
        ],
      ),
    );
  }
}
