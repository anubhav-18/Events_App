import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RecommendedEventsList extends StatefulWidget {
  final bool isLoading;
  final List<EventModel> recommededEvents;
  final Function(String) onEventClick;

  const RecommendedEventsList({
    Key? key,
    required this.isLoading,
    required this.recommededEvents,
    required this.onEventClick,
  }) : super(key: key);

  @override
  State<RecommendedEventsList> createState() => _RecommendedEventsListState();
}

class _RecommendedEventsListState extends State<RecommendedEventsList>
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommeded Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height *
              0.25, // Adjust height as needed
          child: widget.isLoading
              ? _buildShimmerPlaceholder()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.recommededEvents.length,
                  itemBuilder: (context, index) {
                    final event = widget.recommededEvents[index];
                    final favoriteProvider =
                        Provider.of<FavoriteProvider>(context);
                    final isFavorite = favoriteProvider.isFavorite(event.id);
                    return GestureDetector(
                      onTap: () {
                        widget.onEventClick(event.id);
                        Navigator.pushNamed(context, '/event_details',
                            arguments: event);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.46,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Center(
                                  child: CachedImage(
                                    imageUrl: event.imageUrl,
                                    width: 170, // Adjust width as needed
                                    height: double.infinity,
                                    boxFit: BoxFit.cover,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black26,
                                          Colors.black12,
                                        ],
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
                                          favoriteProvider
                                              .toggleFavorite(event.id);
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
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3, // Number of shimmer items
        itemBuilder: (context, index) => Container(
          width: 150,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
