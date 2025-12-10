import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/device_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/home/home_screen.dart'; // <-- Importa tu HomeScreen

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Control de Timbres',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),

        // ---------------------------------------------------
        // Pantalla inicial: HomeScreen
        // ---------------------------------------------------
        home: const HomeScreen(),

        // ---------------------------------------------------
        // Rutas disponibles
        // ---------------------------------------------------
        routes: {
          "/schedule": (_) => const ScheduleScreen(),
          "/home": (_) => const HomeScreen(),
        },
      ),
    );
  }
}
