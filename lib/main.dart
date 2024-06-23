import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cu_events/src/Client_UI/client_menu_page/client_profile_edit.dart';
import 'package:cu_events/src/User_UI/Menu_Items/about_us.dart';
import 'package:cu_events/src/User_UI/Menu_Items/faq.dart';
import 'package:cu_events/src/User_UI/btm_nav_section/favourite.dart';
import 'package:cu_events/src/User_UI/Menu_Items/feedback.dart';
import 'package:cu_events/src/User_UI/Menu_Items/invite_friends.dart';
import 'package:cu_events/src/User_UI/Menu_Items/privacy_policy.dart';
import 'package:cu_events/src/User_UI/Menu_Items/settings/reset_password.dart';
import 'package:cu_events/src/User_UI/Menu_Items/settings/settings.dart';
import 'package:cu_events/src/User_UI/Menu_Items/terms_of_service.dart';
import 'package:cu_events/src/User_UI/Menu_Items/your_profile.dart';
import 'package:cu_events/src/Client_UI/client_dashboard.dart';
import 'package:cu_events/src/Client_UI/client_login/client_info.dart';
import 'package:cu_events/src/Client_UI/client_login/client_resetpass.dart';
import 'package:cu_events/src/User_UI/home/home_sections/btm_nav_bar.dart';
import 'package:cu_events/src/User_UI/home/home_sections/search_view.dart';
import 'package:cu_events/src/User_UI/splashscreen/splashscreen.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/controller/network_contoller.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/provider/search_provider.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/User_UI/events/all_events.dart';
import 'package:cu_events/src/User_UI/events/events_details.dart';
import 'package:cu_events/firebase_options.dart';
import 'package:cu_events/src/User_UI/home/homepage.dart';
import 'package:cu_events/src/controller/notification.dart';
import 'package:cu_events/src/User_UI/login/create_account.dart';
import 'package:cu_events/src/User_UI/login/forget_password.dart';
import 'package:cu_events/src/User_UI/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
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
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => FavoriteProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MyApp(),
      ),
    );
  });
  DependencyInjection.init();
}

Future<void> _openImage(String imagePath) async {
  final Uri url = Uri.parse(imagePath);
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
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
            fontFamily: 'Roboto',
            color: whiteColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
            color: textColor,
          ),
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
            color: textColor,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
            color: textColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          bodySmall: TextStyle(
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w300,
            color: textColor,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBckgnd,
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          titleTextStyle: TextStyle(
            fontSize: 34,
            color: whiteColor,
            fontWeight: FontWeight.w500,
            fontFamily: 'Roboto',
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryBckgnd),
      ),
      initialRoute: '/',
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const Homepage(),
        '/event_details': (context) => const EventDetailsPage(),
        '/allevents': (context) => const AllEventsPage(),
        '/feedback': (context) => const FeedbackPage(),
        '/aboutus': (context) => const AboutUsPage(),
        '/search': (context) => const SearchPage(),
        '/login': (context) => const LoginScreen(),
        '/create': (context) => const CreateAccountPage(),
        '/forgetpassword': (context) => const ForgotPasswordPage(),
        '/yourprofile': (context) => const EditProfilePage(),
        '/favourite': (context) => const FavoritePage(),
        '/tos': (context) => const TermsOfServicePage(),
        '/faq': (context) => const FAQPage(),
        '/privacy': (context) => const PrivacyPolicyPage(),
        '/invite': (context) => const InviteFriendsPage(),
        '/settings': (context) => const SettingsPage(),
        '/resetpassword': (context) => const ResetPasswordPage(),
        '/btmnav': (context) => const BtmNavBar(),
        '/clientInfo': (context) => const ClientInfo(),
        '/clientDashboard': (context) => const ClientDashboard(),
        '/clientresetpass': (context) => const ClientResetpass(),
        '/clientProfile': (context) => const EditClientProfilePage(),
      },
    );
  }
}
