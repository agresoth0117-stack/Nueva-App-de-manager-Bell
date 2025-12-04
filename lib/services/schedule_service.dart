import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/horario.dart';
import '../models/horario_diario.dart';

class ScheduleService {
  static const String _horariosKey = 'horarios';
  static const String _horariosDiariosKey = 'horarios_diarios';

  // -----------------------------
  // Métodos existentes para Horario
  // -----------------------------
  static Future<void> saveHorarios(List<Horario> horarios) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> jsonList = horarios.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList(_horariosKey, jsonList);
  }

  static Future<List<Horario>> loadHorarios() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_horariosKey);
    if (jsonList == null) return [];
    return jsonList.map((h) => Horario.fromJson(jsonDecode(h))).toList();
  }

  // -----------------------------
  // Nuevos métodos para HorarioDiario
  // -----------------------------
  static Future<void> saveHorariosDiarios(List<HorarioDiario> horariosDiarios) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(horariosDiarios.map((h) => h.toJson()).toList());
    await prefs.setString(_horariosDiariosKey, jsonString);
  }

  static Future<List<HorarioDiario>> loadHorariosDiarios() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_horariosDiariosKey);
    if (jsonString == null) return [];
    List<dynamic> data = jsonDecode(jsonString);
    return data.map((json) => HorarioDiario.fromJson(json)).toList();
  }
}
