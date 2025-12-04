import 'package:flutter/material.dart';
import '../models/dispositivo.dart';
import '../repositories/dispositivo_repository.dart';

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
    _loadAndScan();
  }

  /// Carga desde memoria y luego escanea la red
  Future<void> _loadAndScan() async {
    setState(() => cargando = true);

    // 1. Cargar dispositivos guardados
    final guardados = await DispositivoRepository.loadAll();

    if (!mounted) return;
    setState(() => dispositivos = guardados);

    // 2. Escanear y fusionar con los guardados
    final merged = await DispositivoRepository.scanAndMerge();

    if (!mounted) return;
    setState(() {
      dispositivos = merged;
      cargando = false;
    });
  }

  /// Permite actualizar solo el estado online/offline sin reescanear
  Future<void> _refreshOnlineStatus() async {
    final actualizados = await DispositivoRepository.updateStatuses();
    if (!mounted) return;
    setState(() => dispositivos = actualizados);
  }

  /// Eliminar un dispositivo de la lista
  Future<void> _deleteDevice(String ip) async {
    await DispositivoRepository.removeByIp(ip);
    final lista = await DispositivoRepository.loadAll();
    if (!mounted) return;
    setState(() => dispositivos = lista);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispositivos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAndScan,
            tooltip: "Volver a escanear red",
          ),
          IconButton(
            icon: Icon(Icons.wifi_tethering),
            onPressed: _refreshOnlineStatus,
            tooltip: "Actualizar estado Online/Offline",
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : dispositivos.isEmpty
              ? const Center(
                  child: Text(
                    "No hay dispositivos guardados ni detectados",
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
                          onPressed: () => _deleteDevice(d.ip),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/horario_diario",
                            arguments: d,
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
