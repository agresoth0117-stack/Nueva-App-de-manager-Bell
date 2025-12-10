import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class StorageServiceImpl {
  Box? _deviceBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    _deviceBox = await Hive.openBox('devices');
  }

  Future<List<Map>> loadDevices() async {
    return _deviceBox!.values.cast<Map>().toList();
  }

  Future<void> saveDevices(List<Map> list) async {
    await _deviceBox!.clear();
    await _deviceBox!.addAll(list);
  }
}
