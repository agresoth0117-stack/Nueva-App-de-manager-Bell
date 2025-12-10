import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../home/home_status_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final events = scheduleProvider.eventsForToday(limit: 50);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return HomeStatusCard(
            title: event.title,
            subtitle:
                "${event.time.format(context)} · ${scheduleProvider.getDevicesForEventText(event)}",
          );
        },
      ),
    );
  }
}
