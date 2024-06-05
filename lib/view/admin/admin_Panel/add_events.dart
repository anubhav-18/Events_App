import 'dart:io';
import 'package:cu_events/models/event.dart';
import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

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
  final _locationController = TextEditingController();
  DateTime _startdate = DateTime.now();
  DateTime _enddate = DateTime.now();
  DateTime _deadline = DateTime.now();
  bool _popular = false;
  String _selectedCategory = 'engineering';
  String _selectedSubcategory = 'academic';
  File? _image;
  bool _isLoading = false;

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
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
              // location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 20),
              // popular event
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
              // startdate
              Text(
                'StartDate: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  elevatedButton(
                    context,
                    () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _startdate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_startdate),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _startdate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    'Select StartDate',
                    null,
                  ),
                  const SizedBox(width: 8.0),
                  Text(dateFormat.format(_startdate),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 20),
              // enddate
              Text(
                'EndDate: ',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                children: [
                  elevatedButton(
                    context,
                    () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: _enddate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_enddate),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            _enddate = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    'Select EndDate',
                    null,
                  ),
                  const SizedBox(width: 8.0),
                  Text(dateFormat.format(_enddate),
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
              const SizedBox(height: 20),
              // image picker
              Text(
                'Pick Image:',
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
              elevatedButton(
                context,
                _isLoading ? null : _addEvent,
                'Add Event',
                double.infinity,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final imageUrl = await _uploadImage();
      if (imageUrl != null) {
        final event = EventModel(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          imageUrl: imageUrl,
          link: _linkController.text,
          category: _selectedCategory,
          subcategory: _selectedSubcategory,
          deadline: _deadline,
          popular: _popular,
          startdate: _startdate,
          enddate: _enddate,
          location: _locationController.text,
        );

        await FirebaseFirestore.instance
            .collection('events')
            .add(event.toFirestore());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event added successfully'),
          ),
        );

        setState(() {
          _isLoading = false;
          _formKey.currentState!.reset();
          _titleController.clear();
          _descriptionController.clear();
          _linkController.clear();
          _selectedCategory = 'engineering';
          _selectedSubcategory = 'academic';
          _image = null;
          _deadline = DateTime.now();
          _locationController.clear();
          _enddate = DateTime.now();
          _startdate = DateTime.now();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
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
}
