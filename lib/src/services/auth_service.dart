// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
// // import 'package:cu_events/src/services/firestore_service.dart';
// // import 'package:cu_events/src/models/user_model.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_sign_in/google_sign_in.dart';

// // class AuthService {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   final FirestoreService _firestoreService = FirestoreService();
// //   bool loggedIn = false; // Track login status

// //   // Create user object based on FirebaseUser
// //   User? _userFromFirebaseUser(User? user) {
// //     return user;
// //   }

// //   // Auth change user stream
// //   Stream<User?> get user {
// //     return _auth.authStateChanges().map(_userFromFirebaseUser);
// //   }

// //   // User Current Status
// //   User? get currentUser {
// //     return _auth.currentUser;
// //   }

// //   // Sign in with email & password
// //   Future<User?> signInWithEmailAndPassword(
// //       String email, String password) async {
// //     try {
// //       UserCredential result = await _auth.signInWithEmailAndPassword(
// //           email: email, password: password);
// //       loggedIn = true; // Set loggedIn to true upon successful login
// //       return _userFromFirebaseUser(result.user);
// //     } catch (error) {
// //       print(error.toString());
// //       return null;
// //     }
// //   }

// //   // Register with email & password
// //   Future<User?> registerWithEmailAndPassword(
// //       String email, String password, String fname, String lname) async {
// //     try {
// //       UserCredential result = await _auth.createUserWithEmailAndPassword(
// //           email: email, password: password);
// //       await result.user?.updateDisplayName(fname);
// //       loggedIn = true; // Set loggedIn to true upon successful registration

// //       User? user = result.user;
// //       if (user != null) {
// //         String firstName = fname;
// //         String lastName = lname;

// //         // Create UserModel object and add to Firestore
// //         final userModel = UserModel(
// //           id: user.uid,
// //           firstName: firstName,
// //           lastName: lastName,
// //           email: email,
// //         );
// //         await FirestoreService().createUserDocument(userModel);
// //         return _userFromFirebaseUser(user);
// //       }
// //       return null;
// //     } on FirebaseAuthException catch (e) {
// //       throw handleFirebaseAuthException(e);
// //     } catch (error) {
// //       print(error.toString());
// //       return null;
// //     }
// //   }

// //   // Reset Password
// //   Future<void> sendPasswordResetEmail(String email) async {
// //     try {
// //       await _auth.sendPasswordResetEmail(email: email);
// //     } on FirebaseAuthException catch (e) {
// //       throw handleFirebaseAuthException(e);
// //     } catch (error) {
// //       print(error.toString());
// //       rethrow;
// //     }
// //   }

// //   // Sign in with Google
// //   Future<User?> signInWithGoogle(BuildContext context) async {
// //     try {
// //       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
// //       if (googleUser != null) {
// //         final GoogleSignInAuthentication googleAuth =
// //             await googleUser.authentication;
// //         final AuthCredential credential = GoogleAuthProvider.credential(
// //           accessToken: googleAuth.accessToken,
// //           idToken: googleAuth.idToken,
// //         );
// //         final UserCredential result =
// //             await _auth.signInWithCredential(credential);

// //         User? user = result.user;

// //         if (user != null) {
// //           DocumentSnapshot userDoc = await FirebaseFirestore.instance
// //               .collection('users')
// //               .doc(user.uid)
// //               .get();

// //           if (!userDoc.exists) {
// //             // Create UserModel object and add to Firestore

// //             String? name = user.displayName;
// //             List<String>? nameParts = name?.split(" ");
// //             String firstName = (nameParts != null && nameParts.isNotEmpty)
// //                 ? nameParts.first
// //                 : 'User';
// //             String lastName = (nameParts != null && nameParts.isNotEmpty)
// //                 ? nameParts.last
// //                 : '';

// //             final userModel = UserModel(
// //               id: user.uid,
// //               firstName: firstName,
// //               lastName: lastName,
// //               email: user.email ?? '',
// //             );
// //             await FirestoreService().createUserDocument(userModel);
// //           }

// //           loggedIn = true; // Set loggedIn to true upon successful Google sign-in

// //           showCustomSnackBar(context, 'Welcome to CU Events');
// //           Navigator.pushNamedAndRemoveUntil(
// //             context,
// //             '/home',
// //             (Route<dynamic> route) => false,
// //           );
// //         }
// //         return _userFromFirebaseUser(result.user);
// //       }
// //       return null;
// //     } catch (error) {
// //       print(error.toString());
// //       return null;
// //     }
// //   }

// //   // Sign out
// //   Future<void> signOut() async {
// //     try {
// //       await _auth.signOut();
// //       loggedIn = false; // Set loggedIn to false upon sign out
// //     } catch (error) {
// //       print(error.toString());
// //     }
// //   }

// //   Exception handleFirebaseAuthException(FirebaseAuthException e) {
// //     switch (e.code) {
// //       case 'email-already-in-use':
// //         return Exception("This email address is already in use.");
// //       case 'invalid-email':
// //         return Exception("This email address is invalid.");
// //       case 'user-not-found':
// //         return Exception("No user found with this email address.");
// //       case 'wrong-password':
// //         return Exception("Incorrect password. Please try again.");
// //       case 'weak-password':
// //         return Exception("The password is too weak.");
// //       default:
// //         return Exception("An unexpected error occurred. Please try again.");
// //     }
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
// import 'package:cu_events/src/services/firestore_service.dart';
// import 'package:cu_events/src/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirestoreService _firestoreService = FirestoreService();
//   bool loggedIn = false; // Track login status

