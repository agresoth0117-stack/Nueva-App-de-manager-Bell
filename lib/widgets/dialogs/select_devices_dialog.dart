// lib/widgets/dialogs/select_devices_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class SelectDevicesDialog extends StatefulWidget {
  final ScheduleEvent? event;
  final List<String>? initialSelectedIds;

  const SelectDevicesDialog({super.key, this.event, this.initialSelectedIds});

  @override
  State<SelectDevicesDialog> createState() => _SelectDevicesDialogState();
}

class _SelectDevicesDialogState extends State<SelectDevicesDialog> {
  late Set<String> localSelection;

  @override
  void initState() {
    super.initState();
    localSelection = <String>{
      if (widget.event != null) ...widget.event!.deviceIds,
      if (widget.initialSelectedIds != null) ...widget.initialSelectedIds!,
    };
  }

  @override
  Widget build(BuildContext context) {
    final deviceProv = context.watch<DeviceProvider>();
    final scheduleProv = context.watch<ScheduleProvider>();
    final devices = deviceProv.devices;

    return AlertDialog(
      title: const Text("Seleccionar dispositivos"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: devices.isEmpty
            ? const Center(child: Text("No hay dispositivos registrados"))
            : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (_, i) {
                  final d = devices[i];
                  final selected = localSelection.contains(d.id);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(d.name),
                    subtitle: Text(d.ip),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          localSelection.add(d.id);
                        } else {
                          localSelection.remove(d.id);
                        }
                      });
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            // Si el diálogo fue abierto con un event -> actualizamos ese evento directamente
            if (widget.event != null) {
              scheduleProv.updateEvent(widget.event!.copyWith(
                deviceIds: localSelection.toList(),
              ));
              // también actualizamos provider.selectedDeviceIds por consistencia
              scheduleProv.setSelectedDevices(localSelection);
              Navigator.pop(context, localSelection.toList());
              return;
            }

            // Si no hay event -> devolvemos la lista al caller (Edit dialog)
            scheduleProv.setSelectedDevices(localSelection);
            Navigator.pop(context, localSelection.toList());
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
