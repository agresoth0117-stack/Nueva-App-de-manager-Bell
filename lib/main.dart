import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/device_provider.dart';
import 'providers/schedule_provider.dart';
import 'screens/schedule/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aquí puedes cargar datos iniciales si lo deseas en el futuro:
  // await SomeStorage.init();

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
        home: const ScheduleScreen(),   // Pantalla principal
      ),
    );
  }
}
