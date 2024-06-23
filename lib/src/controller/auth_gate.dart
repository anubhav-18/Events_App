import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/UI/login/login_screen.dart';
import 'package:cu_events/src/UI/onboarding_screen.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _auth = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserDocument();
  }

  Future<void> _checkUserDocument() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if user document exists in 'users' collection
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Map<String, dynamic>? data = userDoc.data();
          List<String>? userInterests =
              await _firestoreService.getUserInterests(user.uid);

          if (userInterests.isNotEmpty) {
            Navigator.pushReplacementNamed(context, '/btmnav');
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => OnboardingScreen(
                  userId: _auth.currentUser!.uid,
                ),
              ),
              (route) => false,
            );
          }
        } else {
          // If no document in 'users', check 'clients' collection
          DocumentSnapshot<Map<String, dynamic>> clientDoc =
              await FirebaseFirestore.instance
                  .collection('clients')
                  .doc(user.uid)
                  .get();

          if (clientDoc.exists) {
            Map<String, dynamic>? clientData = clientDoc.data();

            if (clientData != null &&
                clientData['name'] != null &&
                clientData['name'].toString().isNotEmpty &&
                clientData['phoneNo'] != null &&
                clientData['phoneNo'].toString().isNotEmpty &&
                clientData['designation'] != null &&
                clientData['designation'].toString().isNotEmpty) {
              Navigator.pushReplacementNamed(context, '/clientDashboard');
            } else {
              Navigator.pushReplacementNamed(context, '/clientresetpass');
            }
          } else {
            setState(() => _isLoading = false); // No document found, show login
          }
        }
      } else {
        setState(() => _isLoading = false); 
      }
    } catch (e) {
      print("Error checking user data: $e");
      showCustomSnackBar(
          context, "Error checking user data. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: whiteColor,
        child: const Center(
          child: CircularProgressIndicator(
            color: primaryBckgnd,
          ),
        ),
      );
    }
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Or a loading widget if you prefer
        }

        if (snapshot.hasData) {
          return Container();
          // User is logged in
        } else {
          return const LoginScreen();
          // User is not logged in
        }
      },
    );
  }
}
