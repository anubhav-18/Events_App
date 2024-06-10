import 'package:cu_events/controller/firestore_service.dart';
import 'package:cu_events/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

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
      return _userFromFirebaseUser(result.user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Register with email & password
  Future<User?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await result.user?.updateDisplayName(name);

      User? user = result.user;
      if (user != null) {
        // Extract first and last name from full name
        List<String> names = name.split(" ");
        String firstName = names.first;
        String lastName = names.length > 1 ? names.sublist(1).join(" ") : '';

        // Create UserModel object and add to Firestore
        final userModel = UserModel(
          id: user.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );
        await FirestoreService().createUserDocument(userModel);
        return _userFromFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw handleFirebaseAuthException(e);
    } catch (error) {
      print(error.toString());
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
      print(error.toString());
      rethrow;
    }
  }  

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
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
        return _userFromFirebaseUser(result.user);
      }
      return null;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      print(error.toString());
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
