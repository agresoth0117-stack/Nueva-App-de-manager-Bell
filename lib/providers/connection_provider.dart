// lib/providers/connection_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  late StreamSubscription<ConnectivityResult> _subscription;

  ConnectionProvider() {
    _init();
  }

  void _init() async {
    // Estado inicial
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateStatus(connectivityResult);

    // Escucha cambios de conexión
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    bool newStatus = result != ConnectivityResult.none;
    if (newStatus != _isConnected) {
      _isConnected = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
