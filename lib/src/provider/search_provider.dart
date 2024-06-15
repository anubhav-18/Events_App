import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _searchResults = [];
  List<EventModel> _popularEvents = [];
  List<String> _recentSearches = [];
  List<String> _trendingSearches = [];
  bool _isLoading = false;

  List<EventModel> get searchResults => _searchResults;
  List<EventModel> get popularEvents => _popularEvents;
  List<String> get recentSearches => _recentSearches;
  List<String> get trendingSearches => _trendingSearches;
  bool get isLoading => _isLoading;

  SearchProvider() {
    _loadRecentSearches();
    _fetchTrendingSearches();
    _loadPopularEvents();
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

  Future<void> _loadPopularEvents() async {
    try {
      _popularEvents = await _firestoreService.getPopularEvents();
      notifyListeners();
    } catch (e) {
      print('Error fetching popular events searches: $e');
    }
  }

  Future<void> searchEvents(String query) async {
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
      List<EventModel> titleResults =
          await _firestoreService.searchEvents(query.toLowerCase());
      print("Title results: $titleResults");
      List<EventModel> categoryResults = await _firestoreService
          .searchEventsByCategoryOrSubcategory(query.toLowerCase());
      print("Category results: $categoryResults");
      Set<EventModel> uniqueResults = {...titleResults, ...categoryResults};

      print('Unique search results: $uniqueResults');
      _searchResults = uniqueResults.toList();
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
