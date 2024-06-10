import 'package:cu_events/view/events/events_page.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Categories',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: textColor,
              ),
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
                    backgroundImage: _getBackgroundImageForCategory(category),
                    textColor: textColor,
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
        children: List.generate(8, (index) {
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

  final Map<String, List<String>> _categoriesAndSubcategories = {
    'Education': ['Workshop', 'Seminar', 'Conference', 'Training'],
    'Sports': [],
    'Cultural': [],
    'Tech': ['Hackathon', 'Coding Competition', 'Webinar', 'Workshop'],
    'Arts & Entertainment': ['Music', 'Dance', 'Drama', 'Film'],
    'Business & Career': ['Networking', 'Job Fair', 'Startup Pitch'],
    'Health & Wellness': ['Yoga', 'Meditation', 'Fitness'],
    'Others': ['Social', 'Party', 'Festival'],
  };

  Dialog _buildSubcategoryDialog(String category, List<String> subcategories) {
  return Dialog(
    backgroundColor: Colors.transparent, // Transparent background
    insetPadding: const EdgeInsets.all(20), // Adjust padding from edges of the screen
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
            style: Theme.of(context).textTheme.headlineMedium,
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
            image: NetworkImage(
              _getBackgroundImageForSubcategory(category, subcategory),
            ), // Background image for subcategory
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
        child: Center(
          child: Text(
            subcategory,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

class CategoryGridItem extends StatelessWidget {
  final String category;
  final String backgroundImage;
  final Color textColor;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryGridItem({
    Key? key,
    required this.category,
    required this.backgroundImage,
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
            image: NetworkImage(backgroundImage), // Load image from URL
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Center(
          child: Text(category,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }
}

String _getBackgroundImageForCategory(String category) {
  switch (category) {
    case 'Education':
      return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40'; // Example image URL
    case 'Sports':
      return 'https://images.unsplash.com/photo-1517649763962-0c623066013b';
    case 'Cultural':
      return 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e';
    // ... Add more cases for other categories
    default:
      return 'https://images.unsplash.com/photo-1523275335684-37898b6baf30'; // Default image URL
  }
}

String _getBackgroundImageForSubcategory(String category, String subcategory) {
  switch (category) {
    case 'Education':
      switch (subcategory) {
        case 'Workshop':
          return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40'; // Example image path for Education Workshop
        case 'Seminar':
          return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40';
        // ... add more cases for other subcategories under Education
        default:
          return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40'; // Default for Education category
      }
    case 'Sports':
      return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40'; // Since Sports has no subcategories, return the default
    case 'Cultural':
      return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40';
    // ... add cases for other categories and their subcategories
    default:
      return 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40'; // Overall default image
  }
}
