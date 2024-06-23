import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _searchResults = [];
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  bool _isLoading = false;

  List<EventModel> get searchResults => _searchResults;
  List<String> get recentSearches => _recentSearches;
  List<String> get trendingSearches => _trendingSearches;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _loadRecentSearches();
    _fetchTrendingSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _recentSearches =
          prefs.getStringList('recent_searches')?.take(4).toList() ?? [];
      notifyListeners();
    } catch (e) {
      print("Failed to load recent searches: $e");
    }
  }

  Future<void> _fetchTrendingSearches() async {
    try {
      _trendingSearches = await _firestoreService.getTrendingSearches();
      notifyListeners();
    } catch (e) {
      print('Error fetching trending searches: $e');
    }
  }

  void updateSearchResults(List<EventModel> newResults) {
    _searchResults = newResults;
    notifyListeners();
  }

  Future<void> searchEvents(String query, {bool isTagSearch = false}) async {
    print('Searching for: $query');
    if (query.isEmpty) {
      _searchResults.clear();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<EventModel> results = [];
      if (isTagSearch) {
        // results =
            // await _firestoreService.searchEventsByTags([query.toLowerCase()]);
      } else {
        final titleResults =
            await _firestoreService.searchEvents(query.toLowerCase());
        // final tagResults =
            // await _firestoreService.searchEventsByTags([query.toLowerCase()]);

        // Combine and deduplicate results (you can optimize this as needed)
        final uniqueResults = Set<EventModel>();
        uniqueResults.addAll(titleResults);
        // uniqueResults.addAll(tagResults);
        results = uniqueResults.toList();
      }

      _searchResults = results;
      _isLoading = false;
      notifyListeners();
      _updateRecentSearches(query);
    } catch (e) {
      print('Failed to search events: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateRecentSearches(String query) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      query = query.trim();
      List<String> words = query.split(RegExp(r'\W+'));
      for (String word in words) {
        if (word.length > 2 && !_recentSearches.contains(word)) {
          _recentSearches.removeWhere(
              (element) => element.toLowerCase() == word.toLowerCase());
          _recentSearches.insert(0, word);
          if (_recentSearches.length > 5) {
            _recentSearches.removeLast();
          }
        }
      }
      await prefs.setStringList('recent_searches', _recentSearches);
      notifyListeners();
      print("Updated recent searches: $_recentSearches");
    } catch (e) {
      print('Failed to update recent searches: $e');
    }
  }

  void removeRecentSearch(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _recentSearches.removeAt(index);
      notifyListeners();
      await prefs.setStringList('recent_searches', _recentSearches);
      print("Removed recent search at index $index: $_recentSearches");
    } catch (e) {
      print("Failed to remove recent search: $e");
    }
  }
}
