import 'package:flutter/material.dart';
import '../../models/device.dart';
import '../../services/device_service.dart';

/// Modelo para un horario individual
class ScheduleEntry {
  int hour;
  int minute;
  String days; // Ej: "LMXJVSD"

  ScheduleEntry({required this.hour, required this.minute, required this.days});

  Map<String, dynamic> toJson() => {
        'h': hour,
        'm': minute,
        'd': days,
      };

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
        hour: json['h'],
        minute: json['m'],
        days: json['d'],
      );
}

class WeeklyScheduleScreen extends StatefulWidget {
  final List<Device> selectedDevices;

  const WeeklyScheduleScreen({super.key, required this.selectedDevices});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  // Map día -> lista de horarios
  Map<String, List<ScheduleEntry>> weeklySchedules = {
    'L': [],
    'M': [],
    'X': [],
    'J': [],
    'V': [],
    'S': [],
    'D': [],
  };

  // Map para controlar expansión de los días
  Map<String, bool> expanded = {
    'L': true,
    'M': false,
    'X': false,
    'J': false,
    'V': false,
    'S': false,
    'D': false,
  };

  // Nombres completos de los días
  final Map<String, String> dayNames = {
    'L': 'Lunes',
    'M': 'Martes',
    'X': 'Miércoles',
    'J': 'Jueves',
    'V': 'Viernes',
    'S': 'Sábado',
    'D': 'Domingo',
  };

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedulesFromDevices();
  }

  Future<void> _loadSchedulesFromDevices() async {
    setState(() => loading = true);
    try {
      if (widget.selectedDevices.isNotEmpty) {
        Map<String, List<ScheduleEntry>> temp = {
          'L': [], 'M': [], 'X': [], 'J': [], 'V': [], 'S': [], 'D': [],
        };

        // Fusionar horarios de todos los dispositivos
        for (var device in widget.selectedDevices) {
          final schedules = await DeviceService.getSchedule(device);
          for (var entry in schedules) {
            for (var dayChar in entry.days.split('')) {
              if (temp.containsKey(dayChar)) {
                // Evitar duplicados
                if (!temp[dayChar]!.any((e) => e.hour == entry.hour && e.minute == entry.minute)) {
                  temp[dayChar]!.add(entry);
                }
              }
            }
          }
        }

        setState(() => weeklySchedules = temp);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar horarios: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void _addSchedule(String day) {
    int hour = 0;
    int minute = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar horario - ${dayNames[day]}'),
        content: Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Hora (0-23)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => hour = int.tryParse(val) ?? 0,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Minutos (0-59)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => minute = int.tryParse(val) ?? 0,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hora o minuto inválido')),
                );
                return;
              }

              // Evitar duplicados
              if (!weeklySchedules[day]!.any((e) => e.hour == hour && e.minute == minute)) {
                setState(() {
                  weeklySchedules[day]!.add(ScheduleEntry(hour: hour, minute: minute, days: day));
                });
              }

              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _deleteSchedule(String day, int index) {
    setState(() => weeklySchedules[day]!.removeAt(index));
  }

  Future<void> _saveSchedules() async {
    setState(() => loading = true);
    try {
      // Combinar todos los días en una lista
      List<ScheduleEntry> combined = [];
      weeklySchedules.forEach((day, list) {
        combined.addAll(list);
      });

      for (var device in widget.selectedDevices) {
        await DeviceService.sendSchedule(device, combined);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horarios guardados correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar horarios: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de horarios semanales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSchedules,
            tooltip: 'Guardar horarios en dispositivos',
          ),
        ],
      ),
      body: ListView(
        children: weeklySchedules.entries.map((entry) {
          final day = entry.key;
          final schedules = entry.value;
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text(dayNames[day]!),
              initiallyExpanded: expanded[day]!,
              onExpansionChanged: (val) => setState(() => expanded[day] = val),
              children: [
                ...schedules.asMap().entries.map((e) {
                  final idx = e.key;
                  final schedule = e.value;
                  return ListTile(
                    title: Text('${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSchedule(day, idx),
                    ),
                  );
                }),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Agregar horario'),
                  onTap: () => _addSchedule(day),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
