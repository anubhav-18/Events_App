import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/models/comment_model.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/models/hackathon_model.dart';
import 'package:cu_events/src/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Hackathon>> getHackathons() {
    return _db
        .collection('hackathons')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Hackathon(
                id: doc.id,
                name: data['name'],
                organizer: data['organizer'],
                prize: data['prize'],
                status: data['status'],
                daysLeft: data['daysLeft'],
                registered: data['registered'],
                categories: List<String>.from(data['categories']),
                imageUrl: data['imageUrl'],
              );
            }).toList());
  }

  // fetch the featured evetns on the bsis of tags and other crietria
  Future<List<EventModel>> getFeaturedEvents(
      List<String>? userInterests) async {
    QuerySnapshot snapshot;
    List<EventModel> allEvents;

    // Check if any events have clicks
    final clickCheckSnapshot = await _db
        .collection('events')
        .where('clicks', isGreaterThan: 0)
        .limit(5)
        .get(); // Get up to 5 events with clicks

    if (clickCheckSnapshot.docs.isNotEmpty) {
      // If there are events with clicks, prioritize those
      snapshot = await _db
          .collection('events')
          .orderBy('clicks', descending: true)
          .limit(5) // Limit to a reasonable number
          .get();
    } else {
      // If no events have clicks, fall back to recent events
      snapshot = await _db
          .collection('events')
          .orderBy('startdate',
              descending: true) // Sort by most recent start date
          .limit(5) // Limit to a reasonable number
          .get();
    }

    allEvents = snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Exclude events that are already in the recommended list for this user
    if (userInterests != null && userInterests.isNotEmpty) {
      allEvents.removeWhere(
          (event) => event.tags.any((tag) => userInterests.contains(tag)));
    }

    // If there are still no events, return the original list
    if (allEvents.isEmpty) {
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } else {
      return allEvents
          .take(5)
          .toList(); // Take top 5 featured events (or any limit you prefer)
    }
  }

  // Add a user rating to an event
  Future<void> addUserRating(
      String userId, String eventId, double rating) async {
    final userRatingRef = _db
        .collection('userRatings')
        .doc('$userId-$eventId'); // Unique ID for the rating
    await userRatingRef.set({
      'userId': userId,
      'eventId': eventId,
      'rating': rating,
    });
    // After adding the user rating, update the overall event rating
    await updateEventRating(eventId, rating);
  }

  // Update event rating (modified)
  Future<void> updateEventRating(String eventId, double newRating) async {
    final eventRef = _db.collection('events').doc(eventId);
    final ratingsSnapshot = await eventRef.collection('userRatings').get();
    final ratings =
        ratingsSnapshot.docs.map((doc) => doc.get('rating') as double).toList();

    // Calculate the new average rating
    final totalRatings = ratings.length + 1; // Include the new rating
    final sumRatings =
        ratings.fold(0.0, (sum, rating) => sum + rating) + newRating;
    final averageRating = sumRatings / totalRatings;

    await eventRef
        .update({'rating': averageRating, 'ratingsCount': totalRatings});
  }

// Get the rating given by a specific user for an event
  Future<double?> getUserRatingForEvent(String userId, String eventId) async {
    final userRatingRef = _db.collection('userRatings').doc('$userId-$eventId');
    final userRatingDoc = await userRatingRef.get();
    if (userRatingDoc.exists) {
      return userRatingDoc.get('rating') as double;
    }
    return null; // User hasn't rated this event yet
  }

  // Get comments for a specific event
  Future<List<CommentModel>> getCommentsForEvent(String eventId) async {
    final querySnapshot = await _db
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .orderBy('timestamp', descending: true) // Sort by timestamp
        .get();

    return querySnapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc))
        .toList();
  }

// Add a comment to an event
  Future<void> addCommentToEvent(String eventId, CommentModel comment) async {
    try {
      await _db
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .add(comment.toFirestore());
    } catch (e) {
      print('Error adding comment: $e');
      throw e; // Or rethrow for higher-level error handling
    }
  }

  // Increment click count for an event
  Future<void> incrementEventClicks(String eventId) async {
    final eventRef = _db.collection('events').doc(eventId);
    try {
      // Use a transaction to ensure atomic update of the 'clicks' field
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(eventRef);
        if (!snapshot.exists) {
          throw Exception("Event not found");
        }

        int newClicks = (snapshot.data() as Map<String, dynamic>)['clicks'] + 1;
        transaction.update(eventRef, {'clicks': newClicks});
      });
    } catch (e) {
      print('Error incrementing event clicks: $e');
      // Handle errors appropriately (e.g., show error message to user)
    }
  }

  // update user interests
  Future<void> updateUserInterests(
      String userId, List<String> interests) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      // Update (or set if document doesn't exist) the 'interests' field
      await userRef.set({
        'interests': interests,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other user data
    } catch (e) {
      // Handle any potential errors here
      print("Error updating user interests: $e");
      throw e; // Or rethrow for higher-level error handling
    }
  }

  Future<List<String>> getUserInterests(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['interests'] != null) {
          // Ensure the 'interests' field is present and is a list
          return List<String>.from(data['interests']);
        }
      }
      return []; // Return an empty list if no interests or document found
    } catch (e) {
      // Handle potential errors here
      print("Error fetching user interests: $e");
      throw e; // Or rethrow for higher-level error handling
    }
  }

  // delete users account forever
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete the user document from Firestore
      await _db.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user account: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

  // update user details
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection('users')
          .doc(updatedUser.id) // Assuming you have the user ID
          .update(updatedUser.toMap());
    } catch (e) {
      print('Error updating user details: $e');
      throw e; // Re-throw the error to be handled in the UI
    }
  }

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

  //Completed Events
  Future<List<EventModel>> getCompletedEvents() async {
    QuerySnapshot snapshot = await _db
        .collection('events')
        .where('enddate', isLessThan: DateTime.now())
        .get();

    return snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
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

  // check user document exists or not
  Future<bool> userDocumentExists(String userId) async {
    DocumentSnapshot snapshot = 
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return snapshot.exists; // Return true if the document exists, false otherwise
  }

  // User Details Fetch From Firebase
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snapshot = await _db.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return UserModel.fromFirestore(
            snapshot.data() as Map<String, dynamic>, snapshot.id);
        // UserModel(
        //   id: uid,
        //   firstName: snapshot.get('firstName'),
        //   lastName: snapshot.get('lastName'),
        //   email: snapshot.get('email'),
        // );
      } else {
        return null; // User document not found
      }
    } catch (e) {
      print('Error getting user details: $e');
      return null;
    }
  }

  // Search Function by title
  Future<List<EventModel>> searchEvents(String query) async {
    print("Searching events by title with query: $query");
    QuerySnapshot snapshot = await _db
        .collection('events')
        .where('titleLowercase', isGreaterThanOrEqualTo: query)
        .where('titleLowercase', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    List<EventModel> results = snapshot.docs
        .map((doc) => EventModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    print("Found ${results.length} results by title");
    return results;
  }

  // Trending searches
  Future<List<String>> getTrendingSearches() async {
    return Future.delayed(const Duration(seconds: 1),
        () => ['Coding', 'Seminar', 'Workshop', 'Hackathon']);
  }
}
