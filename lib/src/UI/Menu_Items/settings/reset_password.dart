import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart'; // Import your custom button
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart'; // Import your custom text field
import 'package:cu_events/src/services/auth_service.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Check if the entered current password is correct
        if (await _authService
            .isCurrentPasswordValid(_currentPasswordController.text)) {
          // Update the password
          await _authService.updatePassword(_newPasswordController.text);

          // Show success message and navigate back
          showCustomSnackBar(context, 'Password updated successfully');
          Navigator.pop(context);
        } else {
          showCustomSnackBar(
              context, 'Incorrect current password. Please try again.');
        }
      } catch (e) {
        // Handle password update errors (e.g., weak password, network issues)
        showCustomSnackBar(context, 'Error updating password');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CustomTextField(
                controller: _currentPasswordController,
                labelText: 'Current Password',
                obscureText: true,
                validator: (value) => value!.isEmpty
                    ? 'Please enter your current password'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                labelText: 'New Password',
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a new password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  } // Add more specific password validation rules as needed
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm New Password',
                obscureText: true,
                validator: (value) => value != _newPasswordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 32), // Space for the button
              const Spacer(),
              CustomElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                title: _isLoading ? 'Updating...' : 'Update Password',
                width: double.infinity, // Full width button
                isColor: true,
                backgroundColor: _isLoading ? Colors.grey : primaryBckgnd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
