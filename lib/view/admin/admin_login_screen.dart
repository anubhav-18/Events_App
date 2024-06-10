import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:cu_events/reusable_widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  void _login() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to admin panel on successful login
      Navigator.pushReplacementNamed(context, '/admin');
    } catch (e) {
      String errorMessage = "An error occurred";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Invalid password.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Too many unsuccessful login attempts. Please try again later.';
            break;
          default:
            errorMessage = 'Authentication failed. Please try again later.';
        }
      }
      print(errorMessage);
      showCustomSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomElevatedButton(
                  onPressed: _login,
                  title: 'Login',
                  width: double.infinity,
                  height: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
