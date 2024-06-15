import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/cachedImage.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class EventsPage extends StatefulWidget {
  final String category;
  final String? subcategory;

  const EventsPage({
    Key? key,
    required this.category,
    this.subcategory,
  }) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _events = [];
  bool _isLoading = true;
  late AnimationController _controller;
  final AuthService authService = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text
        .split(' ')
        .map((word) => toBeginningOfSentenceCase(word))
        .join(' ');
  }

  Future<void> _fetchEvents() async {
    try {
      _events = await _firestoreService.getEventsByCategoryAndSubcategory(
        widget.category,
        widget.subcategory ?? '',
      );
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: greyColor,
      appBar: AppBar(
        title: Text(
          widget.subcategory != null
              ? toBeginningOfSentenceCase(widget.subcategory!)
              : toBeginningOfSentenceCase(widget.category),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchEvents,
          child: _isLoading
              ? _buildShimmerPlaceholder(width, height)
              : _events.isEmpty
                  ? const Center(child: Text('No events found.'))
                  : ListView.builder(
                      itemCount: _events.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _events.length) {
                          return const SizedBox(
                            height: 20,
                          );
                        } else {
                          final event = _events[index];
                          return _buildEventCard(event, width, height);
                        }
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEventCard(
    EventModel event,
    double width,
    double height,
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
            elevation: 2,
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

class AnimatedIconButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onPressed;

  const AnimatedIconButton({
    Key? key,
    required this.isLiked,
    required this.onPressed,
  }) : super(key: key);

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        iconSize: 32,
        icon: Icon(
          widget.isLiked ? Icons.favorite : Icons.favorite_border,
          color: widget.isLiked ? Colors.red : Colors.white,
        ),
        onPressed: () {
          widget.onPressed();
          _controller.forward().then((_) => _controller.reverse());
        },
      ),
    );
  }
}
