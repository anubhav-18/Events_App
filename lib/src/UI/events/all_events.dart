import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/services/firestore_service.dart';
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
  List<EventModel> _allEvents = [];
  bool _isLoading = true;
  late AnimationController _controller;
  final user = FirebaseAuth.instance.currentUser;

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
      _allEvents = await _firestoreService.getAllEvents();
    } catch (e) {
      print('Error fetching all events: $e');
      // TODO: Handle error appropriately (e.g., show error message)
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: Text(
          'All Events',
          style: GoogleFonts.montserrat(
            // Use Montserrat for app bar title
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0, // Remove app bar shadow
      ),
      body: _isLoading
          ? _buildShimmerPlaceholder()
          : _allEvents.isEmpty
              ? const Center(
                  child: Text('No events found.'),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16), // Add padding to the grid
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Adjust card aspect ratio
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: _allEvents.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_allEvents[index]);
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
                    height: 144, // Adjust image height as needed
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
                                context, 'Please Login, To use this feature',isError: true);
                          }
                        },
                        iconSize: 32,
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
