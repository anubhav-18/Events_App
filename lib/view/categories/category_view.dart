import 'package:cu_events/controller/firestore_service.dart';
import 'package:cu_events/view/events/events_page.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirestoreService _firestoreService = FirestoreService();
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllEvents(); 
  }

  Future<void> _fetchAllEvents() async {
    try {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Categories',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBckgnd, // Your color palette
      ),
      body: _isLoading
          ? _buildShimmerPlaceholder()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: _categoriesAndSubcategories.entries
                    .map((entry) => _buildCategoryTile(entry.key, entry.value))
                    .toList(),
              ),
            ),
    );
  }

  Widget _buildCategoryTile(String category, List<String> subcategories) {
    bool hasSubcategories = subcategories.isNotEmpty;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: primaryBckgnd,
          width: 2.0,
        ),
      ),
      child: hasSubcategories
          ? _buildExpandableTile(category, subcategories)
          : _buildNonExpandableTile(category),
    );
  }

  Widget _buildExpandableTile(String category, List<String> subcategories) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // tilePadding: const EdgeInsets.symmetric(
        //     horizontal: 16,
        //     vertical: 8),
        backgroundColor: whiteColor,
        collapsedBackgroundColor: whiteColor,
        title: Text(
          category,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: _getIconForCategory(category),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: primaryBckgnd,
        collapsedIconColor: primaryBckgnd,
        children: subcategories
            .map((subcategory) => ListTile(
                  leading: const Icon(
                    Icons.arrow_right_sharp,
                    color: primaryBckgnd,
                  ),
                  title: Text(
                    subcategory,
                    style: GoogleFonts.montserrat(
                      color: textColor,
                    ),
                  ),
                  onTap: () {
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
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNonExpandableTile(String category) {
    return ListTile(
      selectedTileColor: whiteColor,
      tileColor: whiteColor,
      shape: RoundedRectangleBorder(
        // Add rounded corners to the ListTile
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(
        category,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      leading: _getIconForCategory(category),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: primaryBckgnd,
        size: 17,
      ),
      onTap: () {
        // ... (your navigation logic for non-expandable tile)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventsPage(
              category: category,
            ),
          ),
        );
      },
    );
  }

  Widget _getIconForCategory(String category) {
    switch (category) {
      case 'Education':
        return SvgPicture.asset(
          'assets/icons/categories/education.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Sports':
        return SvgPicture.asset(
          'assets/icons/categories/sports.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Cultural':
        return SvgPicture.asset(
          'assets/icons/categories/education.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Tech':
        return SvgPicture.asset(
          'assets/icons/categories/sports.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Arts & Entertainment':
        return SvgPicture.asset(
          'assets/icons/categories/education.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Business & Career':
        return SvgPicture.asset(
          'assets/icons/categories/sports.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Health & Wellness':
        return SvgPicture.asset(
          'assets/icons/categories/education.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      case 'Other':
        return SvgPicture.asset(
          'assets/icons/categories/sports.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
      default:
        return SvgPicture.asset(
          'assets/icons/categories/sports.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryBckgnd, BlendMode.srcIn),
        );
    }
  }

  void _handleCategoryTap(String category, List<String> subcategories) {
    if (subcategories.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventsPage(category: category),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Choose a Subcategory'),
          children: subcategories.map((subcategory) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, subcategory);
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
              child: Text(subcategory),
            );
          }).toList(),
        ),
      );
    }
  }

  // Shimmer Placeholder
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        padding: const EdgeInsets.all(16),
        children: List.generate(8, (index) {
          return Container(
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
