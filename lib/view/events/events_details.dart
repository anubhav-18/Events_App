import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:cu_events/controller/notification.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/models/event.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context)!.settings.arguments as Event;

    Future<void> _downloadImage(BuildContext context, String imageUrl) async {
      final Uri uri = Uri.parse(imageUrl);
      final String imageName = uri.pathSegments.last.split('/').last;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/$imageName';
      await Dio().download(imageUrl, path);

      if (imageUrl.contains('.jpg') || imageUrl.contains('.jpeg') || imageUrl.contains('.png')) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Deadline: ${event.deadline.toString().split(' ')[0]}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Center(
                        child: CachedImage(
                      imageUrl: event.imageUrl,
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
                          _downloadImage(context, event.imageUrl);
                        }),
                  ),
                ],
              ),
              // Image.network(event.imageUrl),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                event.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Registration Link',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse(event.link);
                  if (!await launchUrl(url,
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch $url';
                  }
                },
                child: Text(
                  event.link,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
