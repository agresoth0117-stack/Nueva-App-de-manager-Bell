import 'horario.dart';

class Dispositivo {
  String nombre;
  String ip;
  bool online;
  bool seleccionado;
  List<Horario> horariosAsignados;

  Dispositivo({
    required this.nombre,
    required this.ip,
    this.online = false,
    this.seleccionado = false,
    List<Horario>? horariosAsignados,
  }) : horariosAsignados = horariosAsignados ?? [];
  

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'ip': ip,
      'online': online,
      'seleccionado': seleccionado,
      'horariosAsignados':
          horariosAsignados.map((h) => h.toJson()).toList(),
    };
  }

  factory Dispositivo.fromJson(Map<String, dynamic> json) {
    var list = json['horariosAsignados'] as List? ?? [];
    List<Horario> horarios =
        list.map((h) => Horario.fromJson(h)).toList();

    return Dispositivo(
      nombre: json['nombre'],
      ip: json['ip'],
      online: json['online'] ?? false,
      seleccionado: json['seleccionado'] ?? false,
      horariosAsignados: horarios,
    );
  }
}
