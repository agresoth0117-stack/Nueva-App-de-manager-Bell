import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dispositivo.dart';

class EspService {
  static const String baseUrl = "http://TU_IP_O_DOMINIO";

  /// -------------------------------------------------------------
  /// CARGAR LISTA DE DISPOSITIVOS DESDE API/ESP
  /// -------------------------------------------------------------
  static Future<List<Dispositivo>> loadDispositivos() async {
    try {
      final url = Uri.parse("$baseUrl/dispositivos");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        return data.map((json) => Dispositivo.fromJson(json)).toList();
      } else {
        throw Exception(
          "Servidor respondió con código ${response.statusCode}",
        );
      }
    } catch (e) {
      print("❌ Error en EspService.loadDispositivos: $e");
      return [];
    }
  }

  /// -------------------------------------------------------------
  /// ENVIAR HORARIOS A UN DISPOSITIVO ESPECÍFICO
  /// -------------------------------------------------------------
  static Future<bool> postHorarios(String ip, List horarios) async {
    try {
      final url = Uri.parse("http://$ip/horarios");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(horarios),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("⚠️ Error: código HTTP ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error en EspService.postHorarios: $e");
      return false;
    }
  }
}
