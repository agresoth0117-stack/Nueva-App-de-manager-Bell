import 'package:flutter/material.dart';
import '../models/horario.dart';
import '../models/dispositivo.dart';
import '../repositories/dispositivo_repository.dart';

class HorarioDiarioScreen extends StatefulWidget {
  final Dispositivo dispositivo;

  const HorarioDiarioScreen({super.key, required this.dispositivo});

  @override
  State<HorarioDiarioScreen> createState() => _HorarioDiarioScreenState();
}

class _HorarioDiarioScreenState extends State<HorarioDiarioScreen> {
  final TextEditingController _nombreCtrl = TextEditingController();
  Map<String, List<String>> dias = {
    "Lunes": [],
    "Martes": [],
    "Miércoles": [],
    "Jueves": [],
    "Viernes": [],
    "Sábado": [],
    "Domingo": [],
  };

  @override
  void initState() {
    super.initState();
    _cargarHorariosPrevios();
  }

  /// Carga horarios del dispositivo si ya tenía algo guardado
  void _cargarHorariosPrevios() {
    if (widget.dispositivo.horariosAsignados.isNotEmpty) {
      Horario h = widget.dispositivo.horariosAsignados.first;

      _nombreCtrl.text = h.nombre;
      dias = Map.from(h.dias);
      setState(() {});
    }
  }

  /// Guarda en el dispositivo y persiste en SharedPreferences
  Future<void> _guardar() async {
    if (_nombreCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debe escribir un nombre para el horario")),
      );
      return;
    }

    Horario nuevo = Horario(
      nombre: _nombreCtrl.text,
      dias: dias,
      espAsignados: [widget.dispositivo.ip],
    );

    widget.dispositivo.horariosAsignados = [nuevo];
    await DispositivoRepository.addOrUpdate(widget.dispositivo);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Horario guardado")));

    Navigator.pop(context);
  }

  void _agregarHora(String dia) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      final hora = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      setState(() {
        dias[dia]!.add(hora);
      });
    }
  }

  void _borrarHora(String dia, int index) {
    setState(() {
      dias[dia]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dispositivo.nombre),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _guardar,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: InputDecoration(
              labelText: "Nombre del horario",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ...dias.keys.map((dia) => Card(
                child: ExpansionTile(
                  title: Text(dia),
                  children: [
                    ...dias[dia]!.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hora = entry.value;

                      return ListTile(
                        title: Text(hora),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _borrarHora(dia, index),
                        ),
                      );
                    }).toList(),
                    TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text("Agregar hora"),
                      onPressed: () => _agregarHora(dia),
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
