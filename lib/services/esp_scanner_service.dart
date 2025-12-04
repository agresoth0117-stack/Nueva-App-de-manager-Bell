import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:manager_bell/models/dispositivo.dart';

class EspScannerService {
  /// Obtiene automáticamente la subred del dispositivo
  static Future<String> getSubnet() async {
    try {
      final interfaces = await NetworkInterface.list();

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.address.startsWith('127')) {
            final parts = addr.address.split('.');
            return '${parts[0]}.${parts[1]}.${parts[2]}.';
          }
        }
      }
    } catch (_) {}

    return '192.168.1.'; // fallback seguro
  }

  /// Escaneo automático de la red local
  static Future<List<Dispositivo>> scanAuto() async {
    final baseIp = await getSubnet();
    return scanRange(baseIp: baseIp);
  }

  /// Escaneo por rango de IPs
  /// Ahora con límite de tareas simultáneas para mayor velocidad/estabilidad
  static Future<List<Dispositivo>> scanRange({
    required String baseIp,
    int start = 1,
    int end = 254,
    int parallel = 30, // Límite de escaneo simultáneo
  }) async {
    final List<Dispositivo> encontrados = [];
    final List<Future> tareas = [];

    for (int i = start; i <= end; i++) {
      final ip = '$baseIp$i';

      // Se añade la tarea
      tareas.add(_scanIp(ip).then((status) {
        if (status != null) {
          encontrados.add(
            Dispositivo(
              nombre: status['hostname'] ?? ip,
              ip: ip,
              online: true,
            ),
          );
        }
      }));

      // Cuando se alcanza el límite, se espera
      if (tareas.length >= parallel) {
        await Future.wait(tareas);
        tareas.clear();
      }
    }

    // Esperar tareas restantes
    if (tareas.isNotEmpty) {
      await Future.wait(tareas);
    }

    return encontrados;
  }

  /// Revisa si un IP responde con /status
  static Future<Map<String, dynamic>?> _scanIp(String ip) async {
    try {
      final url = Uri.parse('http://$ip/status');
      final response = await http.get(url).timeout(
            const Duration(seconds: 2),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }
}
