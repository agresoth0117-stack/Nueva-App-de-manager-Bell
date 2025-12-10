// lib/providers/schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule.dart';

class ScheduleProvider with ChangeNotifier {
  final List<ScheduleEvent> _events = [];
  Set<String> selectedDeviceIds = {};

  ScheduleProvider() {
    _loadMock();
  }

  List<ScheduleEvent> get events => List.unmodifiable(_events);

  // ---------------------------------------------------------
  // CARGA INICIAL (DEMO)
  // ---------------------------------------------------------
  void _loadMock() {
    final u = Uuid();
    _events.clear();
    _events.addAll([
      ScheduleEvent(
        id: u.v4(),
        title: 'Entrada',
        time: const TimeOfDay(hour: 8, minute: 0),
        action: ActionType.turnOn,
        deviceIds: [],
      ),
      ScheduleEvent(
        id: u.v4(),
        title: 'Cambio de hora',
        time: const TimeOfDay(hour: 10, minute: 40),
        action: ActionType.turnOn,
        deviceIds: [],
      ),
      ScheduleEvent(
        id: u.v4(),
        title: 'Almuerzo',
        time: const TimeOfDay(hour: 12, minute: 0),
        action: ActionType.turnOff,
        deviceIds: [],
      ),
    ]);
    notifyListeners();
  }

  // ---------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------
  void addEvent(ScheduleEvent e) {
    _events.add(e);
    notifyListeners();
  }

  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateEvent(ScheduleEvent e) {
    final idx = _events.indexWhere((x) => x.id == e.id);
    if (idx != -1) {
      _events[idx] = e;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------
  // Selección temporal de dispositivos
  // ---------------------------------------------------------
  void setSelectedDevices(Set<String> ids) {
    selectedDeviceIds = ids;
    notifyListeners();
  }

  void toggleDeviceSelection(String id) {
    if (selectedDeviceIds.contains(id)) {
      selectedDeviceIds.remove(id);
    } else {
      selectedDeviceIds.add(id);
    }
    notifyListeners();
  }

  void clearSelectedDevices() {
    selectedDeviceIds.clear();
    notifyListeners();
  }

  void assignSelectedDevicesToEvent(String eventId) {
    final i = _events.indexWhere((e) => e.id == eventId);
    if (i != -1) {
      _events[i] = _events[i].copyWith(deviceIds: selectedDeviceIds.toList());
      notifyListeners();
    }
  }

  String getDevicesForEventText(ScheduleEvent e) {
    if (e.deviceIds.isEmpty) return "No asignado";
    return "Dispositivos: ${e.deviceIds.length}";
  }

  // ---------------------------------------------------------
  // Próximo evento
  // ---------------------------------------------------------
  ScheduleEvent? getNextEvent() {
    final now = TimeOfDay.now();
    ScheduleEvent? candidate;
    for (final e in _events) {
      if (_isAfterOrEqual(e.time, now)) {
        if (candidate == null || _compareTimeOfDay(e.time, candidate.time) < 0) {
          candidate = e;
        }
      }
    }
    return candidate;
  }

  String getNextEventText() {
    final e = getNextEvent();
    if (e == null) return "No hay más eventos para hoy";
    return "${_formatTime(e.time)} · ${e.title}";
  }

  /// ---------------------------------------------------------
  /// ✅ Nuevo método agregado
  /// Devuelve true si el próximo evento es dentro de los próximos 30 minutos
  bool isNextEventSoon() {
    final nextEvent = getNextEvent();
    if (nextEvent == null) return false;

    final now = TimeOfDay.now();
    int diffMinutes = (nextEvent.time.hour - now.hour) * 60 + (nextEvent.time.minute - now.minute);
    return diffMinutes >= 0 && diffMinutes <= 30;
  }

  // ---------------------------------------------------------
  // Eventos del día
  // ---------------------------------------------------------
  List<ScheduleEvent> eventsForToday({int limit = 5}) {
    final list = _events.toList()
      ..sort((a, b) => _compareTimeOfDay(a.time, b.time));
    return list.take(limit).toList();
  }

  List<String> getEventsForTodayText() {
    return eventsForToday(limit: 10)
        .map((e) => "• ${_formatTime(e.time)} - ${e.title}")
        .toList();
  }

  // ---------------------------------------------------------
  // Último evento
  // ---------------------------------------------------------
  ScheduleEvent? getLastEvent() {
    final now = TimeOfDay.now();
    ScheduleEvent? last;
    for (final e in _events) {
      if (_isAfterOrEqual(now, e.time)) {
        if (last == null || _compareTimeOfDay(e.time, last.time) > 0) {
          last = e;
        }
      }
    }
    return last;
  }

  String getLastEventText() {
    final e = getLastEvent();
    if (e == null) return "Sin eventos recientes";
    return "${_formatTime(e.time)} · ${e.title}";
  }

  // ---------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------
  bool _isAfterOrEqual(TimeOfDay a, TimeOfDay b) {
    return a.hour > b.hour || (a.hour == b.hour && a.minute >= b.minute);
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour - b.hour;
    return a.minute - b.minute;
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $suffix";
  }
}
