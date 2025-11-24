import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dispositivo.dart';

class EspService {
  // Método para cargar todos los dispositivos desde tu API/ESP
  static Future<List<Dispositivo>> loadDispositivos() async {
    try {
      final response = await http.get(Uri.parse('http://TU_IP_O_DOMINIO/dispositivos'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dispositivo.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar dispositivos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en EspService.loadDispositivos: $e');
      return [];
    }
  }

  // Método para enviar horarios a un dispositivo
  static Future<bool> postHorarios(String ip, List horarios) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ip/horarios'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(horarios),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error en EspService.postHorarios: $e');
      return false;
    }
  }
}
