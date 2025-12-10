import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class DeviceProvider with ChangeNotifier {
  final List<Device> _devices = [];

  // Lista de dispositivos seleccionados
  final Set<String> _selectedIds = {};

  List<Device> get devices => List.unmodifiable(_devices);

  List<Device> get selected =>
      _devices.where((d) => _selectedIds.contains(d.id)).toList();

  // ------------------------------------------------------------
  // Cargar dispositivos iniciales (mock)
  // ------------------------------------------------------------
  void loadMockDevices() {
    _devices.clear();
    _devices.addAll([
      Device(id: "1", name: "Timbre Principal", ip: "192.168.0.101"),
      Device(id: "2", name: "Timbre Secundario", ip: "192.168.0.102"),
      Device(id: "3", name: "Timbre Patio", ip: "192.168.0.103"),
    ]);
    notifyListeners();
  }

  // ------------------------------------------------------------
  // Selección
  // ------------------------------------------------------------
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedIds.clear();
    notifyListeners();
  }

  bool isSelected(String id) => _selectedIds.contains(id);

  // ------------------------------------------------------------
  // Obtener un dispositivo por ID
  // ------------------------------------------------------------
  Device? getDeviceById(String id) {
    try {
      return _devices.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // Enviar comando a un único dispositivo
  // ------------------------------------------------------------
  Future<void> sendCommand(String deviceId, String endpoint) async {
    final dev = getDeviceById(deviceId);
    if (dev == null) return;

    try {
      final url = Uri.parse("http://${dev.ip}/$endpoint");
      await http.get(url);
    } catch (e) {
      debugPrint("Error enviando comando a ${dev.name}: $e");
    }
  }

  // ------------------------------------------------------------
  // Enviar comando a TODOS los seleccionados
  // ------------------------------------------------------------
  Future<void> sendCommandToSelected(String endpoint) async {
    for (final dev in selected) {
      try {
        final url = Uri.parse("http://${dev.ip}/$endpoint");
        await http.get(url);
      } catch (e) {
        debugPrint("Error enviando comando a ${dev.name}: $e");
      }
    }
  }

  // ------------------------------------------------------------
  // 🚨 Broadcast de emergencia (RETORNA BOOL)
  // ------------------------------------------------------------
  Future<bool> broadcastEmergency() async {
    bool success = true;

    for (final dev in selected) {
      try {
        final url = Uri.parse("http://${dev.ip}/emergency");
        final response = await http.get(url);

        if (response.statusCode != 200) {
          success = false;
        }
      } catch (e) {
        debugPrint("Error enviando emergencia a ${dev.name}: $e");
        success = false;
      }
    }

    return success;
  }

  // ------------------------------------------------------------
  // Agregar un nuevo dispositivo
  // ------------------------------------------------------------
  void addDevice(Device device) {
    _devices.add(device);
    notifyListeners();
  }

  // ------------------------------------------------------------
  // Eliminar un dispositivo
  // ------------------------------------------------------------
  void removeDevice(String id) {
    _devices.removeWhere((d) => d.id == id);
    _selectedIds.remove(id);
    notifyListeners();
  }
}
