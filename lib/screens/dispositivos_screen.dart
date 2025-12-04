import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../services/esp_scanner_service.dart';
import 'horario_diario_screen.dart';

class DispositivosScreen extends StatefulWidget {
  const DispositivosScreen({super.key});

  @override
  _DispositivosScreenState createState() => _DispositivosScreenState();
}

class _DispositivosScreenState extends State<DispositivosScreen> {
  List<Dispositivo> dispositivos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _scanDispositivos();
  }

  Future<void> _scanDispositivos() async {
    setState(() => cargando = true);

    List<Dispositivo> lista = await EspScannerService.scanAuto();

    setState(() {
      dispositivos = lista;
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispositivos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _scanDispositivos,
          )
        ],
      ),

      body: cargando
          ? Center(child: CircularProgressIndicator())
          : dispositivos.isEmpty
              ? Center(
                  child: Text(
                    "No se encontraron dispositivos en la red",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
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
                            MaterialPageRoute(
                              builder: (_) => HorarioDiarioScreen(dispositivo: d),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
