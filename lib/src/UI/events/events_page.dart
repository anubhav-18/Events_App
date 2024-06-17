import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class EventsPage extends StatefulWidget {
  final String category;
  final String? subcategory;

  const EventsPage({
    Key? key,
    required this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  // List<EventModel> _events = [];
  bool _isLoading = true;
  final AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  List<String> _selectedFilters = [];
  bool _showNoEventsMessage = false;

  // String? filterValue;
  final List<String> _filters = [
    "Upcoming Events",
    "Completed Events",
    "Ongoing Events",
  ];

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text
        .split(' ')
        .map((word) => toBeginningOfSentenceCase(word))
        .join(' ');
  }

  Future<void> _fetchEvents() async {
    try {
      final events = await _firestoreService.getEventsByCategoryAndSubcategory(
        widget.category,
        widget.subcategory ?? '',
      );
      setState(() {
        _events = events;
        _filteredEvents = List.from(_events);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text(
          widget.subcategory != null
              ? toBeginningOfSentenceCase(widget.subcategory!)
              : toBeginningOfSentenceCase(widget.category),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return _filterBottom();
                  });
            },
            icon: SvgPicture.asset(
              'assets/icons/filter.svg',
              width: 25,
              height: 25,
              colorFilter: const ColorFilter.mode(
                whiteColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchEvents,
          child: _isLoading
              ? _buildShimmerPlaceholder(width, height)
              : _showNoEventsMessage || _events.isEmpty
                  ? Center(
                      child: Text(
                        'No events found at this moment.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredEvents.length +
                          1, // Add one extra item for the SizedBox
                      itemBuilder: (context, index) {
                        if (index < _filteredEvents.length) {
                          return _buildEventCard(
                              _filteredEvents[index], width, height);
                        } else {
                          return const SizedBox(height: 20);
                        }
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    EventModel event,
    double width,
    double height,
  ) {
    final cardHeight = height * 0.28;
    final cardWidth = width;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(event.id);
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_details', arguments: event);
      },
      child: Container(
        margin: width > 600 ? AppMargins.large : AppMargins.medium,
        height: cardHeight,
        width: cardWidth,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          child: Card(
            color: whiteColor,
            margin: EdgeInsets.zero,
            elevation: 2,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: SizedBox(
                        height: cardHeight,
                        width: cardWidth * 0.45,
                        child: Stack(
                          children: [
                            CachedImage(
                              imageUrl: event.imageUrl,
                              height: cardHeight,
                              width: cardWidth * 0.45,
                              boxFit: BoxFit.fill,
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.black45, Colors.black26],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  if (user != null) {
                                    favoriteProvider.toggleFavorite(event.id);
                                  } else {
                                    showCustomSnackBar(context,
                                        'Please Login, To use this feature',
                                        isError: true);
                                  }
                                },
                                iconSize: 32,
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            event.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    color: primaryBckgnd,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            event.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 7,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            'Deadline: ${event.deadline.toString().split(' ')[0]}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterBottom() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: backgndColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Events',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: primaryBckgnd,
                  ),
            ),
            const SizedBox(
              height: 16,
            ),
            // Filter Options
            Expanded(
              child: ListView(
                children: _filters.map((filter) {
                  return CheckboxListTile(
                    title: Text(
                      filter,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: _selectedFilters.contains(filter),
                    activeColor: primaryBckgnd,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null && value) {
                          _selectedFilters.add(filter);
                        } else {
                          _selectedFilters.remove(filter);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Center(
              child: CustomElevatedButton(
                onPressed: () {
                  _applyFilter();
                  Navigator.pop(context); // Close the bottom sheet
                },
                title: 'Apply Filter',
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _applyFilter() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      _filteredEvents = _events.where((event) {
        bool isUpcoming = _selectedFilters.contains('Upcoming Events') &&
            event.startdate!.isAfter(DateTime.now());
        bool isCompleted = _selectedFilters.contains('Completed Events') &&
            event.enddate!.isBefore(DateTime.now());
        bool isOngoing = _selectedFilters.contains('Ongoing Events') &&
            event.startdate!.isBefore(DateTime.now()) &&
            event.enddate!.isAfter(DateTime.now());

        // If no filters are selected, show all events
        return _selectedFilters.isEmpty ||
            isUpcoming ||
            isCompleted ||
            isOngoing;
      }).toList();
      setState(() {
        _showNoEventsMessage = _filteredEvents.isEmpty;
      });
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false; // Done loading
      });
    }
  }

  Widget _buildShimmerPlaceholder(double screenSize, double height) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: screenSize > 600 ? AppMargins.large : AppMargins.medium,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
