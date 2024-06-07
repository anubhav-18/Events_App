import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';
import 'package:shimmer/shimmer.dart';

class EventCategorySelector extends StatelessWidget {
  final Map<String, List<String>> categoriesAndSubcategories;
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  final bool isLoading;

  const EventCategorySelector({
    Key? key,
    required this.categoriesAndSubcategories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isLoading,
  }) : super(key: key);

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
        isLoading
            ? _buildCategoryShimmer(context)
            : GridView.count(
                crossAxisCount: 2, // Two columns in the grid
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: categoriesAndSubcategories.keys.map((category) {
                  return CategoryGridItem(
                    category: category,
                    backgroundImage: _getBackgroundImageForCategory(category),
                    textColor: textColor,
                    isSelected: category == selectedCategory,
                    onTap: () => onCategorySelected(category),
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
}

class CategoryGridItem extends StatelessWidget {
  final String category;
  final String backgroundImage; // Added backgroundImage property
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
