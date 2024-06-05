import 'dart:io';
import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateEventPage extends StatefulWidget {
  final DocumentSnapshot event;
  final VoidCallback onUpdate;

  const UpdateEventPage({required this.event, required this.onUpdate, Key? key})
      : super(key: key);

  @override
  _UpdateEventPageState createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController linkController;
  late TextEditingController locationController;
  File? _image;
  String? selectedCategory;
  String? selectedSubcategory;
  DateTime? deadline;
  DateTime? startdate;
  DateTime? enddate;
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
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event['title']);
    descriptionController =
        TextEditingController(text: widget.event['description']);
    linkController = TextEditingController(text: widget.event['link']);
    locationController = TextEditingController(text: widget.event['location']);
    selectedCategory = widget.event['category'];
    selectedSubcategory = widget.event['subcategory'];
    deadline = widget.event['deadline']?.toDate();
    startdate = widget.event['startdate']?.toDate();
    enddate = widget.event['enddate']?.toDate();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              // description
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              // link
              TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  labelText: 'Link',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              // location
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              // category
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              // subcategory
              DropdownButtonFormField<String>(
                value: selectedSubcategory,
                items: _subcategories.map((String subcategory) {
                  return DropdownMenuItem<String>(
                    value: subcategory,
                    child: Text(subcategory),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedSubcategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Subcategory',
                  labelStyle: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 10),
              // deadline
              Row(
                children: [
                  elevatedButton(
                    context,
                    () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: deadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          deadline = selectedDate;
                        });
                      }
                    },
                    'Deadline',
                    null,
                  ),
                  const SizedBox(width: 10),
                  Text('${deadline?.toString().split(' ')[0]}'),
                ],
              ),
              const SizedBox(height: 10),
              // startDate
              Row(
                children: [
                  elevatedButton(
                    context,
                    () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: startdate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              startdate ?? DateTime.now()),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            startdate = DateTime(
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
                    'StartDate',
                    null,
                  ),
                  const SizedBox(width: 5),
                  Text(startdate != null ? dateFormat.format(startdate!) : ''),
                ],
              ),
              const SizedBox(height: 10),
              // endDate
              Row(
                children: [
                  elevatedButton(
                    context,
                    () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: enddate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1),
                      );
                      if (selectedDate != null) {
                        final selectedTime = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(enddate ?? DateTime.now()),
                        );
                        if (selectedTime != null) {
                          setState(() {
                            enddate = DateTime(
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
                    'EndDate',
                    null,
                  ),
                  const SizedBox(width: 5),
                  Text(enddate != null ? dateFormat.format(enddate!) : ''),
                ],
              ),
              const SizedBox(height: 10),
              // image picker
              Row(
                children: [
                  elevatedButton(context, () async {
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 50,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _image = File(pickedFile.path);
                      });
                    }
                  }, 'Image', null),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _image != null ? _image!.path.split('/').last : '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // submit button or loading indicator
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : elevatedButton(
                      context,
                      () {
                        setState(() {
                          _isLoading = true;
                        });
                        _updateEvent(
                          widget.event.id,
                          titleController.text,
                          descriptionController.text,
                          linkController.text,
                          selectedCategory,
                          selectedSubcategory,
                          deadline,
                          startdate,
                          enddate,
                          _image,
                        ).then((_) {
                          setState(() {
                            _isLoading = false;
                          });
                          widget.onUpdate();
                          Navigator.pop(context); // Close the page
                        });
                      },
                      'Save Changes',
                      double.infinity,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateEvent(
    String eventId,
    String title,
    String description,
    String link,
    String? category,
    String? subcategory,
    DateTime? deadline,
    DateTime? startdate,
    DateTime? enddate,
    File? image,
  ) async {
    Map<String, dynamic> eventData = {
      'title': title,
      'description': description,
      'link': link,
      'category': category,
      'subcategory': subcategory,
      'deadline': deadline,
      'startdate': startdate,
      'enddate': enddate,
    };

    if (image != null) {
      // Upload image and update imageUrl in eventData
      final imageUrl = await _uploadImage(image);
      if (imageUrl != null) {
        eventData['imageUrl'] = imageUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image'),
          ),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .update(eventData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event updated successfully'),
        ),
      );
    } catch (e) {
      print('Failed to update event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update event'),
        ),
      );
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

}
