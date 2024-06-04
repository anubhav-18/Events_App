import 'dart:io';

import 'package:cu_events/constants.dart';
import 'package:cu_events/models/event.dart';
import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddEventsPanel extends StatefulWidget {
  const AddEventsPanel({Key? key}) : super(key: key);

  @override
  _AddEventsPanelState createState() => _AddEventsPanelState();
}

class _AddEventsPanelState extends State<AddEventsPanel> {
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/admin_login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<bool>(
      future: _checkAdmin(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          // If the user is not an admin, show an error message
          return const Scaffold(
            body: Center(
              child: Text('You do not have admin rights.'),
            ),
          );
        } else {
          // User is authenticated and is an admin
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Title is required' : null,
                    ),
                    // description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                    // link
                    TextFormField(
                      controller: _linkController,
                      decoration: InputDecoration(
                        labelText: 'Link',
                        labelStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Link is required' : null,
                    ),
                    const SizedBox(height: 20),
                    // popular event
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .start, // Align checkboxes to the start
                      children: [
                        Checkbox(
                          value: _popular,
                          onChanged: (value) {
                            setState(() {
                              _popular = value ?? false;
                            });
                          },
                        ),
                        Text(
                          'Popular Event',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // deadline
                    Text(
                      'Deadline: ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      children: [
                        elevatedButton(
                          context,
                          () async {
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
                          'Select Deadline',
                          null,
                        ),
                        const SizedBox(width: 8.0),
                        Text(_deadline.toString().split(' ')[0],
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // image picker
                    Text(
                      'Image Picker: ',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      children: [
                        elevatedButton(
                          context,
                          () async {
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
                          'Pick Image',
                          null,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _image != null ? _image!.path.split('/').last : '',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // category
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
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Subcategory
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
                      decoration: InputDecoration(
                        labelText: 'Subcategory',
                        labelStyle: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Button on Submit
                    SizedBox(
                      width: double.infinity,
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
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          backgroundColor: primaryBckgnd,
                        ),
                        child: Text(
                          'Add Event',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }
      },
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

  Future<bool> _checkAdmin(User user) async {
    const adminEmail = 'cu.events.18@gmail.com';
    return user.email == adminEmail;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
