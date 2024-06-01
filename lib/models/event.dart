import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String subcategory;
  final String link;
  final DateTime? deadline;
  final bool popular;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.subcategory,
    required this.link,
    required this.deadline,
    required this.popular,
  });

  factory Event.fromFirestore(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      subcategory: data['subcategory'] ?? '',
      link: data['link'] ?? '',
      deadline: data['deadline'] != null
          ? (data['deadline'] is Timestamp
              ? (data['deadline'] as Timestamp).toDate()
              : DateTime.parse(data['deadline']))
          : null,
      popular: data['popular'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'subcategory': subcategory,
      'link': link,
      'deadline': deadline,
      'popular': popular,
    };
  }
}
