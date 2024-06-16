// import 'package:flutter/material.dart';
// import 'package:cu_events/src/constants.dart'; 

// class AppThemes {
//   static final lightTheme = ThemeData(
//     fontFamily: 'Montserrat',
//     pageTransitionsTheme: const PageTransitionsTheme(
//       builders: {
//         TargetPlatform.android: CupertinoPageTransitionsBuilder(),
//       },
//     ),
//     brightness: Brightness.light,
//     useMaterial3: true,
//     scaffoldBackgroundColor: backgndColor,
//     textTheme: const TextTheme(
//       headlineLarge: TextStyle(
//         fontSize: 34,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Montserrat',
//         color: whiteColor,
//       ),
//       headlineMedium: TextStyle(
//         fontSize: 26,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Montserrat',
//         color: textColor,
//       ),
//       bodyLarge: TextStyle(
//         fontSize: 22,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Montserrat',
//         color: textColor,
//       ),
//       bodyMedium: TextStyle(
//         fontSize: 18,
//         fontFamily: 'Montserrat',
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),
//       bodySmall: TextStyle(
//         fontSize: 16,
//         fontFamily: 'Montserrat',
//         fontWeight: FontWeight.bold,
//         color: textColor,
//       ),
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryBckgnd,
//       iconTheme: IconThemeData(color: Colors.white, size: 30),
//       titleTextStyle: TextStyle(
//         fontSize: 34,
//         color: whiteColor,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Montserrat',
//       ),
//     ),
//     colorScheme: ColorScheme.fromSeed(seedColor: primaryBckgnd),
//   );

//   static final darkTheme = ThemeData(
//     fontFamily: 'Montserrat', // Inherit font family from lightTheme
//     pageTransitionsTheme: lightTheme.pageTransitionsTheme,
//     brightness: Brightness.dark,
//     useMaterial3: true,
//     scaffoldBackgroundColor: darkBckgndColor,
//     textTheme: lightTheme.textTheme.copyWith(
//       headlineLarge: lightTheme.textTheme.headlineLarge!.copyWith(
//         color: whiteColor,
//       ),
//       headlineMedium: lightTheme.textTheme.headlineMedium!.copyWith(
//         color: whiteColor,
//       ),
//       bodyLarge: lightTheme.textTheme.bodyLarge!.copyWith(
//         color: whiteColor,
//       ),
//       bodyMedium: lightTheme.textTheme.bodyMedium!.copyWith(
//         color: whiteColor,
//       ),
//       bodySmall: lightTheme.textTheme.bodySmall!.copyWith(
//         color: whiteColor,
//       ),
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: primaryBckgnd,
//       iconTheme: IconThemeData(color: Colors.white, size: 30),
//       titleTextStyle: TextStyle(
//         fontSize: 34,
//         color: whiteColor,
//         fontWeight: FontWeight.bold,
//         fontFamily: 'Montserrat',
//       ),
//     ),
//     colorScheme: ColorScheme.fromSeed(
//       seedColor: primaryBckgnd,
//       brightness: Brightness.dark,
//     ),
//   );
// }
