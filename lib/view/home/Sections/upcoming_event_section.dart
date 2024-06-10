// upcoming_events_list.dart
import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/models/event_model.dart';
import 'package:shimmer/shimmer.dart';

class UpcomingEventsList extends StatelessWidget {
  final List<EventModel> upcomingEvents;
  final bool isLoading;

  const UpcomingEventsList({
    Key? key,
    required this.upcomingEvents,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: MediaQuery.of(context).size.height *
              0.25, // Adjust height as needed
          child: isLoading
              ? _buildShimmerPlaceholder()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/event_details',
                            arguments: event);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.46,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedImage(
                              imageUrl: event.imageUrl,
                              width: 150, // Adjust width as needed
                              height: double.infinity,
                              boxFit: BoxFit.cover,
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
