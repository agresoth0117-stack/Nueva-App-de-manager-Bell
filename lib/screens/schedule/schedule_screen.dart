import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';
import '../../widgets/dialogs/edit_schedule_dialog.dart';
import '../../widgets/dialogs/select_devices_dialog.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final events = scheduleProvider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Horario de Timbres"),
        elevation: 3,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (_) => EditScheduleDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (_, i) {
          final event = events[i];

          return _ScheduleCard(
            event: event,
            onEdit: () async {
              await showDialog(
                context: context,
                builder: (_) => EditScheduleDialog(event: event),
              );
            },
            onDelete: () {
              scheduleProvider.removeEvent(event.id);
            },
            onSelectDevices: () async {
              scheduleProvider.setSelectedDevices(
                event.deviceIds.toSet(),
              );

              await showDialog(
                context: context,
                builder: (_) => SelectDevicesDialog(event: event),
              );
            },
          );
        },
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSelectDevices;

  const _ScheduleCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onSelectDevices,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.read<ScheduleProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------------------------
          // 🕒 HORA + ACCIÓN
          // -----------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(event.time),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: event.action == ActionType.turnOn
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.action == ActionType.turnOn ? "Encendido" : "Apagado",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: event.action == ActionType.turnOn
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // -----------------------------------------------------------
          // 📝 TÍTULO
          // -----------------------------------------------------------
          Row(
            children: [
              Icon(Icons.label, size: 20, color: Colors.blueGrey.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // -----------------------------------------------------------
          // 📟 DISPOSITIVOS ASIGNADOS
          // -----------------------------------------------------------
          Text(
            scheduleProvider.getDevicesForEventText(event),
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          // -----------------------------------------------------------
          // ⚙️ ACCIONES
          // -----------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: "Asignar dispositivos",
                icon: const Icon(Icons.device_hub),
                color: Colors.blueGrey,
                onPressed: onSelectDevices,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }
}
