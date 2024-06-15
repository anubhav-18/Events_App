// favorite_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteProvider extends ChangeNotifier {
  late User _user; // Firebase user
  late FirebaseFirestore _firestore;

  List<String> _favoriteEventIds = [];
  bool _isLoading = true;

  // FavoriteProvider() {
  //   _firestore = FirebaseFirestore.instance;
  //   _user = FirebaseAuth.instance.currentUser!;
  //   _loadFavorites();
  // }

  FavoriteProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out, clear favorites
        _favoriteEventIds.clear();
      } else {
        _user = user;
        _loadFavorites();
      }
      notifyListeners();
    });
  }

  List<String> get favoriteEventIds => _favoriteEventIds;

  bool isFavorite(String eventId) {
    return _favoriteEventIds.contains(eventId);
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      if (_favoriteEventIds.contains(eventId)) {
        _favoriteEventIds.remove(eventId);
        await _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('favorites')
            .doc(eventId)
            .delete();
      } else {
        _favoriteEventIds.add(eventId);
        await _firestore
            .collection('users')
            .doc(_user.uid)
            .collection('favorites')
            .doc(eventId)
            .set({'eventId': eventId});
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Handle error appropriately, e.g., show error message
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user.uid)
          .collection('favorites')
          .get();
      _favoriteEventIds =
          snapshot.docs.map((doc) => doc.id).toList().cast<String>();
    } catch (e) {
      print('Error loading favorites: $e');
      // Handle error appropriately, e.g., show error message
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    _favoriteEventIds.clear();
    notifyListeners();
  }

  void updateUser(User user) {
    _user = user;
    _loadFavorites(); // Load favorites for the updated user
    notifyListeners();
  }
}
