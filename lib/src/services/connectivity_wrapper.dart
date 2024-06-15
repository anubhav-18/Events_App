// import 'package:cu_events/src/UI/no_internet/error_page.dart';
// import 'package:flutter/material.dart';
// import 'connectivity_service.dart';

// class ConnectivityWrapper extends StatelessWidget {
//   final Widget child;
//   final ConnectivityService connectivityService;

//   const ConnectivityWrapper({
//     super.key,
//     required this.child,
//     required this.connectivityService,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<bool>(
//       stream: connectivityService.connectionStatus,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox();
//         }
//         if (snapshot.hasData && snapshot.data == true) {
//           return child;
//         } else {
//           return const ErrorPage();
//         }
//       },
//     );
//   }
// }
