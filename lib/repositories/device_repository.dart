// lib/repositories/device_repository.dart
import '../models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getAll();
  Future<void> add(Device d);
  Future<void> update(Device d);
  Future<void> delete(String id);
  Future<void> pingDevices(List<String> ids);

  // nuevo: enviar comando a todos (útil para emergencia)
  Future<void> sendCommandToAll(String command);
}
