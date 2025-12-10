import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Bienvenido", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("Gestión de Timbres", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),

          Icon(Icons.notifications, size: 30, color: AppColors.primary),
        ],
      ),
    );
  }
}
