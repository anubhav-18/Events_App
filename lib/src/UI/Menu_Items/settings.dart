// import 'package:cu_events/src/provider/theme_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         children: [
//           ListTile(
//             title: const Text('Theme'),
//             trailing: DropdownButton<ThemeMode>(
//               value: themeProvider.themeMode,
//               onChanged: (value) {
//                 themeProvider.setThemeMode(value!);
//               },
//               items: ThemeMode.values
//                   .map(
//                     (mode) => DropdownMenuItem(
//                       value: mode,
//                       child: Text(mode.toString().split('.').last),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//           // ... other settings
//         ],
//       ),
//     );
//   }
// }
