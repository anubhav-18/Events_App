import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/models/event.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Event>> getEvents(String category, String subcategory) {
    return _db.collection('events')
              .where('category', isEqualTo: category)
              .where('subcategory', isEqualTo: subcategory)
              .snapshots()
              .map((snapshot) => snapshot.docs
                .map((doc) => Event.fromFirestore(doc.data(), doc.id))
                .toList());
  }

  Future<void> addEvent(Event event) {
    return _db.collection('events').add(event.toFirestore());
  }
}
