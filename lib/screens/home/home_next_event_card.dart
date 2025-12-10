import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class HomeNextEventCard extends StatelessWidget {
  const HomeNextEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.alarm, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Próximo timbre en 5 minutos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Cambio de hora • 12:00 PM", style: TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
