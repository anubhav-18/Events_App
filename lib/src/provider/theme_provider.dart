// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system; // Default to system
//   static const String _kThemePreferenceKey = 'theme_preference';
//   SharedPreferences? _prefs;

//   ThemeProvider() {
//     _loadThemeFromPrefs();
//   }

//   ThemeMode get themeMode => _themeMode;

//   Future<void> _loadThemeFromPrefs() async {
//     try {
//       _prefs = await SharedPreferences.getInstance();
//       String? themeString = _prefs?.getString(_kThemePreferenceKey);
//       _themeMode = themeString != null
//           ? ThemeMode.values.byName(themeString)
//           : ThemeMode.system;
//       notifyListeners();
//     } catch (e) {
//       // Handle errors during reading from SharedPreferences
//       print("Error loading theme from preferences: $e");
//       // You can set a default theme here if loading fails
//       _themeMode = ThemeMode.system; // Or any other default
//     }
//   }

//   Future<void> setThemeMode(ThemeMode mode) async {
//     _themeMode = mode;
//     notifyListeners();
//     try {
//       _prefs ??= await SharedPreferences.getInstance();
//       await _prefs?.setString(_kThemePreferenceKey, mode.name);
//     } catch (e) {
//       // Handle errors during writing to SharedPreferences
//       print("Error saving theme to preferences: $e");
//       // You might want to show an error message to the user here
//     }
//   }
// }
