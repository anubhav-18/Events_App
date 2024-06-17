import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/custom_button.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for Google Fonts

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({Key? key}) : super(key: key);

  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  late AnimationController _controller;
  final user = FirebaseAuth.instance.currentUser;

  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  List<String> _selectedFilters = [];
  bool _showNoEventsMessage = false;

  final List<String> _filters = [
    "Upcoming Events",
    "Completed Events",
    "Ongoing Events",
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllEvents();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  Future<void> _fetchAllEvents() async {
    try {
      // _allEvents = await _firestoreService.getAllEvents();
      final allEvents = await _firestoreService.getAllEvents();
      setState(() {
        _allEvents = allEvents;
        _filteredEvents = List.from(_allEvents);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching all events: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          'All Events',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
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
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildShimmerPlaceholder()
          : _showNoEventsMessage || _allEvents.isEmpty
              ? Center(
                  child: Text(
                    'No events found at this moment.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16), // Add padding to the grid
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Adjust card aspect ratio
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_filteredEvents[index]);
                  },
                ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(event.id);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_details', arguments: event);
      },
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
              child: Stack(
                children: [
                  CachedImage(
                    imageUrl: event.imageUrl,
                    height: 155, // Adjust image height as needed
                    width: double.infinity,
                    boxFit: BoxFit.cover,
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
                    child: ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.2).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (user != null) {
                            favoriteProvider.toggleFavorite(event.id);
                          } else {
                            showCustomSnackBar(
                                context, 'Please Login, To use this feature',
                                isError: true);
                          }
                        },
                        iconSize: 30,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                    maxLines: 2,
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
    );
  }

  Widget _filterBottom() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height *
              0.4, // Adjust height as needed
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Events',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: primaryBckgnd,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                // Let the list take up remaining space
                child: ListView(
                  children: _filters.map((filter) {
                    return CheckboxListTile(
                      title: Text(
                        filter,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      activeColor: primaryBckgnd,
                      value: _selectedFilters.contains(filter),
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
      },
    );
  }

  Future<void> _applyFilter() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _filteredEvents = _allEvents.where((event) {
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
      print('Error applying filter: $e');
      // TODO: Handle error appropriately
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Shimmer Placeholder
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        padding: const EdgeInsets.all(16),
        children: List.generate(8, (index) {
          return Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Container(
                  height: 120, // Adjust shimmer image height
                  width: double.infinity,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
