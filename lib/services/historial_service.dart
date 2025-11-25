import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activacion.dart';

class HistorialService {
  static const String _historialKey = 'historial';

  // Guardar una activación en el historial
  static Future<void> addActivacion(Activacion activacion) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> historial = prefs.getStringList(_historialKey) ?? [];
    historial.add(jsonEncode(activacion.toJson()));
    await prefs.setStringList(_historialKey, historial);
  }

  // Leer historial completo
  static Future<List<Activacion>> getHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? historial = prefs.getStringList(_historialKey);
    if (historial == null) return [];
    return historial.map((h) => Activacion.fromJson(jsonDecode(h))).toList();
  }

  // Limpiar historial
  static Future<void> clearHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historialKey);
  }
}
