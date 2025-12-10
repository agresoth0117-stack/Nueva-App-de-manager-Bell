// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/emergency_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();

    final nextEventText = scheduleProvider.getNextEventText();
    final lastEventText = scheduleProvider.getLastEventText();
    final todayEventsText = scheduleProvider.getEventsForTodayText();
    final isNextSoon = scheduleProvider.isNextEventSoon();

    final now = DateTime.now();
    final currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final currentDate = "${now.day}/${now.month}/${now.year}";

    // Verificar si hay al menos un dispositivo conectado
    final isConnected = deviceProvider.devices.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 2,
        title: const Text(
          "Manager Bell",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.wifi,
                  color: isConnected ? Colors.orange : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isConnected ? "Conectado" : "Desconectado",
                  style: TextStyle(
                    color: isConnected ? Colors.orange : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------------------
            // Hora y fecha
            // ---------------------------
            Center(
              child: Column(
                children: [
                  Text(
                    currentTime,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---------------------------
            // Próximo evento
            // ---------------------------
            _SectionCard(
              title: "Próximo evento",
              icon: Icons.schedule,
              highlight: isNextSoon,
              child: Text(
                nextEventText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------
            // Eventos del día
            // ---------------------------
            _SectionCard(
              title: "Eventos del día",
              icon: Icons.event,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: todayEventsText
                    .map((txt) => Text(
                          txt,
                          style: const TextStyle(fontSize: 15),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------
            // Último evento
            // ---------------------------
            _SectionCard(
              title: "Último evento",
              icon: Icons.history,
              child: Text(
                lastEventText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------
            // Dispositivos conectados
            // ---------------------------
            _SectionCard(
              title: "Dispositivos conectados",
              icon: Icons.devices,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${deviceProvider.devices.length} dispositivos registrados",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${deviceProvider.selected.length} seleccionados",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/deviceSelector");
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text("Gestionar dispositivos"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---------------------------
            // Botón de emergencia
            // ---------------------------
            Center(
              child: Column(
                children: const [
                  Text(
                    "Mantén presionado 3 segundos",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 12),
                  EmergencyButton(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---------------------------
            // Botones 2x2: Dispositivos, Horarios, Historial, Ajustes
            // ---------------------------
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _HomeButton(
                  icon: Icons.devices,
                  label: "Dispositivos",
                  onTap: () {
                    Navigator.pushNamed(context, "/devices");
                  },
                ),
                _HomeButton(
                  icon: Icons.schedule,
                  label: "Horarios",
                  onTap: () {
                    Navigator.pushNamed(context, "/schedule");
                  },
                ),
                _HomeButton(
                  icon: Icons.history,
                  label: "Historial",
                  onTap: () {
                    Navigator.pushNamed(context, "/history");
                  },
                ),
                _HomeButton(
                  icon: Icons.settings,
                  label: "Ajustes",
                  onTap: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// Card reutilizable
// -----------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool highlight;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        border: highlight ? Border.all(color: Colors.red, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[900]),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// -----------------------------------------------------------
// Botón home 2x2
// -----------------------------------------------------------
class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
