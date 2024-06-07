import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/firestore_service.dart';
import 'package:cu_events/models/event.dart';
import 'package:intl/intl.dart';
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

class _EventsPageState extends State<EventsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _events = [];
  bool _isLoading = true;

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
      // Fetch events based on category and subcategory
      _events = await _firestoreService.getEventsByCategoryAndSubcategory(
        widget.category,
        widget.subcategory ?? '', // Handle potentially null subcategory
      );
    } catch (e) {
      // Handle errors here
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: Text(
          '${widget.subcategory != null ? toBeginningOfSentenceCase(widget.subcategory!) : toBeginningOfSentenceCase(widget.category)} Events',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: RefreshIndicator(
        // Add RefreshIndicator for pull-to-refresh
        onRefresh: _fetchEvents,
        child: _isLoading // Check if loading
            ? _buildShimmerPlaceholder(width, height) // Show shimmer if loading
            : _events.isEmpty
                ? const Center(child: Text('No events found.'))
                : ListView.builder(
                    itemCount: _events.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _events.length) {
                        return const SizedBox(
                          height: 20,
                        );
                      } else {
                        final event = _events[index];
                        return _buildEventCard(event, width, height);
                      }
                    },
                  ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, double screenSize, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_details', arguments: event);
      },
      child: Container(
        margin: screenSize > 600 ? AppMargins.large : AppMargins.medium,
        child: Card(
          elevation: 4, // Add some elevation for a 3D effect
          // color: whiteColor,
          color: Colors.grey[100],
          shape: RoundedRectangleBorder(
            // Add rounded corners to the card
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                // Clip the image to match the card's rounded corners
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedImage(
                  imageUrl: event.imageUrl,
                  height: height *
                      0.25, // Make the image smaller for more compact cards
                  width: double.infinity,
                  boxFit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: primaryBckgnd),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      maxLines: 3, // Limit description lines and show ellipsis
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: primaryBckgnd),
                        const SizedBox(width: 5),
                        Text(
                          '${DateFormat('MMM d').format(event.startdate!)} - ${DateFormat('MMM d').format(event.enddate!)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    // Add more event details here if you want (e.g., location, time)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder(double screenSize, double height) {
    return ListView.builder(
      itemCount: 4, // Number of shimmer placeholders to show
      itemBuilder: (context, index) => Container(
        margin: screenSize > 600 ? AppMargins.large : AppMargins.medium,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height * 0.4, // Set a height for the shimmer placeholder
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
