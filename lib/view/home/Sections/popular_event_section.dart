import 'package:carousel_slider/carousel_slider.dart';
import 'package:cu_events/constants.dart';
import 'package:cu_events/models/event_model.dart';
import 'package:cu_events/reusable_widget/cachedImage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PopularEventsCarousel extends StatefulWidget {
  final List<EventModel> popularEvents;
  final bool isLoading;

  const PopularEventsCarousel({
    Key? key,
    required this.popularEvents,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<PopularEventsCarousel> createState() => _PopularEventsCarouselState();
}

class _PopularEventsCarouselState extends State<PopularEventsCarousel> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Events',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        widget.isLoading
            ? _buildShimmerPlaceholder()
            // const Center(
            //     child: SpinKitChasingDots(
            //       color: textColor,
            //     ),
            //   )
            : widget.popularEvents.isNotEmpty
                ? CarouselSlider(
                    items: widget.popularEvents.map((event) {
                      return _buildPopularEventCard(context, event);
                    }).toList(),
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.3,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
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
        const SizedBox(height: 10),
        Center(
          child: AnimatedSmoothIndicator(
            activeIndex: _currentIndex,
            count: widget.popularEvents.length,
            effect: const ScrollingDotsEffect(
              activeDotColor: primaryBckgnd,
              dotColor: Colors.grey,
              dotHeight: 8,
              dotWidth: 8,
            ),
            onDotClicked: (index) {
              _carouselController.animateToPage(index);
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget _buildPopularEventCard(BuildContext context, EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/event_details', arguments: event);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            CachedImage(
              imageUrl: event.imageUrl,
              width: double.infinity,
              height: double.infinity,
              boxFit: BoxFit.cover,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d').format(event.startdate!)} - ${DateFormat('MMM d').format(event.enddate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
