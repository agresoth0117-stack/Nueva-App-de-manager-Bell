import 'package:http/http.dart' as http;

abstract class DeviceCommService {
  Future<bool> ping(String ip);
  Future<bool> sendCommand(String ip, String command);
}

class DeviceCommServiceImpl implements DeviceCommService {
  @override
  Future<bool> ping(String ip) async {
    try {
      final r = await http.get(Uri.parse('http://$ip/ping')).timeout(
        const Duration(seconds: 2),
      );
      return r.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> sendCommand(String ip, String command) async {
    try {
      final r = await http.get(Uri.parse('http://$ip/cmd?c=$command'));
      return r.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
