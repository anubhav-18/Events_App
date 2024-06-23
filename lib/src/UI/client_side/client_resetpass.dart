import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientResetpass extends StatefulWidget {
  const ClientResetpass({Key? key}) : super(key: key);

  @override
  State<ClientResetpass> createState() => _ClientResetpassState();
}

class _ClientResetpassState extends State<ClientResetpass> {
  final _passwordController = TextEditingController();
  final _repasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _repasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String newPassword = _passwordController.text.trim();
        String reEnteredPassword = _repasswordController.text.trim();

        if (newPassword != reEnteredPassword) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Passwords do not match.';
          });
          return;
        }

        await user.updatePassword(newPassword);
        setState(() {
          _isLoading = false;
          _errorMessage = null;
        });

        // Navigate to appropriate screen after password change
        Navigator.pushNamedAndRemoveUntil(
            context, '/clientInfo', (route) => false);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not authenticated.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              labelText: 'New Password',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              labelText: 'Re-Enter New Password',
              controller: _repasswordController,
              obscureText: true,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            CustomElevatedButton(
              onPressed: _isLoading ? null : changePassword,
              title: 'Change Password',
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
