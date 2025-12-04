// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../models/dispositivo.dart';
import '../services/schedule_service.dart';
import '../services/esp_service.dart';

class HorariosScreen extends StatefulWidget {
  final List<Dispositivo> dispositivos;

  const HorariosScreen({super.key, required this.dispositivos});

  @override
  _HorariosScreenState createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  List<Horario> horarios = [];

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    List<Horario> loaded = await ScheduleService.loadHorarios();
    if (!mounted) return;
    setState(() {
      horarios = loaded;
    });
  }

  Future<void> _saveHorarios() async {
    await ScheduleService.saveHorarios(horarios);

    // Enviar a los ESP (ONLINE)
    for (var disp in widget.dispositivos.where((d) => d.online)) {
      await EspService.postHorarios(disp.ip, horarios);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Horarios guardados y sincronizados')),
    );
  }

  void _crearHorario() {
    showDialog(
      context: context,
      builder: (context) {
        String nombre = '';
        return AlertDialog(
          title: const Text('Nuevo Horario'),
          content: TextField(
            onChanged: (value) => nombre = value,
            decoration: const InputDecoration(labelText: 'Nombre del horario'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombre.isNotEmpty) {
                  setState(() {
                    horarios.add(
                      Horario(
                        nombre: nombre,
                        dias: {
                          'Lunes': [],
                          'Martes': [],
                          'Miércoles': [],
                          'Jueves': [],
                          'Viernes': [],
                          'Sábado': [],
                          'Domingo': [],
                        },
                        espAsignados: [],
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _editarHoras(Horario horario, String dia) {
    List<String> horas = List.from(horario.dias[dia]!);
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Editar $dia - ${horario.nombre}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < horas.length; i++)
                  ListTile(
                    title: Text(horas[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setStateDialog(() {
                          horas.removeAt(i);
                        });
                      },
                    ),
                  ),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Agregar hora HH:MM'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setStateDialog(() {
                      horas.add(controller.text);
                      controller.clear();
                    });
                  }
                },
                child: const Text('Agregar hora'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    horario.dias[dia] = horas;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        });
      },
    );
  }

  void _asignarEsp(Horario horario) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> seleccionados = List.from(horario.espAsignados);

        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('Asignar ESP - ${horario.nombre}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.dispositivos.map((disp) {
                return CheckboxListTile(
                  title: Text(disp.nombre),
                  value: seleccionados.contains(disp.ip),
                  onChanged: (val) {
                    setStateDialog(() {
                      if (val == true) {
                        seleccionados.add(disp.ip);
                      } else {
                        seleccionados.remove(disp.ip);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    horario.espAsignados = seleccionados;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios'),
        actions: [
          IconButton(onPressed: _saveHorarios, icon: const Icon(Icons.save)),
          IconButton(onPressed: _crearHorario, icon: const Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
        itemCount: horarios.length,
        itemBuilder: (context, index) {
          final horario = horarios[index];
          return Card(
            child: ExpansionTile(
              title: Text(horario.nombre),
              children: [
                for (var dia in horario.dias.keys)
                  ListTile(
                    title: Text("$dia: ${horario.dias[dia]!.join(", ")}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editarHoras(horario, dia),
                    ),
                  ),
                ListTile(
                  title: Text(
                    "ESP asignados: "
                    "${horario.espAsignados.isEmpty ? 'Ninguno' : horario.espAsignados.join(', ')}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.devices),
                    onPressed: () => _asignarEsp(horario),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
