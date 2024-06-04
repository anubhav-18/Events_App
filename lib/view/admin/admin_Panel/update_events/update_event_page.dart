import 'dart:io';

import 'package:cu_events/constants.dart';
import 'package:cu_events/reusable_widget/custom_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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

  String? selectedCategory;
  String? selectedSubcategory;
  DateTime? deadline;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event['title']);
    descriptionController =
        TextEditingController(text: widget.event['description']);
    linkController = TextEditingController(text: widget.event['link']);
    selectedCategory = widget.event['category'];
    selectedSubcategory = widget.event['subcategory'];
    deadline = widget.event['deadline']?.toDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: linkController,
              decoration: InputDecoration(
                labelText: 'Link',
                labelStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 10),
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
            elevatedButton(context, () async {
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
            }, 'Update Deadline', null),
            const SizedBox(height: 10),
            Text('Deadline: ${deadline?.toString().split(' ')[0]}'),
            const SizedBox(height: 10),
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
            }, 'Update Image', null),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                _image != null ? _image!.path.split('/').last : '',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: elevatedButton(context, () {
                  _updateEvent(
                    widget.event.id,
                    titleController.text,
                    descriptionController.text,
                    linkController.text,
                    selectedCategory,
                    selectedSubcategory,
                    deadline,
                    _image,
                  );
                  widget.onUpdate();
                  Navigator.pop(context); // Close the page
                }, 'Save Changes', double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateEvent(
    String eventId,
    String title,
    String description,
    String link,
    String? category,
    String? subcategory,
    DateTime? deadline,
    File? image,
  ) async {
    Map<String, dynamic> eventData = {
      'title': title,
      'description': description,
      'link': link,
      'category': category,
      'subcategory': subcategory,
      'deadline': deadline,
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
