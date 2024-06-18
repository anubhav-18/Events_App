import 'package:cu_events/src/controller/category_data.dart';
import 'package:cu_events/src/UI/events/events_page.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/constants.dart';
import 'package:shimmer/shimmer.dart';

class EventCategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final bool isLoading;

  const EventCategorySelector({
    Key? key,
    required this.selectedCategory,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<EventCategorySelector> createState() => _EventCategorySelectorState();
}

class _EventCategorySelectorState extends State<EventCategorySelector> {
  final Map<String, List<String>> _categoriesAndSubcategories =
      CategoryData.categoriesAndSubcategories;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Categories',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        widget.isLoading
            ? _buildCategoryShimmer(context)
            : GridView.count(
                crossAxisCount: 2, // Two columns in the grid
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _categoriesAndSubcategories.keys.map((category) {
                  return CategoryGridItem(
                    category: category,
                    textColor: whiteColor,
                    isSelected: category == widget.selectedCategory,
                    onTap: () => _onCategorySelected(category, context),
                  );
                }).toList(),
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(6, (index) {
          // You can change the number of shimmer items (8 in this case)
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  void _onCategorySelected(String category, BuildContext context) async {
    final subcategories = _categoriesAndSubcategories[category];

    // Check if the category has subcategories
    if (subcategories != null && subcategories.isNotEmpty) {
      // If it has subcategories, show a dialog to select one
      String? selectedSubcategory = await showDialog(
        context: context,
        builder: (context) => _buildSubcategoryDialog(category, subcategories),
      );

      // Navigate to the filtered events page with the selected subcategory
      if (selectedSubcategory != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsPage(
                category: category, subcategory: selectedSubcategory),
          ),
        );
      }
    } else {
      // If it doesn't have subcategories, directly navigate to the filtered events page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventsPage(
            category: category,
          ),
        ),
      );
    }
  }

  Widget _buildSubcategoryDialog(String category, List<String> subcategories) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor: Theme.of(context).brightness == Brightness.light
            ? backgndColor
            : darkBckgndColor,
      ),
      child: Dialog(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? backgndColor
            : darkBckgndColor,
        surfaceTintColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.all(20), // Adjust padding from edges of the screen
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: backgndColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$category :',
                style: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).textTheme.headlineMedium
                    : Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: whiteColor),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: subcategories
                      .map((subcategory) =>
                          _buildSubcategoryGridItem(category, subcategory))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryGridItem(String category, String subcategory) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsPage(
              category: category,
              subcategory: subcategory,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: _getBackgroundImageForSubcategory(category, subcategory),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Center(
              child: Text(subcategory,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: whiteColor)),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryGridItem extends StatelessWidget {
  final String category;
  final Color textColor;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryGridItem({
    Key? key,
    required this.category,
    required this.textColor,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: _getBackgroundImageForCategory(category),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: greyColor.withOpacity(0.2),
            width: 0.8,
          ),
          // isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black38, Colors.black26],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                category,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: whiteColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AssetImage _getBackgroundImageForCategory(String category) {
  switch (category) {
    case 'Education':
      return const AssetImage('assets/images/CategoryImages/education.jpg');
    case 'Sports':
      return const AssetImage('assets/images/CategoryImages/sports.jpg');
    case 'Arts & Entertainment':
      return const AssetImage('assets/images/CategoryImages/arts.jpeg');
    case 'Business & Career':
      return const AssetImage('assets/images/CategoryImages/business.jpg');
    case 'Health & Wellness':
      return const AssetImage('assets/images/CategoryImages/health.jpeg');
    case 'Fests':
      return const AssetImage('assets/images/CategoryImages/others.jpg');
    default:
      return const AssetImage('assets/images/CategoryImages/others.jpg');
  }
}

AssetImage _getBackgroundImageForSubcategory(
    String category, String subcategory) {
  switch (category) {
    case 'Education':
      switch (subcategory) {
        case 'Workshop':
          return const AssetImage(
              'assets/images/CategoryImages/EDU_workshop.jpg');
        case 'Seminar':
          return const AssetImage(
              'assets/images/CategoryImages/EDU_seminar.jpg');
        case 'Hackathon':
          return const AssetImage(
              'assets/images/CategoryImages/TECH_hackathon.png');
        case 'Coding Rounds':
          return const AssetImage('assets/images/CategoryImages/tech.jpg');
        default:
          return const AssetImage(
              'assets/images/CategoryImages/EDU_training.png');
      }
    case 'Arts & Entertainment':
      switch (subcategory) {
        case 'Music & Dance':
          return const AssetImage('assets/images/CategoryImages/A_Edance.png');
        case 'Drama & Film':
          return const AssetImage('assets/images/CategoryImages/A_Efilm.jpg');
        default:
          return const AssetImage('assets/images/CategoryImages/A_Edance.png');
      }
    case 'Business & Career':
      switch (subcategory) {
        case 'Networking':
          return const AssetImage(
              'assets/images/CategoryImages/B_Cnetworking.png');
        case 'Job Fair':
          return const AssetImage(
              'assets/images/CategoryImages/B_Cjob fair.jpg');
        case 'Startup Pitch':
          return const AssetImage(
              'assets/images/CategoryImages/B_Cstartup pitch.jpg');
        default:
          return const AssetImage(
              'assets/images/CategoryImages/B_Cstartup pitch.jpg');
      }
    case 'Health & Wellness':
      switch (subcategory) {
        case 'Meditation & Yoga':
          return const AssetImage(
              'assets/images/CategoryImages/H_F_meditation.png');
        case 'Fitness':
          return const AssetImage(
              'assets/images/CategoryImages/H_F_fitness.jpg');
        default:
          return const AssetImage(
              'assets/images/CategoryImages/H_F_meditation.png');
      }
    case 'Fests':
      switch (subcategory) {
        case 'Social':
          return const AssetImage(
              'assets/images/CategoryImages/OTHERS_social.jpg');
        case 'Party':
          return const AssetImage(
              'assets/images/CategoryImages/OTHERS_Party.png');
        case 'Festival':
          return const AssetImage(
              'assets/images/CategoryImages/OTHERS_festival.jpg');
        case 'Cultural':
          return const AssetImage('assets/images/CategoryImages/cultural.jpg');
        default:
          return const AssetImage(
              'assets/images/CategoryImages/OTHERS_festival.jpg');
      }
    default:
      return const AssetImage(
          'assets/images/CategoryImages/OTHERS_festival.jpg');
  }
}
