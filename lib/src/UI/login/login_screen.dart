import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/reusable_widget/google_sign.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                                    Navigator.of(context).pushNamed('/home'),
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
                          // Logo or App Name
                          Image.asset(
                            'assets/icons/logo/cuevents.png', // Your logo path
                            height: 150, // Adjust logo size as needed
                          ),
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
                            hintText: 'Enter an Email',
                            obscureText: false,
                          ),
                          const SizedBox(height: 10),
                          // Password Input Field
                          CustomTextField(
                            labelText: 'Password',
                            controller: _passwordController,
                            hintText: 'Enter an Password',
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          // "Forgot Password?" Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/forgetpassword',
                                    arguments: _emailController.text);
                              },
                              child: Text(
                                'Forgot Password ?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Google Sign-In Button
                          GoogleSignInButton(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              try {
                                await _auth.signInWithGoogle();
                                showCustomSnackBar(
                                    context, 'Welcome to CU Events');
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              } catch (e) {
                                showCustomSnackBar(context, e.toString());
                              } finally {
                                setState(() => _isLoading = false);
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
                            Navigator.pushReplacementNamed(context, '/create');
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
                                dynamic result =
                                    await _auth.signInWithEmailAndPassword(
                                        _emailController.text,
                                        _passwordController.text);
                                if (result == null) {
                                  showCustomSnackBar(
                                    context,
                                    'Could not sign in. Please check your credentials.',
                                  );
                                } else {
                                  showCustomSnackBar(
                                      context, 'Welcome to CU Events');
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              } catch (e) {
                                if (e is FirebaseAuthException) {
                                  String errorMessage = _auth
                                      .handleFirebaseAuthException(e)
                                      .toString();
                                  showCustomSnackBar(context, errorMessage);
                                } else {
                                  showCustomSnackBar(context,
                                      'An unexpected error occurred. Please try again.');
                                }
                              } finally {
                                setState(() => _isLoading = false);
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
    );
  }
}
