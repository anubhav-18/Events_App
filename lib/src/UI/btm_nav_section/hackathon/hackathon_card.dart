import 'package:cu_events/src/models/hackathon_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class HackathonCard extends StatelessWidget {
  final Hackathon hackathon;

  const HackathonCard({Key? key, required this.hackathon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(10), // Add margin for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hackathon Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              hackathon.imageUrl, // Assuming you have image URLs
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hackathon Name
                Text(
                  hackathon.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                // Organizer
                Text(
                  'Organized by ${hackathon.organizer}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 12),

                // Prize Money (if available)
                if (hackathon.prize != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text('₹${hackathon.prize}'),
                    ],
                  ),

                // Status & Days Left
                Row(
                  children: [
                    Icon(
                      hackathon.status == 'Live'
                          ? Icons.circle
                          : Icons.access_time_filled,
                      color: hackathon.status == 'Live' ? Colors.green : Colors.orange,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${hackathon.status} - ${hackathon.daysLeft} days left',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Registered Participants (if available)
                if (hackathon.registered != null)
                  Row(
                    children: [
                      const Icon(Icons.people_outline),
                      const SizedBox(width: 8),
                      Text('${hackathon.registered} registered'),
                    ],
                  ),

                const SizedBox(height: 16),

                // Categories
                Wrap(
                  spacing: 8.0,
                  children: hackathon.categories.map((category) {
                    return Chip(
                      label: Text(category),
                      backgroundColor: Colors.blue[100], // Light blue color
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () async {
                String urlString = 'https://www.google.com/';
                if (await canLaunchUrl(Uri.parse(urlString))) {
                  await launchUrl(Uri.parse(urlString),
                      mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          )
        ],
      ),
    );
  }
}

