import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_textfiled.dart';
import 'package:cu_events/src/reusable_widget/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General'; // Default category
  bool _isSubmitting = false;
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _feedbackCategories = [
    'General',
    'App Features',
    'Event Suggestions',
    'Technical Issues',
    'Contact US',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Feedback',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomTextField(
                        labelText: 'Name',
                        controller: _nameController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        labelText: 'Email',
                        controller: _emailController,
                        obscureText: false,
                      ),
                      const SizedBox(height: 20),
                      // Feedback Category Dropdown
                      CustomDropdown(
                        labelText: 'Category',
                        value: _selectedCategory,
                        items: _feedbackCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        labelText: 'Feedback',
                        hintText: 'Enter your feedback here...',
                        obscureText: false,
                        controller: _feedbackController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        maxLength: 1000,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              title: 'Submit Feedback',
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await _firestoreService.addFeedback(
          _nameController.text,
          _emailController.text,
          _selectedCategory,
          _feedbackController.text,
        );

        showCustomSnackBar(
          context,
          'Thank you for your feedback!',
        );

        // Clear text fields and reset category dropdown
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _feedbackController.clear();
        setState(() {
          _selectedCategory = 'General';
        });
      } catch (e) {
        showCustomSnackBar(
          context,
          'Failed to submit feedback. Please try again later.',
        );
        print('Error submitting feedback: $e');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
