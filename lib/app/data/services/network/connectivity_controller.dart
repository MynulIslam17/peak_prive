import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  /// Radios report "none" for a moment while the app starts and while the
  /// device hands off between Wi-Fi and mobile data. Only a drop that lasts
  /// longer than this is worth interrupting the user for.
  static const Duration _offlineGrace = Duration(seconds: 3);

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _offlineTimer;
  bool _isDialogOpen = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectivityStatus);
  }

  @override
  void onClose() {
    _offlineTimer?.cancel();
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnection() async {
    _updateConnectivityStatus(await _connectivity.checkConnectivity());
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _offlineTimer ??= Timer(_offlineGrace, _showNoInternetDialog);
    } else {
      _offlineTimer?.cancel();
      _offlineTimer = null;
      _dismissNoInternetDialog();
    }
  }

  void _dismissNoInternetDialog() {
    if (!_isDialogOpen) return;
    _isDialogOpen = false;
    if (Get.isDialogOpen ?? false) Get.back();
  }

  void _showNoInternetDialog() {
    _offlineTimer = null;
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    Get.dialog(
      PopScope(
        canPop: false, // Prevents closing with the back button
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 10),
              Text("No Internet"),
            ],
          ),
          content: const Text(
            "Please check your internet connection and try again.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final results = await _connectivity.checkConnectivity();
                if (!results.contains(ConnectivityResult.none)) {
                  _dismissNoInternetDialog();
                }
              },
              child: const Text("RETRY"),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // User must interact or wait for connection
    );
  }
}
