import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({super.key});

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
            Icon(Icons.wifi, color: AppColors.primary, size: 32),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("12 dispositivos conectados", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Red estable", style: TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
