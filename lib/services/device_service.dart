import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import '../screens/schedule/schedule_screen.dart'; // Para ScheduleEntry

class DeviceService {
  /// Escanea la red para detectar dispositivos ESP8266
  static Future<List<Device>> scanNetwork(
      String subnet, List<Device> existingDevices) async {
    List<Device> scannedDevices = [];

    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';
      try {
        final uri = Uri.parse('http://$ip/status');
        final response = await http.get(uri).timeout(
              const Duration(seconds: 1),
            );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final hostname = jsonData['hostname'] ?? ip;
          final existing = existingDevices.firstWhere(
              (d) => d.id == ip,
              orElse: () => Device(id: ip, name: hostname, ip: ip));
          scannedDevices.add(Device(
            id: ip,
            name: existing.name,
            ip: ip,
            online: true,
            lastSeen: DateTime.now(),
          ));
        }
      } catch (_) {
        // Cambiado: no puede retornar null, ahora usamos un fallback
        final existing = existingDevices.firstWhere(
            (d) => d.id == ip,
            orElse: () => Device(id: ip, name: ip, ip: ip));
        scannedDevices.add(Device(
          id: ip,
          name: existing.name,
          ip: ip,
          online: false,
          lastSeen: existing.lastSeen,
        ));
      }
    }

    return scannedDevices;
  }

  /// Refresca un dispositivo individual
  static Future<Device> refreshDevice(Device device) async {
    try {
      final uri = Uri.parse('http://${device.ip}/status');
      final response = await http.get(uri).timeout(
            const Duration(seconds: 1),
          );
      if (response.statusCode == 200) {
        return Device(
          id: device.id,
          name: device.name,
          ip: device.ip,
          online: true,
          lastSeen: DateTime.now(),
        );
      }
    } catch (_) {}

    return Device(
      id: device.id,
      name: device.name,
      ip: device.ip,
      online: false,
      lastSeen: device.lastSeen,
    );
  }

  /// Activa el timbre de un dispositivo
  static Future<void> ringDevice(String ip, {int durationMs = 5000}) async {
    try {
      final uri = Uri.parse('http://$ip/ring?duration_ms=$durationMs');
      final response = await http.post(uri).timeout(
            const Duration(seconds: 2),
          );
      if (response.statusCode != 200) {
        throw Exception('Error al activar timbre');
      }
    } catch (e) {
      throw Exception('No se pudo conectar al dispositivo $ip: $e');
    }
  }

  /// Obtiene los horarios de un dispositivo
  static Future<List<ScheduleEntry>> getSchedule(Device device) async {
    try {
      final uri = Uri.parse('http://${device.ip}/schedule');
      final response = await http.get(uri).timeout(
            const Duration(seconds: 2),
          );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ScheduleEntry.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error al obtener horarios de ${device.name}: $e');
    }
  }

  /// Envía una lista de horarios a un dispositivo
  static Future<void> sendSchedule(
      Device device, List<ScheduleEntry> schedules) async {
    try {
      final uri = Uri.parse('http://${device.ip}/schedule');
      final jsonData = json.encode(schedules.map((e) => e.toJson()).toList());
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) {
        throw Exception('Error al enviar horarios a ${device.name}');
      }
    } catch (e) {
      throw Exception('No se pudo enviar horarios a ${device.name}: $e');
    }
  }
}
