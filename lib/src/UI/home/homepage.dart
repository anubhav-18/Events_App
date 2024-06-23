import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/src/UI/home/home_sections/ongoing_section.dart';
import 'package:cu_events/src/UI/home/home_sections/feautred_event_section.dart';
import 'package:cu_events/src/UI/home/home_sections/profile_picture.dart';
import 'package:cu_events/src/UI/home/home_sections/recommeded_events.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/UI/home/home_sections/search_view.dart';
import 'package:cu_events/src/UI/home/home_sections/upcoming_event_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Homepage extends StatefulWidget {
  final UserModel? updatedUser;
  const Homepage({
    super.key,
    this.updatedUser,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CarouselController _carouselController = CarouselController();

  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _ongoingEvents = [];
  List<EventModel> _filteredEvents = [];
  List<EventModel> _featuredEvents = [];
  bool _isLoading = true;
  String? _selectedCategory;
  UserModel? _userModel;
  late TextEditingController _firstNameController;
  final AuthService _auth = AuthService();
  String userId = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _userModel = widget.updatedUser;
    _getUserId();
  }

  Future<void> _getUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Set the user ID
      });
    }
  }

  Future<void> _fetchEvents() async {
    try {
      List<EventModel> allEvents = await _firestoreService.getAllEvents();

      _ongoingEvents = allEvents
          .where((event) =>
              event.startdate!.isBefore(DateTime.now()) &&
              event.enddate!.isAfter(DateTime.now()))
          .toList();

      _upcomingEvents = await _firestoreService.getUpcomingEvents();

      // Filter recommended events based on user interests

      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userInterests = (userDoc.data()?['interests'] as List<dynamic>?)
                  ?.cast<String>() ??
              [];

          // Filter ongoing AND upcoming events based on user interests
          _filteredEvents = allEvents
              .where((event) =>
                  event.tags.any((tag) => userInterests.contains(tag)))
              .where((event) => event.startdate!
                  .isAfter(DateTime.now().subtract(const Duration(days: 30))))
              .toList();

          _filteredEvents.sort((a, b) {
            final aScore = _calculateEventScore(a);
            final bScore = _calculateEventScore(b);
            return bScore.compareTo(aScore); // Descending order
          });
        }

        try {
          final user = _auth.currentUser;
          final userInterests = user != null
              ? await _firestoreService.getUserInterests(user.uid)
              : null;

          _featuredEvents =
              await _firestoreService.getFeaturedEvents(userInterests);
        } catch (e) {
          print('Error fetching featured events: $e');
        }
      }
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateEventScore(EventModel event) {
    const clickWeight = 0.5;
    const ratingWeight = 0.3;
    const recencyWeight = 0.2;

    final daysSinceStart =
        DateTime.now().difference(event.startdate!).inDays.toDouble();

    // 1. Normalize Clicks:
    final maxClicks = _filteredEvents.isNotEmpty
        ? _filteredEvents.map((e) => e.clicks).reduce(max)
        : 1; // Max clicks among filtered events or 1 to avoid division by 0
    final normalizedClicks = event.clicks / maxClicks;

    // 2. Normalize Ratings:
    const maxRating = 5.0; // Maximum possible rating
    final normalizedRating = event.rating / maxRating;

    final clickScore = normalizedClicks * clickWeight;
    final ratingScore = normalizedRating * ratingWeight;
    final recencyScore = (30 - daysSinceStart) * recencyWeight;

    return clickScore + ratingScore + recencyScore;
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = _auth.currentUser;

      // final userData = await user.first;
      if (user != null) {
        UserModel? userModel = await _firestoreService.getUserDetails(user.uid);
        if (userModel != null && mounted) {
          setState(() {
            _userModel = userModel;
            _firstNameController =
                TextEditingController(text: userModel.firstName);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshAllData() async {
    await _fetchEvents();
    await _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'CU Events',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontFamily: 'KingsmanDemo', color: Colors.black, fontSize: 36),
          ),
        ),
        backgroundColor: greyColor,
        actions: [
          // Search Button
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0); // Start from bottom
                  const end = Offset.zero; // End at top
                  const curve = Curves.easeInOut; // Animation curve

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ));
            },
          ),
          // Menu
          ProfilePicture(
            updatedUser: _userModel,
          )
        ],
        centerTitle: true,
        elevation: 8,
      ),
      body: RefreshIndicator(
        backgroundColor: whiteColor,
        color: primaryBckgnd,
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          child: Container(
            margin: screenSize > 600 ? AppMargins.large : AppMargins.medium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fetured Events
                FeaturedEventsCarousel(
                  featuredEvents: _featuredEvents,
                  isLoading: _isLoading,
                ),
                // Recommeded Section
                RecommendedEventsList(
                  isLoading: _isLoading,
                  recommededEvents: _filteredEvents,
                  onEventClick: (eventId) async {
                    await _firestoreService.incrementEventClicks(eventId);
                    setState(() {
                      // Update the local event's click count if needed
                      final index =
                          _filteredEvents.indexWhere((e) => e.id == eventId);
                      if (index != -1) {
                        _filteredEvents[index] = _filteredEvents[index]
                            .copyWith(
                                clicks: _filteredEvents[index].clicks + 1);
                      }
                    });
                  },
                ),
                const SizedBox(height: 22),
                // Ongoing
                if (_ongoingEvents.isNotEmpty) ...[
                  OngoingEventsList(
                    isLoading: _isLoading,
                    ongoingEvents: _ongoingEvents,
                  ),
                  const SizedBox(height: 22),
                ],
                // Upcoming Events Section
                UpcomingEventsList(
                  upcomingEvents: _upcomingEvents,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
