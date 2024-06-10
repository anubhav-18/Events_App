// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';

// class ConnectivityCheck extends StatefulWidget {
//   final Widget child;

//   const ConnectivityCheck({Key? key, required this.child}) : super(key: key);

//   @override
//   _ConnectivityCheckState createState() => _ConnectivityCheckState();
// }

// class _ConnectivityCheckState extends State<ConnectivityCheck> {
//   bool isConnected = true;

//   @override
//   void initState() {
//     super.initState();
//     // _checkConnectivity();
//   }

//   // Future<void> _checkConnectivity() async {
//   //   var connectivityResult = await (Connectivity().checkConnectivity());
//   //   setState(() {
//   //     isConnected = connectivityResult != ConnectivityResult.none;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     if (!isConnected) {//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color: Colors.red),
//             SizedBox(height: 16),
//             Text(
//               'Please connect to the internet',
//               style: TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       );
//     }

//     return widget.child;
//   }
// }
