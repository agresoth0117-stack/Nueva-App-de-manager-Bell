class HorarioDiario {
  String nombre;
  Map<String, List<String>> dias; 
  String dispositivoIp;

  HorarioDiario({
    required this.nombre,
    required this.dias,
    required this.dispositivoIp,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'dias': dias,
        'dispositivoIp': dispositivoIp,
      };

  factory HorarioDiario.fromJson(Map<String, dynamic> json) {
    final diasMap = Map<String, dynamic>.from(json['dias'] ?? {});
    final parsed = <String, List<String>>{};

    diasMap.forEach((key, value) {
      parsed[key] = List<String>.from(value);
    });

    return HorarioDiario(
      nombre: json['nombre'],
      dias: parsed,
      dispositivoIp: json['dispositivoIp'],
    );
  }
}
