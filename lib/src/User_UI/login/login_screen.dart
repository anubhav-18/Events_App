import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/controller/auth_gate.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/reusable_widget/google_sign.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? error;

  void _stopLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarIconBrightness: Brightness.dark, // Dark icons for status bar
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 20, right: 20, left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              // Skip Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/home',
                                      (Route<dynamic> route) => false,
                                    ),
                                    child: Text(
                                      'Skip',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: primaryBckgnd,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Logo or App Name
                              Image.asset(
                                'assets/icons/logo/cuevents.png', // Your logo path
                                height: 170, // Adjust logo size as needed
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Login',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .copyWith(
                                      color: textColor,
                                    ),
                              ),
                              const SizedBox(height: 20), // Add spacing
                              // Email Input Field
                              CustomTextField(
                                labelText: 'Email',
                                controller: _emailController,
                                obscureText: false,
                              ),
                              const SizedBox(height: 10),
                              // Password Input Field
                              CustomTextField(
                                labelText: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                              ),
                              const SizedBox(height: 10),
                              // "Forgot Password?" Link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/forgetpassword',
                                        arguments: _emailController.text);
                                  },
                                  child: Text(
                                    'Forgot Password ?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              // Google Sign-In Button
                              GoogleSignInButton(
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    await _auth.signInWithGoogle(context);
                                  } catch (e) {
                                    showCustomSnackBar(context, e.toString());
                                  } finally {
                                    _stopLoading();
                                  }
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/create');
                              },
                              child: Text(
                                "Don't have an account?",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: primaryBckgnd,
                                    ),
                              ),
                            ),
                            // Login Button
                            CustomElevatedButton(
                              widget: true,
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  try {
                                    UserCredential? result =
                                        await _auth.loginWithEmailAndPassword(
                                            _emailController.text,
                                            _passwordController.text,
                                            context);
                                    if (result == null) {
                                      // showCustomSnackBar(
                                      //   context,
                                      //   'Could not sign in. Please check your credentials.',
                                      // );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AuthGate(),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (e is FirebaseAuthException) {
                                      String errorMessage = _auth
                                          .handleFirebaseAuthException(e)
                                          .toString();
                                      showCustomSnackBar(context, errorMessage);
                                    } else {
                                      // showCustomSnackBar(context,
                                      //     'An unexpected error occurred. Please try again.');
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(
                                        () => _isLoading = false,
                                      ); // Always stop loading
                                    }
                                  }
                                }
                              },
                              title: '',
                              width: double.infinity,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      'Login',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(color: whiteColor),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
