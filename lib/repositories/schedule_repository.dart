import '../models/schedule_event.dart';

class ScheduleRepository {
  /// Aquí irán los horarios almacenados
  /// Por ahora usamos datos dummy para probar la UI
  List<ScheduleEvent> getTodayEvents() {
    return [
      ScheduleEvent(time: "08:15 AM", label: "Inicio de clases"),
      ScheduleEvent(time: "09:00 AM", label: "Cambio de clase"),
      ScheduleEvent(time: "12:00 PM", label: "Almuerzo"),
      ScheduleEvent(time: "02:00 PM", label: "Cambio de clase"),
    ];
  }
}
