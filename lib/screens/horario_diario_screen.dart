import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../models/horario_diario.dart';
import '../services/esp_service.dart';
import '../services/schedule_service.dart';

class HorarioDiarioScreen extends StatefulWidget {
  final Dispositivo dispositivo;

  const HorarioDiarioScreen({super.key, required this.dispositivo});

  @override
  _HorarioDiarioScreenState createState() => _HorarioDiarioScreenState();
}

class _HorarioDiarioScreenState extends State<HorarioDiarioScreen> {
  List<HorarioDiario> horarios = [];

  @override
  void initState() {
    super.initState();
    _loadHorarios();
  }

  Future<void> _loadHorarios() async {
    List<HorarioDiario> all = await ScheduleService.loadHorariosDiarios();
    setState(() {
      horarios = all.where((h) => h.dispositivoIp == widget.dispositivo.ip).toList();
    });
  }

  void _agregarHorario() {
    TextEditingController nombreCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nuevo horario diario'),
        content: TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty) {
                HorarioDiario h = HorarioDiario(
                  nombre: nombreCtrl.text,
                  dias: {
                    'Lunes': [],
                    'Martes': [],
                    'Miércoles': [],
                    'Jueves': [],
                    'Viernes': [],
                    'Sábado': [],
                    'Domingo': [],
                  },
                  dispositivoIp: widget.dispositivo.ip,
                );
                setState(() => horarios.add(h));
                Navigator.pop(context);
              }
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _guardarHorarios() async {
    await ScheduleService.saveHorariosDiarios(horarios);
    // Enviar al ESP
    await EspService.postHorarios(widget.dispositivo.ip, horarios);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Horarios diarios guardados')));
  }

  void _editarHoras(HorarioDiario horario, String dia) {
    List<String> horas = List.from(horario.dias[dia]!);
    TextEditingController controller = TextEditingController();

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
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setStateDialog(() {
                          horas.removeAt(i);
                        });
                      },
                    ),
                  ),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Agregar hora HH:MM'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
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
                child: Text('Agregar hora'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    horario.dias[dia] = horas;
                  });
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
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
        title: Text('Horarios diarios - ${widget.dispositivo.nombre}'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _guardarHorarios),
          IconButton(icon: Icon(Icons.add), onPressed: _agregarHorario),
        ],
      ),
      body: ListView.builder(
        itemCount: horarios.length,
        itemBuilder: (context, index) {
          final h = horarios[index];
          return Card(
            child: ListTile(
              title: Text(h.nombre),
              subtitle: Text(h.dias.entries.map((e) => '${e.key}: ${e.value.join(", ")}').join("\n")),
              onTap: () {
                // Mostrar diálogo para elegir día a editar
                showDialog(
                  context: context,
                  builder: (_) {
                    return SimpleDialog(
                      title: Text('Editar horas - ${h.nombre}'),
                      children: h.dias.keys.map((dia) {
                        return SimpleDialogOption(
                          child: Text(dia),
                          onPressed: () {
                            Navigator.pop(context);
                            _editarHoras(h, dia);
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
