import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Solicitar permisos antes de iniciar la app
  await _requestPermissions();

  runApp(ManagerBellApp());
}

Future<void> _requestPermissions() async {
  // Permisos necesarios para escanear red WiFi en Android

  // Para poder obtener la IP local y escanear subred
  await Permission.locationWhenInUse.request();

  // En Android 10+ para usar APIs de WiFi
  await Permission.location.request();

  // En Android 12+ (muy importante)
  if (await Permission.nearbyWifiDevices.isDenied) {
    await Permission.nearbyWifiDevices.request();
  }
}

class ManagerBellApp extends StatelessWidget {
  const ManagerBellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manager Bell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
