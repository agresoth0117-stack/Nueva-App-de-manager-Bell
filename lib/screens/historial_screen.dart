import 'package:flutter/material.dart';
import '../services/historial_service.dart';
import '../models/activacion.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Activacion> historial = [];

  @override
  void initState() {
    super.initState();
    _loadHistorial();
  }

  Future<void> _loadHistorial() async {
    List<Activacion> loaded = await HistorialService.getHistorial();
    setState(() {
      historial = loaded.reversed.toList(); // Mostrar más recientes arriba
    });
  }

  Future<void> _clearHistorial() async {
    await HistorialService.clearHistorial();
    _loadHistorial();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Timbres'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _clearHistorial(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistorial,
        child: ListView.builder(
          itemCount: historial.length,
          itemBuilder: (context, index) {
            final act = historial[index];
            return Card(
              child: ListTile(
                title: Text('${act.tipo} - ${act.dispositivo}'),
                subtitle: Text(
                    '${DateFormat('yyyy-MM-dd HH:mm:ss').format(act.fechaHora)} | Duración: ${act.duracionMs}ms'),
              ),
            );
          },
        ),
      ),
    );
  }
}
