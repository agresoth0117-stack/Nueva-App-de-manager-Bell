class Horario {
  String nombre;                   // Nombre del horario
  Map<String, List<String>> dias;  // Días con horas, ej: {"Lunes": ["07:00","12:00"]}
  List<String> espAsignados;       // IPs de ESP asignados a este horario

  Horario({
    required this.nombre,
    required this.dias,
    required this.espAsignados,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'dias': dias,
      'espAsignados': espAsignados,
    };
  }

  factory Horario.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> diasMap = Map<String, dynamic>.from(json['dias'] ?? {});
    Map<String, List<String>> diasParsed = {};
    diasMap.forEach((key, value) {
      diasParsed[key] = List<String>.from(value);
    });

    return Horario(
      nombre: json['nombre'],
      dias: diasParsed,
      espAsignados: List<String>.from(json['espAsignados'] ?? []),
    );
  }
}
