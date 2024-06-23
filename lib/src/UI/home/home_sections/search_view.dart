import 'package:cu_events/src/provider/search_provider.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isLoading = false;

  late SearchProvider searchProvider;
  String? initialQuery;

  @override
  void initState() {
    super.initState();
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    _searchFocusNode.requestFocus();
    // Check for initial query from the previous page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialQuery = ModalRoute.of(context)?.settings.arguments as String?;
      if (initialQuery != null) {
        _searchController.text = initialQuery!;
        searchProvider.searchEvents(initialQuery!, isTagSearch: true); 
        setState(() {}); // Trigger a rebuild to show the initial query
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSuffixIcon(SearchProvider searchProvider) {
    if (_searchController.text.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
            searchProvider.searchEvents('');
            setState(() {});
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: backgndColor,
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          statusBarIconBrightness: Brightness.dark, // Dark icons for status bar
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8, left: 16, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 0, left: 4, right: 4, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      onChanged: (text) {
                        searchProvider.searchEvents(text);
                        setState(() {});
                      },
                      onSubmitted: (text) {
                        searchProvider.searchEvents(text);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                        suffixIcon: _buildSuffixIcon(searchProvider),
                        contentPadding: const EdgeInsets.all(0),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16,
                          ),
                    ),
                  ),
                  if (_searchController.text.isEmpty) ...[
                    _buildRecentSearches(searchProvider),
                    _buildTrendingSearches(searchProvider),
                  ] else ...[
                    const Text('Search Results',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildSearchResults(searchProvider),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    return searchProvider.isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: primaryBckgnd,
            ),
          )
        : searchProvider.searchResults.isEmpty
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
                itemCount: searchProvider.searchResults.length,
                itemBuilder: (context, index) {
                  return _buildEventCard(
                      searchProvider.searchResults[index], false);
                },
              );
  }

  Widget _buildRecentSearches(SearchProvider searchProvider) {
    if (searchProvider.recentSearches.isEmpty) {
      return Container(); // Don't show if empty
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Searches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: searchProvider.recentSearches.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history), // Add leading icon
              title: Text(searchProvider.recentSearches[index]),
              onTap: () {
                _searchController.text = searchProvider.recentSearches[index];
                searchProvider
                    .searchEvents(searchProvider.recentSearches[index]);
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => searchProvider.removeRecentSearch(index),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTrendingSearches(SearchProvider searchProvider) {
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
          children: searchProvider.trendingSearches.map((search) {
            return ActionChip(
              label: Text(search),
              backgroundColor: backgndColor,
              labelStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 15),
              onPressed: () {
                _searchController.text = search;
                searchProvider.searchEvents(search);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
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
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  width: listView ? 150 : null,
                  height: listView ? 110 : null,
                  child: CachedImage(
                    imageUrl: event.imageUrl,
                    height: 150,
                    width: double.infinity,
                    boxFit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: listView ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
}
