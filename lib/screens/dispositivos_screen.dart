import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../services/esp_service.dart';
import 'horario_diario_screen.dart';

class DispositivosScreen extends StatefulWidget {
  const DispositivosScreen({super.key});

  @override
  _DispositivosScreenState createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  List<Dispositivo> dispositivos = [];

  @override
  void initState() {
    super.initState();
    _loadDispositivos();
  }

  Future<void> _loadDispositivos() async {
    List<Dispositivo> lista = await EspService.loadDispositivos();
    setState(() {
      dispositivos = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dispositivos')),
      body: ListView.builder(
        itemCount: dispositivos.length,
        itemBuilder: (context, index) {
          final d = dispositivos[index];
          return Card(
            child: ListTile(
              title: Text(d.nombre),
              subtitle: Text('IP: ${d.ip}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => HorarioDiarioScreen(dispositivo: d)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
