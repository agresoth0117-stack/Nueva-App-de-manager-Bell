import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';

class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> {
  Timer? _holdTimer;
  double _progress = 0;
  bool _activated = false;

  void _startHolding() {
    _progress = 0;
    _activated = false;

    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() {
        _progress += 0.1; // 0 → 1 en 3 segundos (100ms * 10 = 1 sec)
      });

      if (_progress >= 1.0 && !_activated) {
        _activated = true;
        _holdTimer?.cancel();
        _triggerEmergency();
      }
    });
  }

  void _stopHolding() {
    _holdTimer?.cancel();
    setState(() {
      _progress = 0;
    });
  }

  Future<void> _triggerEmergency() async {
    final provider = context.read<DeviceProvider>();

    final ok = await provider.broadcastEmergency();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? "🚨 Timbres activados (Emergencia)"
                : "Error al activar los dispositivos",
          ),
          backgroundColor: ok ? Colors.redAccent : Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _startHolding(),
      onLongPressEnd: (_) => _stopHolding(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Fondo
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),

          // Progreso circular
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 6,
              color: Colors.red.shade900,
            ),
          ),

          // Icono de alarma
          const Icon(
            Icons.warning_amber_rounded,
            size: 55,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