//   // Create user object based on FirebaseUser
//   User? _userFromFirebaseUser(User? user) {
//     return user;
//   }

//   // Auth change user stream
//   Stream<User?> get user {
//     return _auth.authStateChanges().map(_userFromFirebaseUser);
//   }

//   // User Current Status
//   User? get currentUser {
//     return _auth.currentUser;
//   }

//   // Sign in with email & password
//   Future<User?> signInWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       loggedIn = true; // Set loggedIn to true upon successful login
//       notifyListeners(); // Notify listeners about the change
//       return _userFromFirebaseUser(result.user);
//     } catch (error) {
//       print(error.toString());
//       return null;
//     }
//   }

//   // Register with email & password
//   Future<User?> registerWithEmailAndPassword(
//       String email, String password, String fname, String lname) async {
//     try {
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       await result.user?.updateDisplayName(fname);
//       loggedIn = true; // Set loggedIn to true upon successful registration
//       notifyListeners(); // Notify listeners about the change

//       User? user = result.user;
//       if (user != null) {
//         String firstName = fname;
//         String lastName = lname;

//         // Create UserModel object and add to Firestore
//         final userModel = UserModel(
//           id: user.uid,
//           firstName: firstName,
//           lastName: lastName,
//           email: email,
//         );
//         await FirestoreService().createUserDocument(userModel);
//         return _userFromFirebaseUser(user);
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       throw handleFirebaseAuthException(e);
//     } catch (error) {
//       print(error.toString());
//       return null;
//     }
//   }

//   // Reset Password
//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       throw handleFirebaseAuthException(e);
//     } catch (error) {
//       print(error.toString());
//       rethrow;
//     }
//   }

//   // Sign in with Google
//   Future<User?> signInWithGoogle(BuildContext context) async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser != null) {
//         final GoogleSignInAuthentication googleAuth =
//             await googleUser.authentication;
//         final AuthCredential credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth.accessToken,
//           idToken: googleAuth.idToken,
//         );
//         final UserCredential result =
//             await _auth.signInWithCredential(credential);

//         User? user = result.user;

//         if (user != null) {
//           DocumentSnapshot userDoc = await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .get();

//           if (!userDoc.exists) {
//             // Create UserModel object and add to Firestore

//             String? name = user.displayName;
//             List<String>? nameParts = name?.split(" ");
//             String firstName = (nameParts != null && nameParts.isNotEmpty)
//                 ? nameParts.first
//                 : 'User';
//             String lastName = (nameParts != null && nameParts.isNotEmpty)
//                 ? nameParts.last
//                 : '';

//             final userModel = UserModel(
//               id: user.uid,
//               firstName: firstName,
//               lastName: lastName,
//               email: user.email ?? '',
//             );
//             await FirestoreService().createUserDocument(userModel);
//           }

//           loggedIn = true; // Set loggedIn to true upon successful Google sign-in
//           notifyListeners(); // Notify listeners about the change

//           showCustomSnackBar(context, 'Welcome to CU Events');
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/home',
//             (Route<dynamic> route) => false,
//           );
//         }
//         return _userFromFirebaseUser(result.user);
//       }
//       return null;
//     } catch (error) {
//       print(error.toString());
//       return null;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       loggedIn = false; // Set loggedIn to false upon sign out
//       notifyListeners(); // Notify listeners about the change
//     } catch (error) {
//       print(error.toString());
//     }
//   }

//   Exception handleFirebaseAuthException(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'email-already-in-use':
//         return Exception("This email address is already in use.");
//       case 'invalid-email':
//         return Exception("This email address is invalid.");
//       case 'user-not-found':
//         return Exception("No user found with this email address.");
//       case 'wrong-password':
//         return Exception("Incorrect password. Please try again.");
//       case 'weak-password':
//         return Exception("The password is too weak.");
//       default:
//         return Exception("An unexpected error occurred. Please try again.");
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  bool loggedIn = false; // Track login status

  AuthService() {
    // Check the initial authentication state and set loggedIn accordingly
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        loggedIn = true;
      } else {
        loggedIn = false;
      }
      notifyListeners(); // Notify listeners whenever the auth state changes
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

  // Sign in with email & password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      loggedIn = true; // Set loggedIn to true upon successful login
      notifyListeners(); // Notify listeners about the change
      print('User signed in: $loggedIn'); // Debug statement
      return _userFromFirebaseUser(result.user);
    } catch (error) {
      print('Error signing in: $error'); // Debug statement
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
          profilePicture: null,
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
            // Create UserModel object and add to Firestore
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
              profilePicture: null,
            );
            await FirestoreService().createUserDocument(userModel);
          }

          loggedIn =
              true; // Set loggedIn to true upon successful Google sign-in
          notifyListeners(); // Notify listeners about the change
          print('User signed in with Google: $loggedIn'); // Debug statement

          showCustomSnackBar(context, 'Welcome to CU Events');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (Route<dynamic> route) => false,
          );
        }
        return _userFromFirebaseUser(result.user);
      }
      return null;
    } catch (error) {
      print('Error signing in with Google: $error'); // Debug statement
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
}
