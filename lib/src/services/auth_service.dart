import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/User_UI/onboarding_screen.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  bool loggedIn = false;

  // Constructor 
  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedIn = true;
      } else {
        loggedIn = false;
      }
      notifyListeners();
    });
  }

  // Create user object based on FirebaseUser
  User? _userFromFirebaseUser(User? user) {
    return user;
  }

  // Auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // User Current Status
  User? get currentUser {
    return _auth.currentUser;
  }

  // Sign in with email and password
  Future<UserCredential?> loginWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check in 'users' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        List<String>? userInterests =
            await FirestoreService().getUserInterests(userCredential.user!.uid);

        if (userInterests.isNotEmpty) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/btmnav', (route) => false);
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
        // Check in 'clients' collection
        DocumentSnapshot clientDoc = await FirebaseFirestore.instance
            .collection('clients')
            .doc(userCredential.user!.uid)
            .get();

        if (clientDoc.exists) {
          Map<String, dynamic>? clientData =
              clientDoc.data() as Map<String, dynamic>?;

          if (clientData != null &&
              clientData['name'] != null &&
              clientData['name'].toString().isNotEmpty &&
              clientData['phoneNo'] != null &&
              clientData['phoneNo'].toString().isNotEmpty &&
              clientData['designation'] != null &&
              clientData['designation'].toString().isNotEmpty) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/clientDashboard', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, '/clientresetpass', (route) => false);
          }
        } else {
          showCustomSnackBar(context, 'User data not found.', isError: true);
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showCustomSnackBar(context, 'No user found for that email.',
            isError: true);
      } else if (e.code == 'wrong-password') {
        showCustomSnackBar(context, 'Wrong password provided for that user.',
            isError: true);
      } else {
        showCustomSnackBar(context, 'Error: ${e.message}', isError: true);
      }
      return null;
    } catch (e) {
      showCustomSnackBar(context, 'An error occurred during login.',
          isError: true);
      return null;
    }
  }

  // Register with email & password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String fname, String lname) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await result.user?.updateDisplayName(fname);
      loggedIn = true; // Set loggedIn to true upon successful registration
      notifyListeners(); // Notify listeners about the change
      print('User registered: $loggedIn'); // Debug statement

      User? user = result.user;
      if (user != null) {
        String firstName = fname;
        String lastName = lname;

        // Create UserModel object and add to Firestore
        final userModel = UserModel(
          id: user.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNo: null,
          gender: null,
          dateOfBirth: null,
          role: 'user',
          interests: [],
        );
        await FirestoreService().createUserDocument(userModel);
        return _userFromFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthException(e);
    } catch (error) {
      print('Error registering: $error'); // Debug statement
      return null;
    }
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthException(e);
    } catch (error) {
      print('Error sending password reset email: $error'); // Debug statement
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential result =
            await _auth.signInWithCredential(credential);

        User? user = result.user;

        if (user != null) {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // New user, create UserModel object and add to Firestore
            String? name = user.displayName;
            List<String>? nameParts = name?.split(" ");
            String firstName = (nameParts != null && nameParts.isNotEmpty)
                ? nameParts.first
                : 'User';
            String lastName = (nameParts != null && nameParts.isNotEmpty)
                ? nameParts.last
                : '';

            final userModel = UserModel(
              id: user.uid,
              firstName: firstName,
              lastName: lastName,
              email: user.email ?? '',
              phoneNo: null,
              gender: null,
              dateOfBirth: null,
              role: 'user',
              interests: [],
            );
            await FirestoreService().createUserDocument(userModel);
          } else {
            // Existing user
            String role = userDoc.get('role');
            if (role == 'client') {
              // Client logic
              DocumentSnapshot clientDoc = await FirebaseFirestore.instance
                  .collection('clients')
                  .doc(user.uid)
                  .get();

              if (!clientDoc.exists) {
                // New client, navigate to change password screen
                Navigator.pushNamed(context, '/clientresetpass');
              } else {
                // Existing client, check for interests
                List<String>? userInterests =
                    await FirestoreService().getUserInterests(user.uid);

                if (userInterests.isNotEmpty) {
                  // Client has interests, navigate to client dashboard
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/btmnav', (route) => false);
                } else {
                  // Client needs to complete onboarding
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingScreen(
                        userId: user.uid,
                      ),
                    ),
                    (route) => false,
                  );
                }
              }
            } else {
              // Regular user logic (role == 'user')
              List<String>? userInterests =
                  await FirestoreService().getUserInterests(user.uid);

              if (userInterests.isNotEmpty) {
                // User has interests, navigate to bottom navigation
                Navigator.pushNamedAndRemoveUntil(
                    context, '/btmnav', (route) => false);
              } else {
                // User needs to complete onboarding
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OnboardingScreen(
                      userId: user.uid,
                    ),
                  ),
                  (route) => false,
                );
              }
            }
          }

          loggedIn = true;
          notifyListeners(); // Notify listeners about the change
          print('User signed in with Google: $loggedIn');
        }

        return user;
      } else {
        showCustomSnackBar(context, 'Google sign-in canceled');
        return null;
      }
    } catch (error) {
      print('Error signing in with Google: $error'); // Debug statement
      showCustomSnackBar(
          context, 'Error signing in with Google. Please try again.');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      loggedIn = false; // Set loggedIn to false upon sign out
      notifyListeners(); // Notify listeners about the change

      print('User signed out: $loggedIn'); // Debug statement
    } catch (error) {
      print('Error signing out: $error'); // Debug statement
    }
  }

  // exceptions list 
  Exception handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception("This email address is already in use.");
      case 'invalid-email':
        return Exception("This email address is invalid.");
      case 'user-not-found':
        return Exception("No user found with this email address.");
      case 'wrong-password':
        return Exception("Incorrect password. Please try again.");
      case 'weak-password':
        return Exception("The password is too weak.");
      default:
        return Exception("An unexpected error occurred. Please try again.");
    }
  }

  // check which signined method
  String? getSignInMethod() {
    final user = _auth.currentUser;
    if (user != null) {
      final providerData = user.providerData;
      for (var info in providerData) {
        if (info.providerId == 'password') {
          return 'email'; // User signed in with email/password
        } else if (info.providerId == 'google.com') {
          return 'google'; // User signed in with Google
        }
      }
    }
    return null; // User is not signed in
  }

  // signed wit email & password ?
  bool isSignedInWithEmailAndPassword() {
    String? signInMethod = getSignInMethod();
    return signInMethod == 'email';
  }

  // signed with google ?
  bool isSignedInWithGoogle() {
    String? signInMethod = getSignInMethod();
    return signInMethod == 'google';
  }

  // Check for current password
  Future<bool> isCurrentPasswordValid(String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Re-authenticate with the current password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        return true; // Password is valid
      } else {
        // User not logged in or missing email
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return false; // Wrong password
      } else {
        print('Error during re-authentication: $e');
        // Handle other Firebase auth errors
        return false;
      }
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } on FirebaseAuthException catch (e) {
      // Handle password update errors (e.g., weak password, network issues)
      throw e; // Rethrow the exception to be handled in the UI
    }
  }
}
