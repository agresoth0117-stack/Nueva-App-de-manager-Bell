import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  double duracionTimbre = 5.0; // segundos
  bool notificaciones = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      duracionTimbre = prefs.getDouble('duracionTimbre') ?? 5.0;
      notificaciones = prefs.getBool('notificaciones') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('duracionTimbre', duracionTimbre);
    await prefs.setBool('notificaciones', notificaciones);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Ajustes guardados')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes Generales'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Duración del timbre (segundos): ${duracionTimbre.toInt()}'),
              ],
            ),
            Slider(
              value: duracionTimbre,
              min: 1,
              max: 15,
              divisions: 14,
              label: duracionTimbre.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  duracionTimbre = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Notificaciones activas'),
              value: notificaciones,
              onChanged: (val) {
                setState(() {
                  notificaciones = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
