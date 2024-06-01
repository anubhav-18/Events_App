import 'package:cu_events/admin_login_screen.dart';
import 'package:cu_events/admin_panel.dart';
import 'package:cu_events/checkConnectivity.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/events_details.dart';
import 'package:cu_events/events_page.dart';
import 'package:cu_events/firebase_options.dart';
import 'package:cu_events/homepage.dart';
import 'package:cu_events/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'JockeyOne',
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: primaryBckgnd,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'JockeyOne',
            color: headingColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'JockeyOne',
            color: headingColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 20,
            fontFamily: 'JockeyOne',
            color: textColor,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: barBckgnd,
          titleTextStyle: TextStyle(
            fontSize: 34,
            color: headingColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'JockeyOne',
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBckgnd),
      ),
      initialRoute: '/',
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Homepage(),
        '/engineering/academic': (context) =>
            const EventsPage(category: 'engineering', subcategory: 'academic'),
        '/engineering/cultural': (context) =>
            const EventsPage(category: 'engineering', subcategory: 'cultural'),
        '/engineering/nss_ncc': (context) =>
            const EventsPage(category: 'engineering', subcategory: 'nss_ncc'),
        '/engineering/others': (context) =>
            const EventsPage(category: 'engineering', subcategory: 'others'),
        '/medical/academic': (context) =>
            const EventsPage(category: 'medical', subcategory: 'academic'),
        '/medical/cultural': (context) =>
            const EventsPage(category: 'medical', subcategory: 'cultural'),
        '/medical/nss_ncc': (context) =>
            const EventsPage(category: 'medical', subcategory: 'nss_ncc'),
        '/medical/others': (context) =>
            const EventsPage(category: 'medical', subcategory: 'others'),
        '/business/academic': (context) =>
            const EventsPage(category: 'business', subcategory: 'academic'),
        '/business/cultural': (context) =>
            const EventsPage(category: 'business', subcategory: 'cultural'),
        '/business/nss_ncc': (context) =>
            const EventsPage(category: 'business', subcategory: 'nss_ncc'),
        '/business/others': (context) =>
            const EventsPage(category: 'business', subcategory: 'others'),
        '/law/academic': (context) =>
            const EventsPage(category: 'law', subcategory: 'academic'),
        '/law/cultural': (context) =>
            const EventsPage(category: 'law', subcategory: 'cultural'),
        '/law/nss_ncc': (context) =>
            const EventsPage(category: 'law', subcategory: 'nss_ncc'),
        '/law/others': (context) =>
            const EventsPage(category: 'law', subcategory: 'others'),
        '/other/academic': (context) =>
            const EventsPage(category: 'other', subcategory: 'academic'),
        '/other/cultural': (context) =>
            const EventsPage(category: 'other', subcategory: 'cultural'),
        '/other/nss_ncc': (context) =>
            const EventsPage(category: 'other', subcategory: 'nss_ncc'),
        '/other/others': (context) =>
            const EventsPage(category: 'other', subcategory: 'others'),
        '/admin': (context) => const AdminPanel(),
        '/event_details': (context) => const EventDetailsPage(),
        '/secret-admin-login': (context) => AdminLoginScreen(),
      },
    );
  }
}
