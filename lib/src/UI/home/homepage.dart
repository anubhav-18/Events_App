import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cu_events/src/UI/home/home_sections/ongoing_section.dart';
import 'package:cu_events/src/UI/home/home_sections/profile_picture.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/UI/home/home_sections/categories_section.dart';
import 'package:cu_events/src/UI/home/home_sections/popular_event_section.dart';
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
  List<EventModel> _popularEvents = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _ongoingEvents = [];
  bool _isLoading = true;
  String? _selectedCategory;
  UserModel? _userModel;
  late TextEditingController _firstNameController;
  File? _image;
  String? _imageUrl;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _userModel = widget.updatedUser;
  }

  Future<void> _fetchEvents() async {
    try {
      List<EventModel> allEvents = await _firestoreService.getAllEvents();

      _ongoingEvents = allEvents
          .where((event) =>
              event.startdate!.isBefore(DateTime.now()) &&
              event.enddate!.isAfter(DateTime.now()))
          .toList();

      _popularEvents = await _firestoreService.getPopularEvents();
      _upcomingEvents = await _firestoreService.getUpcomingEvents();
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
            _imageUrl = userModel.profilePicture;
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
                // Popular Section
                PopularEventsCarousel(
                  popularEvents: _popularEvents,
                  isLoading: _isLoading,
                ),
                // Categories Section
                EventCategorySelector(
                  selectedCategory: _selectedCategory,
                  isLoading: _isLoading,
                ),
                // Ongoing Events
                if (_ongoingEvents.isNotEmpty) ...[
                  OngoingEventsList(
                    isLoading: _isLoading,
                    ongoingEvents: _ongoingEvents,
                  ),
                  const SizedBox(height: 20),
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
