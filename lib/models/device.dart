class Device {
  final String id;
  String name;
  String ip;
  bool online;
  String? tag;
  DateTime? lastSeen;

  Device({
    required this.id,
    required this.name,
    required this.ip,
    this.online = false,
    this.tag,
    this.lastSeen,
  });

  factory Device.fromMap(Map<String, dynamic> m) => Device(
        id: m['id'],
        name: m['name'],
        ip: m['ip'],
        online: m['online'] ?? false,
        tag: m['tag'],
        lastSeen: m['lastSeen'] != null
            ? DateTime.parse(m['lastSeen'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ip': ip,
        'online': online,
        'tag': tag,
        'lastSeen': lastSeen?.toIso8601String(),
      };
}
