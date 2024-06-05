import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/view/home/event_categories/event_categories.dart';
import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void _incrementTap() {
    setState(() {
      Navigator.pushNamed(context, '/secret-admin-login');
    });
  }

  List<EventModel> popularEvents = [];
  bool isLoading = true;
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    fetchPopularEvents();
    super.initState();
  }

  Future<void> fetchPopularEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('popular', isEqualTo: true)
        .get();

    setState(() {
      popularEvents = snapshot.docs.map((doc) {
        return EventModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading = false;
    });
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
      body: SingleChildScrollView(
        child: Container(
          margin: screenSize > 600 ? AppMargins.large : AppMargins.medium,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Popular Events',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: isLoading
                    ? const Center(
                        child: SpinKitChasingDots(
                          color: textColor,
                        ),
                      )
                    : popularEvents.isNotEmpty
                        ? Column(
                            children: [
                              CarouselSlider(
                                items: popularEvents.map((event) {
                                  return Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/event_details',
                                            arguments: event);
                                      },
                                      child: CachedImage(
                                        imageUrl: event.imageUrl,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.4,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        boxFit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 6),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              AnimatedSmoothIndicator(
                                activeIndex: _currentIndex,
                                count: popularEvents.length,
                                effect: const ScrollingDotsEffect(
                                  activeDotColor: primaryBckgnd,
                                  activeDotScale: 1.5,
                                  dotColor: Colors.grey,
                                  dotHeight: 8,
                                  dotWidth: 8,
                                ),
                                onDotClicked: (index) {
                                  _carouselController.animateToPage(index);
                                },
                              ),
                            ],
                          )
                        : const Center(
                            child: Text(
                              'There are no popular events',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
              ),
              Text(
                'Events Categories',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              const ExpansionTileRadio(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 1,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              alignment: Alignment.center,
              color: primaryBckgnd,
              padding:
                  const EdgeInsets.only(left: 5, right: 8, top: 22, bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: whiteColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Center(
                    child: Text(
                      'Hey, CUIANS',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.policy,
                size: 30,
                color: iconColor,
              ),
              title: Text(
                ' Privacy Policy ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.call,
                size: 30,
                color: iconColor,
              ),
              title: Text(
                ' Contact US ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
