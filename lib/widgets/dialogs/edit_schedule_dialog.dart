// lib/widgets/dialogs/edit_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/schedule_provider.dart';
import '../../providers/device_provider.dart';
import '../../models/schedule.dart';
import 'select_devices_dialog.dart';

class EditScheduleDialog extends StatefulWidget {
  final ScheduleEvent? event;

  const EditScheduleDialog({super.key, this.event});

  @override
  State<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<EditScheduleDialog> {
  late TextEditingController _title;
  late TimeOfDay _time;
  late ActionType _action;

  List<String> _selectedDeviceIds = [];

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.event?.title ?? "");
    _time = widget.event?.time ?? TimeOfDay.now();
    _action = widget.event?.action ?? ActionType.turnOn;

    _selectedDeviceIds = List<String>.from(widget.event?.deviceIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    final deviceProvider = context.watch<DeviceProvider>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEditing ? "Editar evento" : "Nuevo evento"),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Hora:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 12),
                Text(_formatTime(_time), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton(onPressed: () async {
                  final picked = await showTimePicker(context: context, initialTime: _time);
                  if (picked != null) setState(() => _time = picked);
                }, child: const Text("Cambiar")),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ActionType>(
              initialValue: _action,
              decoration: const InputDecoration(labelText: "Acción", border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: ActionType.turnOn, child: Text("Encender")),
                DropdownMenuItem(value: ActionType.turnOff, child: Text("Apagar")),
              ],
              onChanged: (v) => setState(() => _action = v!),
            ),
            const SizedBox(height: 12),

            // Dispositivos seleccionados + botón
            Row(
              children: [
                const Text("Dispositivos:", style: TextStyle(fontSize: 16)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final result = await showDialog<List<String>>(
                      context: context,
                      builder: (_) => SelectDevicesDialog(initialSelectedIds: _selectedDeviceIds),
                    );
                    if (result != null) {
                      setState(() => _selectedDeviceIds = result);
                    }
                  },
                  child: const Text("Seleccionar"),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(10)),
              child: _selectedDeviceIds.isEmpty ? const Text("Ningún dispositivo asignado", style: TextStyle(color: Colors.grey)) : Wrap(
                spacing: 6,
                children: _selectedDeviceIds.map((id) {
                  final dev = deviceProvider.getDeviceById(id);
                  return Chip(label: Text(dev?.name ?? "Desconocido"));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
        ElevatedButton(onPressed: () => _save(context), child: Text(isEditing ? "Guardar" : "Crear")),
      ],
    );
  }

  void _save(BuildContext context) {
    final scheduleProv = context.read<ScheduleProvider>();
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("El título no puede estar vacío")));
      return;
    }

    if (widget.event == null) {
      scheduleProv.addEvent(ScheduleEvent(
        id: const Uuid().v4(),
        title: _title.text.trim(),
        time: _time,
        action: _action,
        deviceIds: _selectedDeviceIds,
      ));
    } else {
      scheduleProv.updateEvent(widget.event!.copyWith(title: _title.text.trim(), time: _time, action: _action, deviceIds: _selectedDeviceIds));
    }

    Navigator.pop(context);
  }

  String _formatTime(TimeOfDay t) => "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
}
