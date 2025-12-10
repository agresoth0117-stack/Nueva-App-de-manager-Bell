import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/device.dart';
import '../../services/device_service.dart';
import '../schedule/schedule_screen.dart'; // Pantalla de horarios

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> devices = [];
  Set<String> selectedDeviceIds = {};
  Timer? scanTimer;

  final String subnet = "192.168.1";

  @override
  void initState() {
    super.initState();
    _startAutoScan();
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  void _startAutoScan() {
    _scanDevices();
    scanTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _scanDevices();
    });
  }

  Future<void> _scanDevices() async {
    try {
      final scannedDevices = await DeviceService.scanNetwork(subnet, devices);
      setState(() {
        devices = scannedDevices;
      });
    } catch (e) {
      debugPrint('Error al escanear dispositivos: $e');
    }
  }

  void _showAddDeviceDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar dispositivo manual'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre/alias'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingresa un nombre' : null,
                ),
                TextFormField(
                  controller: ipController,
                  decoration: const InputDecoration(labelText: 'IP del dispositivo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa la IP';
                    final regex =
                        RegExp(r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$');
                    if (!regex.hasMatch(value)) return 'IP inválida';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final ip = ipController.text.trim();
                  final name = nameController.text.trim();

                  bool isConnected = false;
                  try {
                    final devicesList = await DeviceService.scanNetwork(
                        ip.split('.').sublist(0, 3).join('.'), [
                      Device(id: ip, name: name, ip: ip),
                    ]);
                    if (devicesList.isNotEmpty && devicesList.first.connected) {
                      isConnected = true;
                    }
                  } catch (e) {
                    isConnected = false;
                  }

                  if (isConnected) {
                    setState(() {
                      devices.add(Device(
                        id: ip,
                        name: name,
                        ip: ip,
                        online: true,
                        lastSeen: DateTime.now(),
                      ));
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'No se pudo conectar al dispositivo. Verifica la IP.'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedDevices() {
    setState(() {
      devices.removeWhere((d) => selectedDeviceIds.contains(d.id));
      selectedDeviceIds.clear();
    });
  }

  Future<void> _refreshSelectedDevices() async {
    for (String id in selectedDeviceIds) {
      final device = devices.firstWhere((d) => d.id == id);
      try {
        final refreshed = await DeviceService.scanNetwork(subnet, [device]);
        if (refreshed.isNotEmpty) {
          setState(() {
            final index = devices.indexWhere((d) => d.id == id);
            devices[index] = refreshed.first;
          });
        }
      } catch (_) {
        setState(() {
          device.online = false;
        });
      }
    }
  }

  Future<void> _ringSelectedDevices() async {
    for (String id in selectedDeviceIds) {
      final device = devices.firstWhere((d) => d.id == id);
      try {
        await DeviceService.ringDevice(device.ip); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timbre activado en ${device.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo activar timbre en ${device.name}')),
        );
      }
    }
  }

  void _openScheduleScreen() {
    if (selectedDeviceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un dispositivo')),
      );
      return;
    }

    final selectedDevices = devices
        .where((d) => selectedDeviceIds.contains(d.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeeklyScheduleScreen(
          selectedDevices: selectedDevices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos ESP8266'),
        actions: [
          if (selectedDeviceIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.schedule),
              onPressed: _openScheduleScreen,
              tooltip: 'Asignar horarios',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedDevices,
              tooltip: 'Eliminar seleccionados',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshSelectedDevices,
              tooltip: 'Refrescar seleccionados',
            ),
            IconButton(
              icon: const Icon(Icons.notifications_active),
              onPressed: _ringSelectedDevices,
              tooltip: 'Activar timbre seleccionados',
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _scanDevices,
              tooltip: 'Volver a escanear',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddDeviceDialog,
              tooltip: 'Agregar dispositivo',
            ),
          ],
        ],
      ),
      body: devices.isEmpty
          ? const Center(child: Text('No se han detectado dispositivos.'))
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final selected = selectedDeviceIds.contains(device.id);

                return ListTile(
                  leading: SizedBox(
                    width: 60,
                    child: Icon(
                      device.connected ? Icons.circle : Icons.circle_outlined,
                      color: device.connected ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(device.name),
                  subtitle: Text(device.ip),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          // Editar dispositivo
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          setState(() {
                            devices.removeAt(index);
                            selectedDeviceIds.remove(device.id);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () async {
                          try {
                            final refreshed = await DeviceService.scanNetwork(
                                subnet, [device]);
                            if (refreshed.isNotEmpty) {
                              setState(() {
                                devices[index] = refreshed.first;
                              });
                            }
                          } catch (e) {
                            setState(() {
                              device.online = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  selected: selected,
                  selectedTileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        selectedDeviceIds.remove(device.id);
                      } else {
                        selectedDeviceIds.add(device.id);
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}
