import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(ManagerBellApp());
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
