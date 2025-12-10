import '../models/device.dart';
import '../services/storage_service.dart';
import '../services/device_comm_service.dart';
import 'device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final StorageServiceImpl storage;
  final DeviceCommService deviceComm;

  DeviceRepositoryImpl({
    required this.storage,
    required this.deviceComm,
  });

  List<Device> _cache = [];

  @override
  Future<List<Device>> getAll() async {
    final raw = await storage.loadDevices();
    _cache = raw.map((m) => Device.fromMap(Map<String, dynamic>.from(m))).toList();
    return _cache;
  }

  @override
  Future<void> add(Device d) async {
    _cache.add(d);
    await storage.saveDevices(_cache.map((e) => e.toMap()).toList());
  }

  @override
  Future<void> update(Device d) async {
    final i = _cache.indexWhere((x) => x.id == d.id);
    if (i != -1) {
      _cache[i] = d;
      await storage.saveDevices(_cache.map((e) => e.toMap()).toList());
    }
  }

  @override
  Future<void> delete(String id) async {
    _cache.removeWhere((d) => d.id == id);
    await storage.saveDevices(_cache.map((e) => e.toMap()).toList());
  }

  @override
  Future<void> pingDevices(List<String> ids) async {
    for (final id in ids) {
      final d = _cache.firstWhere((e) => e.id == id);
      d.online = await deviceComm.ping(d.ip);
      d.lastSeen = DateTime.now();
    }
    await storage.saveDevices(_cache.map((e) => e.toMap()).toList());
  }

    @override
  Future<void> sendCommandToAll(String command) async {
    for (final d in _cache) {
      try {
        await deviceComm.sendCommand(d.ip, command);
      } catch (e) {
        // silenciar errores individuales
      }
    }
    // no es necesario salvar aquí, pero actualizamos lastSeen
    final now = DateTime.now();
    for (final d in _cache) {
      d.lastSeen = now;
    }
    await storage.saveDevices(_cache.map((e) => e.toMap()).toList());
  }

}
