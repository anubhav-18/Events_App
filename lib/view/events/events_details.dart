import 'dart:io';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:cu_events/controller/notification.dart';
import 'package:cu_events/reusable_widget/circular_elevated.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/models/event.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EventModel events =
        ModalRoute.of(context)!.settings.arguments as EventModel;

    Future<void> _downloadImage(BuildContext context, String imageUrl) async {
      final Uri uri = Uri.parse(imageUrl);
      final String imageName = uri.pathSegments.last.split('/').last;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/$imageName';
      await Dio().download(imageUrl, path);

      if (imageUrl.contains('.jpg') ||
          imageUrl.contains('.jpeg') ||
          imageUrl.contains('.png')) {
        await ImageGallerySaver.saveFile(path);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $imageName..')),
      );

      await NotificationService.showNotification(
        title: imageName,
        body: 'Download Complete',
        payload: imageUrl,
      );
    }

    Future<void> _shareEvent(BuildContext context, String imageUrl) async {
      try {
        final tempDir = await getTemporaryDirectory();
        final response = await http.get(Uri.parse(imageUrl));
        final file = File('${tempDir.path}/event.png');
        await file.writeAsBytes(response.bodyBytes);

        if (await file.exists()) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text:
                'Check out this Event:\n${events.title}\nDescription:\n${events.description}\n'
                'Download our app from the Play Store to stay updated with more events: \nlink',
            subject: 'Event: ${events.title}',
          );
        } else {
          throw Exception('File does not exist');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing event: $e')),
        );
        print(e);
      }
    }

    void addToCalendar(BuildContext context, EventModel event) {
      print("Adding event to calendar");
      try {
        final Event calendarEvent = Event(
          title: event.title,
          description: event.description,
          location: event.location,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        );

        print("event details:");
        print("Title: ${event.title}");
        print("Description: ${event.description}");
        print(event.location);
        print(DateTime.now());

        Add2Calendar.addEvent2Cal(calendarEvent).then((success) {
          print("Event added to calendar: $success");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Event added to calendar!'
                  : 'Failed to add event to calendar'),
            ),
          );
        }).catchError((error) {
          print("Error adding event to calendar: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add event to calendar')),
          );
        });
      } catch (e) {
        print("Exception caught: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exception while adding to calendar: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Marquee(
          directionMarguee: DirectionMarguee.oneDirection,
          textDirection: TextDirection.ltr,
          animationDuration: const Duration(seconds: 2),
          forwardAnimation: Curves.easeIn,
          child: Text(events.title),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Deadline
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Deadline: ${events.deadline.toString().split(' ')[0]}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              // Image + Download Button
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Center(
                        child: CachedImage(
                      imageUrl: events.imageUrl,
                    )),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          _downloadImage(context, events.imageUrl);
                        }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                'Description',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              Text(
                events.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Regestration Link
              Text(
                'Registration Link',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(events.link);
                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  events.link,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              // Start Date
              Text(
                'Start Date: ',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              Text(
                '2024-06-05 06:00 PM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // End Date
              Text(
                'End Date: ',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              Text(
                '2024-06-04 10:00 PM',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Location
              Text(
                'Location: ',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: primaryBckgnd),
              ),
              Text(
                'Chandiagrh University, Block B2',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularElevatedButton(
                    onPressed: () => _shareEvent(context, events.imageUrl),
                    icon: Icons.share,
                  ),
                  const SizedBox(width: 15),
                  CircularElevatedButton(
                    onPressed: () {
                      addToCalendar(context, events);
                    },
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
