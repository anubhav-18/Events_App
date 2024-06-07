import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cu_events/firestore_service.dart';
import 'package:cu_events/reusable_widget/custom_snackbar.dart';

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
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Your Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Your Email'),
                  // You can add email validation if needed
                ),
                const SizedBox(height: 20),
                // Feedback Category Dropdown
                DropdownButtonFormField<String>(
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
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Enter your feedback here...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: elevatedButton(
                    context,
                    _isSubmitting ? null : _submitFeedback,
                    'Submit Feedback',
                    null,
                  ),
                )
              ],
            ),
          ),
        ),
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

      showCustomSnackBar(context, 'Thank you for your feedback!');

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
          context, 'Failed to submit feedback. Please try again later.');
      print('Error submitting feedback: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
}
