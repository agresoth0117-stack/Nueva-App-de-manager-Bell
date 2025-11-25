import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dispositivos_screen.dart';
import 'horarios_screen.dart';
import 'historial_screen.dart';
import 'ajustes_screen.dart';
import '../models/dispositivo.dart';

class DashboardScreen extends StatefulWidget {
  final List<Dispositivo> dispositivos;

  const DashboardScreen({super.key, this.dispositivos = const []});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _horaActual = '';
  String _fechaActual = '';

  @override
  void initState() {
    super.initState();
    _actualizarHora();
  }

  void _actualizarHora() {
    final now = DateTime.now();
    setState(() {
      _horaActual = DateFormat.Hms().format(now);
      _fechaActual = DateFormat.yMMMMEEEEd().format(now);
    });

    // Actualiza cada segundo
    Future.delayed(Duration(seconds: 1), _actualizarHora);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manager Bell - Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _horaActual,
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(
              _fechaActual,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DispositivosScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.devices),
                  label: Text('Dispositivos'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HorariosScreen(dispositivos: widget.dispositivos),
                      ),
                    );
                  },
                  icon: Icon(Icons.schedule),
                  label: Text('Horarios'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HistorialScreen()),
                    );
                  },
                  icon: Icon(Icons.history),
                  label: Text('Historial'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AjustesScreen()),
                    );
                  },
                  icon: Icon(Icons.settings),
                  label: Text('Ajustes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
