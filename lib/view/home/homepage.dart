import 'package:carousel_slider/carousel_slider.dart';
import 'package:cu_events/firestore_service.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/models/event.dart';
import 'package:cu_events/view/events/events_page.dart';
import 'package:cu_events/view/home/Sections/app_drawer_section.dart';
import 'package:cu_events/view/home/Sections/categories_section.dart';
import 'package:cu_events/view/home/Sections/popular_event_section.dart';
import 'package:cu_events/view/home/Sections/upcoming_event_section.dart';
import 'package:flutter/material.dart';

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
  List<EventModel> _filteredEvents = [];
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
        _filteredEvents = _upcomingEvents;
      });
    }
  }

  // Handle category selection
  void _onCategorySelected(String category) async {
  final subcategories = _categoriesAndSubcategories[category];

  // Check if the category has subcategories
  if (subcategories != null && subcategories.isNotEmpty) {
    // If it has subcategories, show a dialog to select one
    String? selectedSubcategory = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Select Subcategory'),
        children: subcategories.map((subcategory) {
          return SimpleDialogOption(
            child: Text(subcategory),
            onPressed: () {
              Navigator.pop(context, subcategory);
            },
          );
        }).toList(),
      ),
    );

    // Navigate to the filtered events page with the selected subcategory
    if (selectedSubcategory != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EventsPage(category: category, subcategory: selectedSubcategory),
        ),
      );
    }
  } else {
    // If it doesn't have subcategories, directly navigate to the filtered events page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventsPage(category: category,),
      ),
    );
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
          GestureDetector(
            onDoubleTap: _incrementTap,
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Icon(Icons.settings,
                  color: Colors.transparent), // Invisible icon
            ),
          ),
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
                  categoriesAndSubcategories: _categoriesAndSubcategories,
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                // Upcoming Events Section
                UpcomingEventsList(
                  upcomingEvents: _upcomingEvents,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 10),
                // const ExpansionTileRadio(),
                // const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  final Map<String, List<String>> _categoriesAndSubcategories = {
    'Education': ['Workshop', 'Seminar', 'Conference', 'Training'],
    'Sports': [],
    'Cultural': [],
    'Tech': ['Hackathon', 'Coding Competition', 'Webinar', 'Workshop'],
    'Arts & Entertainment': ['Music', 'Dance', 'Drama', 'Film'],
    '  Business & Career ': ['Networking', 'Job Fair', 'Startup Pitch'],
    'Health & Wellness': ['Yoga', 'Meditation', 'Fitness'],
    'Others': ['Social', 'Party', 'Festival'],
  };
}
