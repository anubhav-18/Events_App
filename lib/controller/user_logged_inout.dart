import 'package:cu_events/view/home/homepage.dart';
import 'package:cu_events/view/login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Or a loading widget if you prefer
        }

        if (snapshot.hasData) {
          return const Homepage(); // User is logged in
        } else {
          return const LoginScreen(); // User is not logged in
        }
      },
    );
  }
}
