// lib/services/esp_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';

class EspService {
  /// Obtiene los horarios almacenados actualmente en el ESP
  static Future<List<Horario>> getHorarios(String ip) async {
    try {
      final url = Uri.parse("http://$ip/get_horarios");
      final resp = await http.get(url).timeout(Duration(seconds: 3));

      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        return data.map((h) => Horario.fromJson(h)).toList();
      }
    } catch (_) {}

    return [];
  }

  /// Envía todos los horarios al ESP y los reemplaza en el dispositivo
  static Future<bool> postHorarios(String ip, List<Horario> horarios) async {
    try {
      final url = Uri.parse("http://$ip/set_horarios");

      final body = jsonEncode(
        horarios.map((h) => h.toJson()).toList(),
      );

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      ).timeout(Duration(seconds: 4));

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Alternativa: enviar un solo horario a un ESP
  static Future<bool> postSingleHorario(String ip, Horario horario) async {
    try {
      final url = Uri.parse("http://$ip/set_horario");

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(horario.toJson()),
      ).timeout(Duration(seconds: 4));

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Chequeo de status simple
  static Future<bool> ping(String ip) async {
    try {
      final url = Uri.parse("http://$ip/status");
      final resp = await http.get(url).timeout(Duration(seconds: 2));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
