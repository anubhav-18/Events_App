import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String subcategory;
  final String link;
  final DateTime? deadline;
  final bool popular;
  final DateTime? startdate;
  final DateTime? enddate;
  final String location;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.subcategory,
    required this.link,
    required this.deadline,
    required this.popular,
    required this.startdate,
    required this.enddate,
    required this.location,
  });

  factory EventModel.fromFirestore(Map<String, dynamic> data, String id) {
    return EventModel(
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
      startdate: data['startdate'] != null
          ? (data['startdate'] is Timestamp
              ? (data['startdate'] as Timestamp).toDate()
              : DateTime.parse(data['startdate']))
          : null,
      enddate: data['enddate'] != null
          ? (data['enddate'] is Timestamp
              ? (data['enddate'] as Timestamp).toDate()
              : DateTime.parse(data['enddate']))
          : null,
      location: data['location'] ?? '',
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
      'startdate': startdate,
      'enddate': enddate,
      'location': location,
    };
  }
}
