import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _recentSearches = [];
  List<EventModel> _searchResults = [];
  List<String> _trendingSearches = [];
  List<EventModel> _popularEvents = [];
  bool _isLoading = false;

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _fetchTrendingSearches();
    _loadPopularEvents();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    // Dispose the FocusNode when the widget is disposed
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _recentSearches =
            prefs.getStringList('recent_searches')?.take(4).toList() ?? [];
      });
    } catch (e) {
      print("Falied to load recent searches: $e");
    }
  }

  Future<void> _fetchTrendingSearches() async {
    try {
      List<String> trendingSearches =
          await _firestoreService.getTrendingSearches();
      setState(() {
        _trendingSearches = trendingSearches;
      });
    } catch (e) {
      print('Error fetching trending searches: $e');
    }
  }

  Future<void> _loadPopularEvents() async {
    try {
      List<EventModel> popularEvents =
          await _firestoreService.getPopularEvents();
      setState(() {
        _popularEvents = popularEvents;
      });
    } catch (e) {
      print('Error fetching popular events searches: $e');
    }
  }

  Future<void> _searchEvents(String query) async {
    print('Searching for: $query');
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // List<EventModel> results = await _firestoreService.searchEvents(query);
      List<EventModel> titleResults =
          await _firestoreService.searchEvents(query.toLowerCase());
      List<EventModel> categoryResults = await _firestoreService
          .searchEventsByCategoryOrSubcategory(query.toLowerCase());
      Set<EventModel> uniqueResults = {...titleResults, ...categoryResults};

      print('Search results: $uniqueResults');
      setState(() {
        _searchResults = uniqueResults.toList();
        _isLoading = false;
      });
      _updateRecentSearches(query);
    } catch (e) {
      print('Failed to search events: $e');
      _isLoading = false;
    }
  }

  Future<void> _updateRecentSearches(String query) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      query = query.trim();
      List<String> words = query.split(RegExp(r'\W+'));
      for (String word in words) {
        if (word.length > 3 && !_recentSearches.contains(word)) {
          // Filter by length
          _recentSearches.removeWhere(
              (element) => element.toLowerCase() == word.toLowerCase());
          _recentSearches.insert(0, word);
          if (_recentSearches.length > 4) {
            _recentSearches.removeLast();
          }
        }
      }
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      print('Failed to update recent searches: $e');
    }
  }

  Widget _buildSearchResults() {
    print('Building search results');
    print("_searchResults length: ${_searchResults.length}");
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: primaryBckgnd,
            ),
          )
        : _searchResults.isEmpty
            ? const Center(child: Text('No results found'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  childAspectRatio: 0.8, // Adjust for card size
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(_searchResults[index], false);
                },
              );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) return Container(); // Don't show if empty

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history), // Add leading icon
              title: Text(_recentSearches[index]),
              onTap: () {
                _searchController.text = _recentSearches[index];
                _searchEvents(_recentSearches[index]);
              },
              trailing: IconButton(
                // Add trailing delete icon
                icon: const Icon(Icons.delete),
                onPressed: () => _removeRecentSearch(index),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _removeRecentSearch(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _recentSearches.removeAt(index);
      });
      await prefs.setStringList('recent_searches', _recentSearches);
    } catch (e) {
      print("failed to remove recent searches: $e");
    }
  }

  Widget _buildTrendingSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Searches',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: primaryBckgnd,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: _trendingSearches.map((search) {
            return ActionChip(
              label: Text(search),
              backgroundColor: backgndColor,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 15),
              onPressed: () {
                _searchController.text = search;
                _searchEvents(search);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPopularEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Events',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: primaryBckgnd,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          // Wrap in SizedBox to limit height
          height: 200, // Adjust height as needed
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 10,
              );
            },
            scrollDirection: Axis.horizontal,
            itemCount: _popularEvents.length,
            itemBuilder: (context, index) =>
                _buildEventCard(_popularEvents[index], true),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEventCard(EventModel event, bool listView) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_details', arguments: event);
      },
      child: SizedBox(
        width: listView ? 150 : null,
        child: Card(
          elevation: 5,
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  width: listView ? 150 : null, // Constrain width
                  height: listView ? 110 : null,
                  child: CachedImage(
                    imageUrl: event.imageUrl,
                    height: 150, // Adjust image height as needed
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),

              // Content Padding
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      event.title,
                      style: GoogleFonts.montserrat(
                        // Use Montserrat font
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: listView ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.grey[600],
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${DateFormat('MMM d').format(event.startdate!)} - ${DateFormat('MMM d').format(event.enddate!)}',
                          style: GoogleFonts.montserrat(
                            // Use Montserrat font
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (status == SpeechToText.listeningStatus) {
            setState(() => _isListening = true);
          }
        },
      );
      if (available) {
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();

      // Perform search when speech recognition stops
      _searchEvents(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgndColor,
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: whiteColor,
      //   elevation: 0,
      //   title: Container(
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(25),
      //     ),
      //     child: TextField(
      //       controller: _searchController,
      //       onChanged: (text) {
      //         _searchEvents(text);
      //       },
      //       onSubmitted: _searchEvents,
      //       decoration: InputDecoration(
      //         hintText: 'Search events...',
      //         hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
      //               fontSize: 16,
      //             ),
      //         filled: true,
      //         fillColor: Colors.white,
      //         border: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(15.0),
      //           borderSide: BorderSide(
      //             color: Colors.grey[400]!, // Outline color
      //             width: 2.0, // Outline width
      //           ),
      //         ),
      //         prefixIcon: IconButton(
      //           icon: const Icon(Icons.arrow_back),
      //           onPressed: () => Navigator.pop(context),
      //         ),
      //         suffixIcon: _searchController.text.isNotEmpty
      //             ? Container(
      //                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
      //                 decoration: BoxDecoration(
      //                   border: Border(
      //                     left: BorderSide(
      //                       color: Colors.grey[400]!, // Divider color
      //                       width: 1.0, // Divider thickness
      //                     ),
      //                   ),
      //                 ),
      //                 child: IconButton(
      //                   icon: const Icon(Icons.close),
      //                   onPressed: () {
      //                     _searchController.clear();
      //                     _searchEvents(
      //                         ''); // Trigger a new search with empty query
      //                     setState(() {});
      //                   },
      //                 ),
      //               )
      //             : Container(
      //                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
      //                 decoration: BoxDecoration(
      //                   border: Border(
      //                     left: BorderSide(
      //                       color: Colors.grey[400]!, // Divider color
      //                       width: 1.0, // Divider thickness
      //                     ),
      //                   ),
      //                 ),
      //                 child: IconButton(
      //                   icon: const Icon(Icons.mic),
      //                   onPressed: () {},
      //                 ),
      //               ),
      //         contentPadding: const EdgeInsets.all(0),
      //       ),
      //       style: Theme.of(context).textTheme.bodyMedium!.copyWith(
      //             fontSize: 16,
      //           ),
      //     ),
      //   ),
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          // Make content scrollable
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 10, left: 4, right: 4, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onChanged: (text) {
                      _searchEvents(text);
                    },
                    onSubmitted: _searchEvents,
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16,
                          ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(
                          color: Colors.grey[400]!, // Outline color
                          width: 2.0, // Outline width
                        ),
                      ),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.grey[400]!, // Divider color
                                    width: 1.0, // Divider thickness
                                  ),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchEvents('');
                                  setState(() {});
                                },
                              ),
                            )
                          : Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.grey[400]!, // Divider color
                                    width: 1.0, // Divider thickness
                                  ),
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                                onPressed: () => _startListening(),
                              ),
                            ),
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                        ),
                  ),
                ),
                if (_searchController.text.isEmpty) ...[ 
                  _buildRecentSearches(),
                  _buildTrendingSearches(),
                  _buildPopularEvents(),
                ] else ...[
                  const Text('Search Results',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildSearchResults()
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
