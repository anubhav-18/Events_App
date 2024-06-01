import 'package:cu_events/cachedImage.dart';
import 'package:cu_events/constants.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/firestore_service.dart';
import 'package:cu_events/models/event.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsPage extends StatelessWidget {
  final String category;
  final String subcategory;

  const EventsPage(
      {Key? key, required this.category, required this.subcategory})
      : super(key: key);

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text
        .split(' ')
        .map((word) => toBeginningOfSentenceCase(word) ?? '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    final screenSize = MediaQuery.of(context).size.width;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${capitalize(category)} - ${capitalize(subcategory)} Events',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: firestoreService.getEvents(category, subcategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/event_details',
                      arguments: event);
                },
                child: Container(
                  margin:
                      screenSize > 600 ? AppMargins.large : AppMargins.medium,
                  height: height * 0.3,
                  width: width * 1,
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: CachedImage(
                                imageUrl: event.imageUrl,
                                height: height * 0.2,
                                width: width * 0.45,
                                boxFit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  event.description,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 6,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () async {
                                    final Uri url = Uri.parse(event.link);
                                    if (!await launchUrl(url,
                                        mode: LaunchMode
                                            .externalApplication)) {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Text(
                                    event.link,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(height: 5),
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
                    ),
                  ),
                ),
              );

              // ListTile(
              //   contentPadding: const EdgeInsets.all(8.0),
              //   leading: SizedBox(
              //     width: MediaQuery.of(context).size.width * 0.4,
              //     child: Image.network(
              //       event.imageUrl,
              //       fit: BoxFit.cover,
              //       errorBuilder: (context, error, stackTrace) {
              //         return const Icon(Icons.error);
              //       },
              //     ),
              //   ),
              //   title: Text(event.title),
              //   onTap: () {
              //     Navigator.pushNamed(context, '/event_details',
              //         arguments: event);
              //   },
              // );
            },
          );
        },
      ),
    );
  }
}
