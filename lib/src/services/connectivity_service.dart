// import 'dart:async';
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

// class ConnectivityService {
//   final InternetConnection _internetConnection = InternetConnection();
//   StreamSubscription<InternetStatus>? _internetConnectionStream;
//   final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

//   ConnectivityService() {
//     _internetConnectionStream = _internetConnection.onStatusChange.listen((event) {
//       _updateConnectionStatus(event);
//     });
//     _checkInitialConnection();
//   }

//   Stream<bool> get connectionStatus => _connectionStatusController.stream;

//   void _updateConnectionStatus(InternetStatus status) {
//     print('Update Connection: $status');
//     _connectionStatusController.add(status == InternetStatus.connected);
//   }

//   Future<void> _checkInitialConnection() async {
//     bool isConnected = await _internetConnection.hasInternetAccess;
//     print('Inital Connection: $isConnected');
//     _updateConnectionStatus(isConnected ? InternetStatus.connected : InternetStatus.disconnected);
//   }

//   Future<void> checkConnectivityAndNotify() async {
//     bool isConnected = await _internetConnection.hasInternetAccess;
//     print('Check Connection: $isConnected');
//     _updateConnectionStatus(isConnected ? InternetStatus.connected : InternetStatus.disconnected);
//   }

//   void dispose() {
//     _internetConnectionStream?.cancel();
//     _connectionStatusController.close();
//   }
// }
