// lib/models/schedule.dart
import 'package:flutter/material.dart';

enum ActionType { turnOn, turnOff }

class ScheduleEvent {
  final String id;
  final String title;
  final TimeOfDay time;
  final ActionType action;
  final List<String> deviceIds;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.action,
    required this.deviceIds,
  });

  /// Crea una copia del evento reemplazando solo los campos entregados.
  ScheduleEvent copyWith({
    String? id,
    String? title,
    TimeOfDay? time,
    ActionType? action,
    List<String>? deviceIds,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      action: action ?? this.action,
      deviceIds: deviceIds ?? List<String>.from(this.deviceIds),
    );
  }

  @override
  String toString() {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return 'ScheduleEvent(id: $id, title: $title, time: $hour:$minute, action: $action, devices: ${deviceIds.length})';
  }
}
