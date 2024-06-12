import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Get the email from the arguments if it exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _emailController.text = args;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: primaryBckgnd),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Logo or App Name (Optional)
                            Center(
                              child: Image.asset(
                                'assets/icons/logo/cuevents.png', // Your logo path
                                height: 150,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Reset Password',
                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                      color: textColor,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Email Input Field
                            CustomTextField(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 20),
                            if (_error != null)
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 14.0),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Send Reset Email Button
                      CustomElevatedButton(
                        onPressed: _isLoading ? null : _sendResetPasswordEmail,
                        title: '',
                        widget: true,
                        width: double.infinity,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Send Reset Email',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: whiteColor),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendResetPasswordEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.sendPasswordResetEmail(_emailController.text);
        showCustomSnackBar(
            context, 'Password reset email sent. Please check your inbox.');
        Navigator.of(context).pop(); // Navigate back to the login page
      } catch (e) {
        showCustomSnackBar(context, e.toString());
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}

