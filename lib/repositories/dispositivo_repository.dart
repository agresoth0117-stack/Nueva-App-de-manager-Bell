// lib/repositories/dispositivo_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/dispositivo.dart';
import '../services/esp_scanner_service.dart';

class DispositivoRepository {
  static const String _storageKey = 'dispositivos_v1';

  /// Cargar lista persistida (si no existe retorna lista vacía)
  static Future<List<Dispositivo>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null) return [];
    try {
      return jsonList
          .map((s) => Dispositivo.fromJson(jsonDecode(s)))
          .toList();
    } catch (e) {
      // Si hay corrupción, limpiar y devolver vacío
      await prefs.remove(_storageKey);
      return [];
    }
  }

  /// Guardar lista completa
  static Future<void> saveAll(List<Dispositivo> dispositivos) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList =
        dispositivos.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Añadir o actualizar (busca por ip)
  static Future<void> addOrUpdate(Dispositivo device) async {
    final list = await loadAll();
    final idx = list.indexWhere((d) => d.ip == device.ip);
    if (idx >= 0) {
      list[idx] = device;
    } else {
      list.add(device);
    }
    await saveAll(list);
  }

  /// Eliminar por IP
  static Future<void> removeByIp(String ip) async {
    final list = await loadAll();
    list.removeWhere((d) => d.ip == ip);
    await saveAll(list);
  }

  /// Marca online/offline haciendo GET http://IP/status con timeout
  static Future<bool> _pingStatus(String ip, {Duration timeout = const Duration(seconds:2)}) async {
    try {
      final url = Uri.parse('http://$ip/status');
      final resp = await http.get(url).timeout(timeout);
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Revisa el estado online/offline de todos los dispositivos guardados y los actualiza.
  /// Devuelve la lista actualizada.
  static Future<List<Dispositivo>> updateStatuses({Duration timeout = const Duration(seconds:2)}) async {
    final list = await loadAll();
    for (int i = 0; i < list.length; i++) {
      final online = await _pingStatus(list[i].ip, timeout: timeout);
      list[i].online = online;
    }
    await saveAll(list);
    return list;
  }

  /// Escanea la red (usa tu EspScannerService) y MERGE con la lista persistida:
  /// - Si aparece un dispositivo nuevo -> se añade persistente
  /// - Si dispositivo ya existe actualiza nombre/online
  /// Devuelve la lista resultante guardada.
  static Future<List<Dispositivo>> scanAndMerge({String? baseIp}) async {
    // Cargar guardados
    final saved = await loadAll();
    // Escanear red (tu servicio). scanAuto usa subnet detectada; si quieres pasar baseIp,
    // modifica EspScannerService.scanRange; aquí llamamos scanAuto().
    List<Dispositivo> encontrados;
    try {
      encontrados = await EspScannerService.scanAuto();
    } catch (e) {
      encontrados = [];
    }

    // Map por IP para búsquedas rápidas
    final Map<String, Dispositivo> mapa = { for (var d in saved) d.ip : d };

    // Merge: actualizar o insertar
    for (var e in encontrados) {
      if (mapa.containsKey(e.ip)) {
        // actualizar nombre y estado online
        final existing = mapa[e.ip]!;
        existing.nombre = e.nombre;
        existing.online = true;
        // no tocar horariosAsignados ni seleccionado si ya existía
      } else {
        // nuevo: agregar (online true por hallazgo)
        mapa[e.ip] = e;
      }
    }

    // Marcar offline a los guardados que no aparecieron en el escaneo
    for (var kv in mapa.entries) {
      final ip = kv.key;
      final device = kv.value;
      final encontrado = encontrados.any((d) => d.ip == ip);
      if (!encontrado) device.online = await _pingStatus(device.ip);
    }

    final resultado = mapa.values.toList();
    await saveAll(resultado);
    return resultado;
  }
}
