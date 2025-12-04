import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../repositories/dispositivo_repository.dart';
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
    _cargarDispositivos();
  }

  /// 1️⃣ Carga dispositivos guardados (instantáneo)
  /// 2️⃣ Luego ejecuta un escaneo completo y MERGEA
  Future<void> _cargarDispositivos() async {
    // Muestra lista guardada sin esperar escaneo
    final saved = await DispositivoRepository.loadAll();
    setState(() {
      dispositivos = saved;
      cargando = false;
    });

    // Escanear y mergear en segundo plano
    _scanYActualizar();
  }

  Future<void> _scanYActualizar() async {
    setState(() => cargando = true);

    final merged = await DispositivoRepository.scanAndMerge();

    setState(() {
      dispositivos = merged;
      cargando = false;
    });
  }

  /// Eliminar dispositivo
  Future<void> _eliminar(String ip) async {
    await DispositivoRepository.removeByIp(ip);
    final updated = await DispositivoRepository.loadAll();

    setState(() {
      dispositivos = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _scanYActualizar,
          )
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : dispositivos.isEmpty
              ? const Center(
                  child: Text(
                    "No hay dispositivos registrados",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: dispositivos.length,
                  itemBuilder: (context, index) {
                    final d = dispositivos[index];

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          d.online ? Icons.wifi : Icons.wifi_off,
                          color: d.online ? Colors.green : Colors.red,
                        ),
                        title: Text(d.nombre),
                        subtitle: Text("IP: ${d.ip}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminar(d.ip),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HorarioDiarioScreen(dispositivo: d),
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
