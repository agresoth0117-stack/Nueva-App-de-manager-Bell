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

    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}";
    final dateString = "${now.day}/${now.month}/${now.year} ${_weekdayName(now.weekday)}";

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: const Text(
          "Manager Bell",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        actions: [
          Icon(
            Icons.wifi,
            color: deviceProvider.isConnected ? Colors.orange : Colors.white,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hora y fecha
            Center(
              child: Column(
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Próximo evento con parpadeo si está cerca
            NextEventCard(
              nextEventText: nextEventText,
              isSoon: scheduleProvider.isNextEventSoon(),
            ),
            const SizedBox(height: 24),

            // Grid de botones 2x2: Dispositivos, Horarios, Historial, Ajustes
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _HomeButton(
                  label: "Dispositivos",
                  icon: Icons.devices,
                  onTap: () => Navigator.pushNamed(context, "/devices"),
                ),
                _HomeButton(
                  label: "Horarios",
                  icon: Icons.schedule,
                  onTap: () => Navigator.pushNamed(context, "/schedule"),
                ),
                _HomeButton(
                  label: "Historial",
                  icon: Icons.history,
                  onTap: () => Navigator.pushNamed(context, "/history"),
                ),
                _HomeButton(
                  label: "Ajustes",
                  icon: Icons.settings,
                  onTap: () => Navigator.pushNamed(context, "/settings"),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Último evento
            _SectionCard(
              title: "Último evento",
              icon: Icons.history,
              child: Text(
                lastEventText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de eventos de hoy (usando todayEventsText)
            _SectionCard(
              title: "Eventos de hoy",
              icon: Icons.today,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: todayEventsText
                    .map((e) => Text(
                          e,
                          style: const TextStyle(fontSize: 14),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de emergencia
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

  String _weekdayName(int wd) {
    switch (wd) {
      case 1:
        return "Lunes";
      case 2:
        return "Martes";
      case 3:
        return "Miércoles";
      case 4:
        return "Jueves";
      case 5:
        return "Viernes";
      case 6:
        return "Sábado";
      case 7:
        return "Domingo";
      default:
        return "";
    }
  }
}

// --------------------------
// Home Button Widget
// --------------------------
class _HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HomeButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.shade800,
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------
// Section Card Widget
// --------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? color;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
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
          child,
        ],
      ),
    );
  }
}

// --------------------------
// Next Event Card con parpadeo
// --------------------------
class NextEventCard extends StatefulWidget {
  final String nextEventText;
  final bool isSoon;

  const NextEventCard({
    super.key,
    required this.nextEventText,
    required this.isSoon,
  });

  @override
  State<NextEventCard> createState() => _NextEventCardState();
}

class _NextEventCardState extends State<NextEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    );

    if (widget.isSoon) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant NextEventCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSoon && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSoon && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: _SectionCard(
        title: "Próximo Evento",
        icon: Icons.schedule,
        color: widget.isSoon ? Colors.red.shade100 : Colors.white,
        child: Text(
          widget.nextEventText,
          style: TextStyle(
            fontSize: 16,
            color: widget.isSoon ? Colors.red.shade800 : Colors.black,
            fontWeight:
                widget.isSoon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
