import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;         // Unique identifier for the comment
  final String eventId;     // ID of the event the comment belongs to
  final String authorName;  // Name of the user who posted the comment
  final String text;        // The actual comment text
  final DateTime timestamp; // Timestamp of when the comment was posted

  CommentModel({
    required this.id,
    required this.eventId,
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  factory CommentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    Map<String, dynamic> data = doc.data()!;
    return CommentModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'authorName': authorName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
