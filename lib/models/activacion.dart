class Activacion {
  String dispositivo;   // Nombre o IP del ESP
  String tipo;          // "Manual" o "Programado"
  DateTime fechaHora;   // Fecha y hora de activación
  int duracionMs;       // Duración del timbre en milisegundos

  Activacion({
    required this.dispositivo,
    required this.tipo,
    required this.fechaHora,
    required this.duracionMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'dispositivo': dispositivo,
      'tipo': tipo,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMs': duracionMs,
    };
  }

  factory Activacion.fromJson(Map<String, dynamic> json) {
    return Activacion(
      dispositivo: json['dispositivo'],
      tipo: json['tipo'],
      fechaHora: DateTime.parse(json['fechaHora']),
      duracionMs: json['duracionMs'],
    );
  }
}
