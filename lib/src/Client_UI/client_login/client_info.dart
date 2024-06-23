import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientInfo extends StatefulWidget {
  const ClientInfo({super.key});

  @override
  State<ClientInfo> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfo> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();

  Future<void> _saveClientInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('clients')
            .doc(user.uid)
            .set({
          'name': _nameController.text.trim(),
          'phoneNo': _phoneController.text.trim(),
          'designation': _designationController.text.trim(),
          'email': user.email,
          'role': 'client',
          // Add any other required fields here
        }, SetOptions(merge: true)); // Merge with existing document
        // Navigate to home page after saving
        Navigator.pushNamedAndRemoveUntil(
            context, '/clientDashboard', (route) => false);
      } catch (e) {
        // Handle errors
        print("Error saving client info: $e");
        showCustomSnackBar(
            context, 'Error saving information. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Information',
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
              labelText: 'Name',
              controller: _nameController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              labelText: 'Designation',
              controller: _designationController,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              labelText: 'Phone Number',
              controller: _phoneController,
            ),
            const Spacer(),
            CustomElevatedButton(
              onPressed: _saveClientInfo,
              title: 'Save & Proceed',
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
