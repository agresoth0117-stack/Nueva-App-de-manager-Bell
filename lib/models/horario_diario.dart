class HorarioDiario {
  String nombre;
  Map<String, List<String>> dias; // 'Lunes', 'Martes', ...
  String dispositivoIp; // Horario específico para este ESP

  HorarioDiario({required this.nombre, required this.dias, required this.dispositivoIp});

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'dias': dias,
        'dispositivoIp': dispositivoIp,
      };

  factory HorarioDiario.fromJson(Map<String, dynamic> json) => HorarioDiario(
        nombre: json['nombre'],
        dias: Map<String, List<String>>.from(json['dias']),
        dispositivoIp: json['dispositivoIp'],
      );
}
