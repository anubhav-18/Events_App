import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cu_events/view/admin/admin_Panel/add_events.dart';
import 'package:cu_events/view/admin/admin_login_screen.dart';
import 'package:cu_events/view/admin/admin_panel.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/view/categories/category_view.dart';
import 'package:cu_events/view/drawer/about_us.dart';
import 'package:cu_events/view/drawer/feedback.dart';
import 'package:cu_events/view/events/all_events.dart';
import 'package:cu_events/view/events/events_details.dart';
import 'package:cu_events/firebase_options.dart';
import 'package:cu_events/view/home/homepage.dart';
import 'package:cu_events/controller/notification.dart';
import 'package:cu_events/view/splashscreen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();

  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) async {
      if (receivedAction.buttonKeyPressed == 'OPEN_IMAGE') {
        String? imagePath = receivedAction.payload?['imagePath'];
        if (imagePath != null) {
          await _openImage(imagePath);
        }
      }
    },
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

Future<void> _openImage(String imagePath) async {
  final Uri url = Uri.parse(imagePath);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Acme',
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: backgndColor,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            fontFamily: 'Acme',
            color: whiteColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Acme',
            color: textColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Acme',
            color: textColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            fontFamily: 'Acme',
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          bodySmall: TextStyle(
            fontSize: 18,
            fontFamily: 'Acme',
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBckgnd,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle:  TextStyle(
              fontSize: 34,
              color: whiteColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Acme',
            ),
          // GoogleFonts.montserrat(
          //   textStyle: TextStyle(
          //     fontSize: 34,
          //     color: whiteColor,
          //     fontWeight: FontWeight.bold,
          //     fontFamily: 'Acme',
          //   ),
          // ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBckgnd),
      ),
      initialRoute: '/',
      home: SplashScreen(),
      routes: {
        '/home': (context) => const Homepage(),
        '/admin': (context) => const AdminPanel(),
        '/event_details': (context) => const EventDetailsPage(),
        '/secret-admin-login': (context) => const AdminLoginScreen(),
        '/addEvents': (context) => const AddEventsPanel(),
        '/allevents': (context) => const AllEventsPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/aboutus': (context) => const AboutUsPage(),
        '/category': (context) => const CategoriesPage(),
      },
    );
  }
}
