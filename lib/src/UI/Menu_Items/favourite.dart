import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cu_events/src/models/event_model.dart'; // Adjust import as per your event model
import 'package:cu_events/src/reusable_widget/cachedImage.dart'; // Adjust import as per your cached image widget
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart'; // Firestore library

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final List<String> favoriteEventIds = favoriteProvider.favoriteEventIds;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: const Text('Favorite Events'),
      ),
      body: favoriteEventIds.isEmpty
          ? const Center(
              child: Text('No favorite events.'),
            )
          : FutureBuilder<List<EventModel>>(
              future: _fetchFavoriteEvents(favoriteEventIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingWidget();
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No favorite events.'),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == snapshot.data!.length) {
                        return const SizedBox(height: 20);
                      } else {
                        final event = snapshot.data![index];
                        return _buildEventCard(event, width, height, context);
                      }
                    },
                  );
                }
              },
            ),
    );
  }

  Future<List<EventModel>> _fetchFavoriteEvents(List<String> eventIds) async {
    try {
      List<EventModel> events = [];

      // Fetch events from Firestore based on eventIds
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      for (var doc in querySnapshot.docs) {
        // Explicitly cast doc.data() to Map<String, dynamic>
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Create EventModel using fromFirestore constructor
        EventModel event = EventModel.fromFirestore(data, doc.id);
        events.add(event);
      }

      return events;
    } catch (e) {
      print('Error fetching favorite events: $e');
      throw Exception('Failed to fetch favorite events');
    }
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Text('Error: $message'),
    );
  }

  Widget _buildEventCard(
    EventModel event,
    double width,
    double height,
    BuildContext context,
  ) {
    final cardHeight = height * 0.3;
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
            elevation: 4,
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
                                    color:
                                        isFavorite ? Colors.red : Colors.white,
                                  ),
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
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: primaryBckgnd),
                          ),
                          Text(
                            event.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 7,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            'Deadline: ${event.deadline.toString().split(' ')[0]}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.red),
                          ),
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
