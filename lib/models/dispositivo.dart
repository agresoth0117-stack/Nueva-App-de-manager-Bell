import 'horario.dart';

class Dispositivo {
  String nombre;                    // Nombre o alias del ESP
  String ip;                        // Dirección IP
  bool online;                      // Estado Online/Offline
  bool seleccionado;                // Para seleccionar varios dispositivos
  List<Horario> horariosAsignados;  // Horarios asignados a este dispositivo

  Dispositivo({
    required this.nombre,
    required this.ip,
    this.online = false,
    this.seleccionado = false,
    this.horariosAsignados = const [],
  });

  // Método para convertir a JSON (útil para enviar al ESP)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ip': ip,
      'online': online,
      'horariosAsignados': horariosAsignados.map((h) => h.toJson()).toList(),
    };
  }

  // Crear objeto desde JSON (útil al leer del ESP o de almacenamiento local)
  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    var list = json['horariosAsignados'] as List? ?? [];
    List<Horario> horarios = list.map((h) => Horario.fromJson(h)).toList();

    return Dispositivo(
      nombre: json['nombre'],
      ip: json['ip'],
      online: json['online'] ?? false,
      seleccionado: json['seleccionado'] ?? false,
      horariosAsignados: horarios,
    );
  }
}
