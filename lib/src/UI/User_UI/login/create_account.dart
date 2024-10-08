import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/reusable_widget/google_sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? error;

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
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed('/home'),
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
                              // Logo or App Name (Optional)
                              Image.asset(
                                'assets/icons/logo/cuevents.png',
                                height: 170,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Sign IN',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(color: textColor),
                              ),
                              const SizedBox(height: 30),
                              // Name Input Field
                              Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      labelText: 'First Name',
                                      controller: _firstnameController,
                                      obscureText: false,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: CustomTextField(
                                      labelText: 'Last Name',
                                      controller: _lastnameController,
                                      obscureText: false,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Email Input Field
                              CustomTextField(
                                labelText: 'Email',
                                controller: _emailController,
                                obscureText: false,
                                boolValidator: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Password Input Field
                              CustomTextField(
                                labelText: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                                boolValidator: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 35),
                              GoogleSignInButton(
                                onPressed: () async {
                                  setState(
                                    () => _isLoading = true,
                                  );
                                  try {
                                    await _auth.signInWithGoogle(context);
                                  } catch (e) {
                                    showCustomSnackBar(context, e.toString());
                                  } finally {
                                    _isLoading = false;
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
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                'Already have an account?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 14,
                                      color: primaryBckgnd,
                                    ),
                              ),
                            ),
                            // Create Account Button
                            CustomElevatedButton(
                              onPressed: () => _createAccount(),
                              title: '',
                              widget: true,
                              width: double.infinity,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Text(
                                      'Create Account',
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

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.registerWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _firstnameController.text,
          _lastnameController.text,
        );
        showCustomSnackBar(
            context, 'Account created successfully. Please log in.');

        // Clear the form fields
        _formKey.currentState!.reset();
        _firstnameController.clear();
        _emailController.clear();
        _passwordController.clear();

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        showCustomSnackBar(context, e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
