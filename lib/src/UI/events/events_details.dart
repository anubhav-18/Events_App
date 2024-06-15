import 'dart:io';
import 'dart:ui';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/controller/notification.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({Key? key}) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage>
    with TickerProviderStateMixin {
  bool isFABOpen = false;
  bool showZoomedImage = false;
  late AnimationController _animationController;
  late AnimationController _controllerWishList;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _controllerWishList = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  void _toggleFAB() {
    setState(() {
      isFABOpen = !isFABOpen;
      if (isFABOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerWishList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final EventModel event =
        ModalRoute.of(context)!.settings.arguments as EventModel;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(event.id);

    final double screenHeight = MediaQuery.of(context).size.height;

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

      showCustomSnackBar(context, 'Downloading $imageName..');

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
                'Check out this Event:\n${event.title}\nDescription:\n${event.description}\n'
                'Download our app from the Play Store to stay updated with more events: \nlink',
            subject: 'Event: ${event.title}',
          );
        } else {
          throw Exception('File does not exist');
        }
      } catch (e) {
        showCustomSnackBar(context, 'Error sharing event: $e');
        print(e);
      }
    }

    void addToCalendar(BuildContext context, EventModel event) async {
      if (await Permission.calendarWriteOnly.request().isGranted ||
          await Permission.calendarFullAccess.request().isGranted) {
        try {
          tz.initializeTimeZones();

          String currentTimeZone = tz.local.name;

          // Find the corresponding Location object in the timezone database
          tz.Location? location =
              tz.timeZoneDatabase.locations[currentTimeZone];

          // If location is found, use it for TZDateTime conversion
          if (location != null) {
            final Event calendarEvent = Event(
                title: event.title,
                description: event.description,
                location: event.location,
                startDate: tz.TZDateTime.from(event.startdate!, location),
                endDate: tz.TZDateTime.from(event.enddate!, location));

            final result = await Add2Calendar.addEvent2Cal(calendarEvent);

            if (result) {
              showCustomSnackBar(context, 'Event added to calendar!');
            } else {
              showCustomSnackBar(context, 'Failed to add event to calendar!',
                  isError: true);
            }
          } else {
            showCustomSnackBar(
                context, 'Could not determine your timezone. Event not added.',
                isError: true);
          }
        } catch (e) {
          showCustomSnackBar(context, 'Error adding event to calendar',
              isError: true);
          print('Error adding event to calendar: $e');
        }
      } else {
        // Handle the case where permission is denied
        showCustomSnackBar(context, "Please grant calendar permission.",
            isError: true);
      }
    }

    Widget _buildFloatingActionButton(
      BuildContext context,
      EventModel event,
      String icon,
      String heroTag,
      Function()? onPressed,
    ) {
      return Container(
        margin: const EdgeInsets.symmetric(
            vertical: 8.0), // Add margin between buttons
        child: FloatingActionButton(
          heroTag: heroTag,
          onPressed: onPressed,
          backgroundColor: primaryBckgnd,
          child: SvgPicture.asset(
            icon,
            colorFilter: const ColorFilter.mode(
              whiteColor,
              BlendMode.srcIn,
            ),
          ),
        ),
      );
    }

    Widget _buildDetailRow(
        BuildContext context, String iconAssetPath, String label, String value,
        {VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconAssetPath,
                height: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: primaryBckgnd, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgndColor,
      body: SafeArea(
        child: AnnotatedRegion(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.dark, // Dark icons for status bar
          ),
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: screenHeight * 0.4,
                    floating: true,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: GestureDetector(
                        onTap: () {
                          setState(() {
                            showZoomedImage = true;
                          });
                        },
                        child: Stack(
                          children: [
                            Hero(
                              tag: event.imageUrl,
                              child: CachedImage(
                                imageUrl: event.imageUrl,
                                height: screenHeight * 0.4,
                                width: double.infinity,
                                boxFit: BoxFit.cover,
                              ),
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
                          ],
                        ),
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: whiteColor,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.2).animate(
                          CurvedAnimation(
                            parent: _controllerWishList,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: greyColor.withOpacity(0.4),
                          child: Center(
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
                              iconSize: 30,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  spreadRadius: -5,
                                  blurRadius: 7,
                                  offset: const Offset(0, -3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(color: primaryBckgnd),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  event.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Divider(
                                  height: 32,
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                _buildDetailRow(
                                  context,
                                  'assets/icons/calendar.svg',
                                  'Date:',
                                  DateFormat('EEEE, MMM d, yyyy')
                                      .format(event.startdate!),
                                ),
                                _buildDetailRow(
                                  context,
                                  'assets/icons/clock.svg',
                                  'Time:',
                                  DateFormat('h:mm a').format(event.startdate!),
                                ),
                                const Divider(
                                  height: 32,
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                if (event.link.isNotEmpty)
                                  _buildDetailRow(
                                    context,
                                    'assets/icons/link.svg',
                                    'Registration Link:',
                                    event.link,
                                    onTap: () async {
                                      final Uri url = Uri.parse(event.link);
                                      if (!await launchUrl(url,
                                          mode:
                                              LaunchMode.externalApplication)) {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                const Divider(
                                  height: 32,
                                  thickness: 1,
                                  color: Colors.grey,
                                ),
                                if (event.location.isNotEmpty)
                                  _buildDetailRow(
                                    context,
                                    'assets/icons/location.svg',
                                    'Location:',
                                    event.location,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showZoomedImage)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        showZoomedImage = false;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ),
                          PhotoView(
                            imageProvider:
                                CachedNetworkImageProvider(event.imageUrl),
                            minScale: PhotoViewComputedScale.contained * 0.8,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            heroAttributes:
                                PhotoViewHeroAttributes(tag: event.imageUrl),
                          ),
                          Positioned(
                            top: 30,
                            right: 10,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  showZoomedImage = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!showZoomedImage)
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isFABOpen)
                        _buildFloatingActionButton(
                          context,
                          event,
                          'assets/icons/calendar1.svg',
                          'calenderBtn',
                          () {
                            addToCalendar(context, event);
                          },
                        ),
                      if (isFABOpen)
                        _buildFloatingActionButton(
                          context,
                          event,
                          'assets/icons/share1.svg',
                          'shareBtn',
                          () {
                            _shareEvent(context, event.imageUrl);
                          },
                        ),
                      if (isFABOpen)
                        _buildFloatingActionButton(
                          context,
                          event,
                          'assets/icons/download1.svg',
                          'downloadBtn',
                          () {
                            _downloadImage(context, event.imageUrl);
                          },
                        ),
                      FloatingActionButton(
                        onPressed: _toggleFAB,
                        backgroundColor: primaryBckgnd,
                        child: AnimatedIcon(
                          icon: AnimatedIcons.menu_close,
                          progress: _animationController,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
