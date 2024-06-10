import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/models/event_model.dart';
import 'package:cu_events/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // All Events
  Future<List<EventModel>> getAllEvents() async {
    QuerySnapshot snapshot = await _db.collection('events').get();

    return snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Events By category and subCategory
  Future<List<EventModel>> getEventsByCategoryAndSubcategory(
      String category, String? subcategory) async {
    // Create a query based on category
    Query query =
        _db.collection('events').where('category', isEqualTo: category);

    // Add subcategory filter if provided
    if (subcategory != null && subcategory.isNotEmpty) {
      query = query.where('subcategory', isEqualTo: subcategory);
    }

    QuerySnapshot snapshot = await query.get();

    return snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Popluar Events
  Future<List<EventModel>> getPopularEvents() async {
    QuerySnapshot snapshot =
        await _db.collection('events').where('popular', isEqualTo: true).get();

    return snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Upcoming Events
  Future<List<EventModel>> getUpcomingEvents() async {
    QuerySnapshot snapshot = await _db
        .collection('events')
        .where('startdate', isGreaterThanOrEqualTo: DateTime.now())
        .get();

    return snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Add Event
  Future<void> addEvent(EventModel event) async {
    try {
      await _db.collection('events').add(event.toFirestore());
    } catch (e) {
      // Handle errors (show error message, log, etc.)
      print('Error adding event: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

  // Update Event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _db
          .collection('events')
          .doc(event.id) // Assuming you have the event ID
          .update(event.toFirestore());
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  // Delete Event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }

  // Feedback
  Future<void> addFeedback(
      String name, String? email, String category, String feedback) async {
    try {
      final feedbackData = {
        'name': name,
        'email': email, // Store email even if it's null
        'category': category,
        'text': feedback,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _db.collection('feedback').add(feedbackData);
    } catch (e) {
      print('Error adding feedback: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

  // careting user documanrt for stroing data in firebase
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error creating user document: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

  // User Details Fetch From Firebase
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return UserModel(
          id: uid,
          firstName: snapshot.get('firstName'),
          lastName: snapshot.get('lastName'),
          email: snapshot.get('email'),
        );
      } else {
        return null; // User document not found
      }
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }
}
