import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResultList) {
      // Assuming you want to handle the first result in the list
      _updateConnectionStatus(connectivityResultList.isNotEmpty
          ? connectivityResultList[0]
          : ConnectivityResult.none);
    });
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      // Delay showing the Snackbar to ensure Get.overlayContext is properly set
      Future.delayed(Duration.zero, () {
        Get.rawSnackbar(
          messageText: const Text(
            'Please connect to the internet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(days: 1),
          isDismissible: false,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.red,
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        );
      });
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
