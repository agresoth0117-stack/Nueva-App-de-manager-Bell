import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/horario.dart';
import '../models/horario_diario.dart';

class ScheduleService {
  static const String _horariosKey = 'horarios';
  static const String _horariosDiariosKey = 'horarios_diarios';

  // ---------------------------------------------------
  // GUARDAR Y CARGAR HORARIOS SEMANALES (Horario)
  // ---------------------------------------------------

  static Future<void> saveHorarios(List<Horario> horarios) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        horarios.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_horariosKey, jsonList);
  }

  static Future<List<Horario>> loadHorarios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_horariosKey);
    if (jsonList == null) return [];

    try {
      return jsonList
          .map((h) => Horario.fromJson(jsonDecode(h)))
          .toList();
    } catch (_) {
      // Corrupción => borrar
      await prefs.remove(_horariosKey);
      return [];
    }
  }

  // ---------------------------------------------------
  // GUARDAR Y CARGAR HORARIOS DIARIOS (HorarioDiario)
  // ---------------------------------------------------

  static Future<void> saveHorariosDiarios(
      List<HorarioDiario> horariosDiarios) async {
    final prefs = await SharedPreferences.getInstance();

    // Convertimos a JSONList para evitar errores de mapas
    final List<Map<String, dynamic>> jsonList =
        horariosDiarios.map((h) => h.toJson()).toList();

    await prefs.setString(
      _horariosDiariosKey,
      jsonEncode(jsonList),
    );
  }

  static Future<List<HorarioDiario>> loadHorariosDiarios() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_horariosDiariosKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> list = jsonDecode(jsonString);

      return list
          .map((item) =>
              HorarioDiario.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await prefs.remove(_horariosDiariosKey);
      return [];
    }
  }
}
