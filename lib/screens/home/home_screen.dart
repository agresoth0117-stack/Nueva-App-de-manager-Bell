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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestor de Timbres",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 3,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // 🔔 PRÓXIMO TIMBRE
            // -------------------------------------------------
            _SectionCard(
              title: "Próximo timbre",
              icon: Icons.schedule,
              child: Text(
                nextEventText,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------
            // 📅 EVENTOS DEL DÍA
            // -------------------------------------------------
            _SectionCard(
              title: "Eventos del día",
              icon: Icons.event,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: todayEventsText
                    .map(
                      (txt) => Text(
                        txt,
                        style: const TextStyle(fontSize: 15),
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------
            // 📟 DISPOSITIVOS CONECTADOS (MODIFICADO)
            // -------------------------------------------------
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
                      // abre el selector de dispositivos
                      Navigator.pushNamed(context, "/deviceSelector");
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: const Text("Gestionar dispositivos"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------
            // 🕒 ÚLTIMO EVENTO
            // -------------------------------------------------
            _SectionCard(
              title: "Último evento",
              icon: Icons.history,
              child: Text(
                lastEventText,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------------------------------
            // 🚨 BOTÓN DE EMERGENCIA
            // -------------------------------------------------
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

//
// -----------------------------------------------------------
// Card reutilizable
// -----------------------------------------------------------
//

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con ícono
          Row(
            children: [
              Icon(icon, color: Colors.blueGrey.shade700),
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

          // Contenido
          child,
        ],
      ),
    );
  }
}
