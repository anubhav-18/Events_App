import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:flutter/material.dart';

class AddHackathonPage extends StatefulWidget {
  const AddHackathonPage({Key? key}) : super(key: key);

  @override
  _AddHackathonPageState createState() => _AddHackathonPageState();
}

class _AddHackathonPageState extends State<AddHackathonPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _organizerController = TextEditingController();
  final _prizeController = TextEditingController();
  final _daysLeftController = TextEditingController();
  final _registeredController = TextEditingController();
  final _imageUrlController = TextEditingController();
  List<String> _selectedCategories = [];

  void _addHackathon() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('hackathons').add({
          'name': _nameController.text,
          'organizer': _organizerController.text,
          'prize': _prizeController.text,
          'status': 'Upcoming', // Default status
          'daysLeft': _daysLeftController.text,
          'registered': _registeredController.text,
          'categories': _selectedCategories,
          'imageUrl': _imageUrlController.text,
        }); // Close the page after adding
        showCustomSnackBar(context, 'Hackathon added successfully!');
      } catch (e) {
        showCustomSnackBar(context, 'Error adding hackathon: $e');
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Hackathon'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Allow scrolling for the form
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TextFormFields for name, organizer, prize, daysLeft, registered, imageUrl
              // Checkbox/Chip widgets for selecting categories
              CustomTextField(labelText: 'Name', controller: _nameController),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  labelText: 'organizer', controller: _organizerController),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  labelText: 'prizes', controller: _prizeController),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  labelText: "daysleft", controller: _daysLeftController),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  labelText: 'registred', controller: _registeredController),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  labelText: 'imageUrl', controller: _imageUrlController),
              const SizedBox(
                height: 20,
              ),
              CustomElevatedButton(
                onPressed: _addHackathon,
                title: 'Add Hackathon',
                width: double.infinity,
              )
            ],
          ),
        ),
      ),
    );
  }
}
