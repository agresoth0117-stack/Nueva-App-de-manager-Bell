import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';

import 'providers/device_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/connection_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/devices/devices_screen.dart';
import 'screens/schedule/schedule_screen.dart'; // WeeklyScheduleScreen
import 'screens/history/history_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceProvider>(
          create: (_) => DeviceProvider(),
        ),
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider(),
        ),
        ChangeNotifierProvider<ConnectionProvider>(
          create: (_) => ConnectionProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Control de Timbres',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),

        // Pantalla inicial
        home: const HomeScreen(),

        // Rutas disponibles
        routes: {
          "/home": (_) => const HomeScreen(),
          "/devices": (_) => const DevicesScreen(),
          "/schedule": (_) => WeeklyScheduleScreen(selectedDevices: []),
          "/history": (_) => const HistoryScreen(),
          "/settings": (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
