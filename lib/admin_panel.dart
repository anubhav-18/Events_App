import 'dart:io';

import 'package:cu_events/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  late DateTime _deadline = DateTime.now();
  bool _popular = false;
  String _selectedCategory = 'engineering';
  String _selectedSubcategory = 'academic';
  File? _image;

  final List<String> _categories = [
    'engineering',
    'medical',
    'law',
    'business',
    'other'
  ];
  final List<String> _subcategories = [
    'academic',
    'cultural',
    'nss_ncc',
    'others'
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If the user is not authenticated, redirect to the login screen
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/admin_login');
      });
      return const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Loading indicator while redirecting
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      value!.isEmpty ? 'Title is required' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Description is required' : null,
                ),
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'Link'),
                ),
                Row(
                  children: [
                    const Text('Deadline: '),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _deadline = selectedDate;
                          });
                        }
                      },
                      child: Text('Select Deadline'),
                    ),
                    const SizedBox(width: 8.0),
                    Text(_deadline.toString().split(' ')[0]),
                  ],
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align checkboxes to the start
                  children: [
                    Checkbox(
                      value: _popular,
                      onChanged: (value) {
                        setState(() {
                          _popular = value ?? false;
                        });
                      },
                    ),
                    Text('Popular Event'),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                    );
                    setState(() {
                      if (pickedFile != null) {
                        _image = File(pickedFile.path);
                      } else {
                        print('No image selected.');
                      }
                    });
                  },
                  child: const Text('Pick Image'),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((category) {
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedSubcategory,
                  items: _subcategories.map((subcategory) {
                    return DropdownMenuItem(
                      value: subcategory,
                      child: Text(subcategory),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategory = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Subcategory'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final imageUrl = await _uploadImage();
                        if (imageUrl != null) {
                          final event = Event(
                            id: '',
                            title: _titleController.text,
                            description: _descriptionController.text,
                            imageUrl: imageUrl,
                            link: _linkController.text,
                            category: _selectedCategory,
                            subcategory: _selectedSubcategory,
                            deadline: _deadline,
                            popular: _popular,
                          );
        
                          await FirebaseFirestore.instance
                              .collection('events')
                              .add(event.toFirestore());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Event added successfully'),
                            ),
                          );
                          _formKey.currentState!.reset();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to upload image'),
                            ),
                          );
                        }
                      }
                    },
                    child: Text('Add Event',style: Theme.of(context).textTheme.headlineLarge,),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
