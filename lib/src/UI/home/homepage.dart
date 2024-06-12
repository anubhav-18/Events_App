import 'package:carousel_slider/carousel_slider.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/event_model.dart';
import 'package:cu_events/src/UI/home/Sections/app_drawer_section.dart';
import 'package:cu_events/src/UI/home/Sections/categories_section.dart';
import 'package:cu_events/src/UI/home/Sections/popular_event_section.dart';
import 'package:cu_events/src/UI/home/Sections/search_view.dart';
import 'package:cu_events/src/UI/home/Sections/upcoming_event_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CarouselController _carouselController = CarouselController();

  final FirestoreService _firestoreService = FirestoreService();
  List<EventModel> _popularEvents = [];
  List<EventModel> _upcomingEvents = [];
  // List<EventModel> _filteredEvents = [];
  bool _isLoading = true;
  String? _selectedCategory;

  void _incrementTap() {
    setState(() {
      Navigator.pushNamed(context, '/secret-admin-login');
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      _popularEvents = await _firestoreService.getPopularEvents();
      _upcomingEvents = await _firestoreService.getUpcomingEvents();
    } catch (e) {
      print('Error fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CU EVENTS',
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                whiteColor,
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
          // GestureDetector(
          //   onDoubleTap: _incrementTap,
          //   child: const SizedBox(
          //     width: 50,
          //     height: 50,
          //     child: Icon(Icons.settings,
          //         color: Colors.transparent), // Invisible icon
          //   ),
          // ),
        ],
        centerTitle: true,
        elevation: 8,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEvents,
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
                const SizedBox(height: 20),
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
      drawer: const AppDrawer(),
    );
  }
}
