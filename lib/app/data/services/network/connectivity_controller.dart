import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  bool _isDialogOpen = false;

  @override
  void onInit() {
    super.onInit();
    // 1. Check connectivity status on app startup
    _checkInitialConnection();

    // 2. Listen for real-time connectivity changes
    // Note: Use List<ConnectivityResult> for newer versions of connectivity_plus
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      debugPrint("NETWORK_DEBUG: Connectivity Changed! Current Status: $results");
      _updateConnectivityStatus(results);
    });
  }

  Future<void> _checkInitialConnection() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    debugPrint("NETWORK_DEBUG: Initial Check Result: $results");
    _updateConnectivityStatus(results);
  }

  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    bool hasNoInternet = results.contains(ConnectivityResult.none);

    if (hasNoInternet) {
      debugPrint("NETWORK_DEBUG: No Internet detected!");

      if (!_isDialogOpen) {
        _isDialogOpen = true;
        _showNoInternetDialog();
      }
    } else {
      debugPrint("NETWORK_DEBUG: Internet is Connected!");

      if (_isDialogOpen) {
        _isDialogOpen = false;
        if (Get.isDialogOpen ?? false) {
          Get.back(); // Closes the dialog
        }

        // Brief confirmation snackbar when back online
        Get.rawSnackbar(
          title: "Internet connection restored",
          message: "You are now online",
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
        );

      }
    }
  }

  void _showNoInternetDialog() {
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
                // Manually re-check if needed
                List<ConnectivityResult> results = await _connectivity.checkConnectivity();
                if (!results.contains(ConnectivityResult.none)) {
                  _isDialogOpen = false;
                  Get.back();
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