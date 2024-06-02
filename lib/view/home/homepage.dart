import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/firestore_service.dart';
import 'package:cu_events/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  List<Event> popularEvents = [];
  bool isLoading = true;

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
        return Event.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
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
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: isLoading
                      ? const Center(
                          child: SpinKitChasingDots(
                            color: headingColor,
                          ),
                        )
                      : popularEvents.isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.35,
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 6),
                                autoPlayAnimationDuration:
                                    const Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enlargeCenterPage: true,
                                aspectRatio: 2.0,
                              ),
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
                                      width: 1000,
                                      boxFit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
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
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Engineering',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        children: [
                          ListTile(
                            title: const Text('Academic Events'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/engineering/academic');
                            },
                          ),
                          ListTile(
                            title: const Text('Cultural Events'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/engineering/cultural');
                            },
                          ),
                          ListTile(
                            title: const Text('NSS/NCC'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/engineering/nss_ncc');
                            },
                          ),
                          ListTile(
                            title: const Text('Others'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/engineering/others');
                            },
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Medical',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        children: [
                          ListTile(
                            title: const Text('Academic Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/medical/academic');
                            },
                          ),
                          ListTile(
                            title: const Text('Cultural Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/medical/cultural');
                            },
                          ),
                          ListTile(
                            title: const Text('NSS/NCC'),
                            onTap: () {
                              Navigator.pushNamed(context, '/medical/nss_ncc');
                            },
                          ),
                          ListTile(
                            title: const Text('Others'),
                            onTap: () {
                              Navigator.pushNamed(context, '/medical/others');
                            },
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Business',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        children: [
                          ListTile(
                            title: const Text('Academic Events'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/business/academic');
                            },
                          ),
                          ListTile(
                            title: const Text('Cultural Events'),
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/business/cultural');
                            },
                          ),
                          ListTile(
                            title: const Text('NSS/NCC'),
                            onTap: () {
                              Navigator.pushNamed(context, '/business/nss_ncc');
                            },
                          ),
                          ListTile(
                            title: const Text('Others'),
                            onTap: () {
                              Navigator.pushNamed(context, '/business/others');
                            },
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Law',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        children: [
                          ListTile(
                            title: const Text('Academic Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/law/academic');
                            },
                          ),
                          ListTile(
                            title: const Text('Cultural Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/law/cultural');
                            },
                          ),
                          ListTile(
                            title: const Text('NSS/NCC'),
                            onTap: () {
                              Navigator.pushNamed(context, '/law/nss_ncc');
                            },
                          ),
                          ListTile(
                            title: const Text('Others'),
                            onTap: () {
                              Navigator.pushNamed(context, '/law/others');
                            },
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          'Others',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        children: [
                          ListTile(
                            title: const Text('Academic Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/other/academic');
                            },
                          ),
                          ListTile(
                            title: const Text('Cultural Events'),
                            onTap: () {
                              Navigator.pushNamed(context, '/other/cultural');
                            },
                          ),
                          ListTile(
                            title: const Text('NSS/NCC'),
                            onTap: () {
                              Navigator.pushNamed(context, '/other/nss_ncc');
                            },
                          ),
                          ListTile(
                            title: const Text('Others'),
                            onTap: () {
                              Navigator.pushNamed(context, '/other/others');
                            },
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
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Container(
                color: barBckgnd,
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Hey, CUIANS',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.policy,
                  size: 30,
                  color: headingColor,
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
                  color: headingColor,
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
      ),
    );
  }
}
