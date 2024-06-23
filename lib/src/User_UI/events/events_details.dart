import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/comment_model.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/controller/notification.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

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

  final FirestoreService _firestoreService = FirestoreService();
  double _userRating = 0.0;
  List<CommentModel> _comments = []; // List to store comments
  final TextEditingController _commentController = TextEditingController();
  EventModel? event;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is EventModel) {
        setState(() {
          event = args;
          _fetchComments(); // Call _fetchComments here
          _getUserRating();
        });
      } else {
        // Handle the case where the event was not passed correctly.
        // You could navigate back or show an error message.
      }
    });
  }

  Future<void> _getUserRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final rating =
          await _firestoreService.getUserRatingForEvent(user.uid, event!.id);
      if (rating != null) {
        setState(() {
          _userRating = rating;
        });
      }
    }
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await _firestoreService.getCommentsForEvent(event!.id);
      setState(() {
        _comments = comments;
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
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

  Future<bool> _onWillPop() async {
    if (showZoomedImage) {
      setState(() {
        showZoomedImage = false;
      });
      return false; // Prevent default back navigation
    }
    return true; // Allow default back navigation
  }

  @override
  Widget build(BuildContext context) {
    final EventModel event =
        ModalRoute.of(context)!.settings.arguments as EventModel;
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(event.id);

    final double screenHeight = MediaQuery.of(context).size.height;

    Future<void> _downloadImage(BuildContext context, String imageUrl) async {
      try {
        final Uri uri = Uri.parse(imageUrl);
        final String imageName = uri.pathSegments.last.split('/').last;

        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/$imageName';

        showCustomSnackBar(context, 'Downloading $imageName...',
            isLoading: true);

        await Dio().download(imageUrl, path);

        if (imageUrl.contains('.jpg') ||
            imageUrl.contains('.jpeg') ||
            imageUrl.contains('.png')) {
          await ImageGallerySaver.saveFile(path);
        }

        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        await NotificationService.showNotification(
          title: imageName,
          body: 'Download Complete',
          payload: imageUrl,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();

        // Detailed error handling based on the exception type
        if (e is DioException) {
          // Network or Dio-related error
          showCustomSnackBar(context, 'Download failed. Try again',
              isError: true);
        } else if (e is FileSystemException) {
          // File system error (e.g., saving image)
          showCustomSnackBar(context, 'Saving image failed. Try again',
              isError: true);
        } else {
          // Generic error
          showCustomSnackBar(context, 'An error occurred', isError: true);
        }

        // Log the error for debugging
        print('Error downloading image. Try again');
      }
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
        showCustomSnackBar(context, 'Error sharing event');
        print(e);
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
      BuildContext context,
      String iconAssetPath,
      String label, {
      String? value,
      Widget? customWidget,
      VoidCallback? onTap,
    }) {
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
                    customWidget ??
                        Text(
                          value ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildCommentsList() {
      return _comments.isEmpty
          ? const Center(child: Text('No comments yet'))
          : ListView.builder(
              shrinkWrap: true, // Important for nested ListViews
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling in nested ListView
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final formattedTimestamp = DateFormat('MMM d, yyyy - hh:mm a')
                    .format(comment.timestamp);
                return ListTile(
                  title: Text(comment.text),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('By ${comment.authorName}'),
                      Text(formattedTimestamp),
                    ],
                  ),
                );
              },
            );
    }

    Widget _buildCommentInput() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(hintText: 'Add a comment'),
              ),
            ),
            IconButton(
              onPressed: () async {
                if (_commentController.text.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final comment = CommentModel(
                      id: '', // Firestore will generate an ID
                      eventId: event.id,
                      authorName: user.displayName ?? 'Anonymous',
                      text: _commentController.text,
                      timestamp: DateTime
                          .now(), // You can use server timestamp as well
                    );
                    await _firestoreService.addCommentToEvent(
                        event.id, comment);
                    _commentController.clear(); // Clear the input field
                    _fetchComments(); // Refresh comments
                  } else {
                    // Handle case where the user is not logged in
                  }
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      );
    }

    void _searchByTag(BuildContext context, String tag) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, tag);
      }

      Navigator.pushNamed(context, '/search', arguments: tag);
    }

    Widget _buildTagsRow(BuildContext context, List<String> tags) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/icons/tags.svg', // Assuming you have a tag icon
              height: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 8.0,
                children: tags.map((tag) {
                  return ActionChip(
                    // Use ActionChip for clickable tags
                    label: Text(tag),
                    backgroundColor: whiteColor,
                    labelStyle: const TextStyle(color: primaryBckgnd),
                    onPressed: () {
                      _searchByTag(context, tag); // Call the search function
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
                          child: GestureDetector(
                            onTap: () {
                              if (user != null) {
                                favoriteProvider.toggleFavorite(event.id);
                              } else {
                                showCustomSnackBar(context,
                                    'Please Login, To use this feature',
                                    isError: true);
                              }
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: greycolor2.withOpacity(0.5),
                              child: Center(
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                  size: 28,
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
                                  // Title and Tags
                                  Text(
                                    event.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: primaryBckgnd),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDetailRow(
                                    context,
                                    'assets/icons/description.svg',
                                    'Description',
                                    value: event.description,
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
                                    value: DateFormat('EEEE, MMM d, yyyy')
                                        .format(event.startdate!),
                                  ),
                                  _buildDetailRow(
                                    context,
                                    'assets/icons/clock.svg',
                                    'Time:',
                                    value: DateFormat('h:mm a')
                                        .format(event.startdate!),
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
                                      value: event.link,
                                      onTap: () async {
                                        final Uri url = Uri.parse(event.link);
                                        if (!await launchUrl(url,
                                            mode: LaunchMode
                                                .externalApplication)) {
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
                                      'Venue:',
                                      value: event.location,
                                    ),
                                  const Divider(
                                    height: 32,
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                  _buildTagsRow(context, event.tags),
                                  // _buildDetailRow(
                                  //   context,
                                  //   'assets/icons/tags.svg',
                                  //   'Tags:',
                                  //   customWidget: Wrap(
                                  //     spacing: 8.0,
                                  //     children: event.tags
                                  //         .map((tag) => Chip(
                                  //               label: Text(tag),
                                  //               backgroundColor: whiteColor,
                                  //             ))
                                  //         .toList(),
                                  //   ),
                                  // ),
                                  const Divider(
                                    height: 32,
                                    thickness: 1,
                                    color: Colors.grey,
                                  ),
                                  // Ratings Section
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    context,
                                    'assets/icons/rating.svg',
                                    'Rating:',
                                    customWidget: Row(
                                      children: [
                                        RatingBar.builder(
                                          initialRating: _userRating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 30,
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) async {
                                            final user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user != null) {
                                              setState(() {
                                                _userRating = rating;
                                              });
                                              await _firestoreService
                                                  .addUserRating(user.uid,
                                                      event.id, rating);
                                              showCustomSnackBar(context,
                                                  'Thanks for rating!'); // Show snackbar
                                            } else {
                                              showCustomSnackBar(context,
                                                  'Please log in to rate this event',
                                                  isError: true);
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        Text('(${event.ratingsCount} ratings)'),
                                      ],
                                    ),
                                  ),
                                  // Comments Section
                                  const SizedBox(height: 15),
                                  Text(
                                    'Comments',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  _buildCommentsList(),
                                  _buildCommentInput(),
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
                                  PhotoViewHeroAttributes(tag: event.id),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
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
      ),
    );
  }
}
