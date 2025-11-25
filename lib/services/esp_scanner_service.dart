import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dispositivo.dart';

class EspScannerService {
  // Escaneo en un rango de IPs (ej: 192.168.1.1-254)
  static Future<List<Dispositivo>> scanRange(
      {String baseIp = '192.168.1.', int start = 1, int end = 254}) async {
    List<Dispositivo> encontrados = [];

    for (int i = start; i <= end; i++) {
      String ip = '$baseIp$i';
      try {
        var status = await _getStatus(ip);
        if (status != null) {
          encontrados.add(Dispositivo(
            nombre: status['hostname'] ?? ip,
            ip: ip,
            online: true,
          ));
        }
      } catch (_) {
        // Ignorar si no responde
      }
    }

    return encontrados;
  }

  static Future<Map<String, dynamic>?> _getStatus(String ip) async {
    try {
      var url = Uri.parse('http://$ip/status');
      var response = await http.get(url).timeout(Duration(seconds: 2));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }
}
