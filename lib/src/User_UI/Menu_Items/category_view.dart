// import 'package:flutter/material.dart';
// import 'package:cu_events/src/controller/category_data.dart';
// import 'package:cu_events/src/services/firestore_service.dart';
// import 'package:cu_events/src/UI/events/events_page.dart';
// import 'package:cu_events/src/constants.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';

// class CategoriesPage extends StatefulWidget {
//   const CategoriesPage({Key? key}) : super(key: key);

//   @override
//   _CategoriesPageState createState() => _CategoriesPageState();
// }

// class _CategoriesPageState extends State<CategoriesPage> {
//   final FirestoreService _firestoreService = FirestoreService();
//   final Map<String, List<String>> _categoriesAndSubcategories =
//       CategoryData.categoriesAndSubcategories;

//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAllEvents();
//   }

//   Future<void> _fetchAllEvents() async {
//     try {
//       // Simulate a network call
//       await Future.delayed(const Duration(seconds: 2));
//     } catch (e) {
//       print('Error fetching events: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         titleSpacing: 0,
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.black,
//             size: 22,
//           ),
//         ),
//         title: Text(
//           'Event Categories',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         elevation: 0,
//         backgroundColor: greyColor,
//       ),
//       body: _isLoading
//           ? _buildShimmerPlaceholder()
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16.0,
//                   mainAxisSpacing: 16.0,
//                 ),
//                 itemCount: _categoriesAndSubcategories.length,
//                 itemBuilder: (context, index) {
//                   String category =
//                       _categoriesAndSubcategories.keys.elementAt(index);
//                   List<String> subcategories =
//                       _categoriesAndSubcategories[category]!;
//                   return _buildCategoryCard(category, subcategories);
//                 },
//               ),
//             ),
//     );
//   }

//   Widget _buildCategoryCard(String category, List<String> subcategories) {
//     return GestureDetector(
//       onTap: () => _handleCategoryTap(category, subcategories),
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [primaryBckgnd, primaryBckgnd.withOpacity(0.7)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _getIconForCategory(category),
//               const SizedBox(height: 10),
//               Text(
//                 category,
//                 style: GoogleFonts.montserrat(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleCategoryTap(String category, List<String> subcategories) {
//     if (subcategories.isEmpty) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => EventsPage(category: category),
//         ),
//       );
//     } else {
//       showModalBottomSheet(
//         context: context,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         builder: (context) =>
//             _buildSubcategorySheet(context, category, subcategories),
//       );
//     }
//   }

//   Widget _buildSubcategorySheet(
//       BuildContext context, String category, List<String> subcategories) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         const SizedBox(height: 10),
//         Text(
//           'Choose a Subcategory',
//           style:
//               GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const Divider(),
//         ...subcategories.map((subcategory) {
//           return ListTile(
//             title: Text(subcategory, style: GoogleFonts.montserrat()),
//             onTap: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => EventsPage(
//                     category: category,
//                     subcategory: subcategory,
//                   ),
//                 ),
//               );
//             },
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget _getIconForCategory(String category) {
//     String assetName;
//     switch (category) {
//       case 'Education':
//         assetName = 'assets/icons/categories/education.svg';
//         break;
//       case 'Sports':
//         assetName = 'assets/icons/categories/sports.svg';
//         break;
//       case 'Arts & Entertainment':
//         assetName = 'assets/icons/categories/Arts.svg';
//         break;
//       case 'Business & Career':
//         assetName = 'assets/icons/categories/Business.svg';
//         break;
//       case 'Health & Wellness':
//         assetName = 'assets/icons/categories/health.svg';
//         break;
//       case 'Fests':
//         assetName = 'assets/icons/categories/fests.svg';
//         break;
//       default:
//         assetName = 'assets/icons/categories/sports.svg';
//         break;
//     }

//     return SvgPicture.asset(
//       assetName,
//       height: 50,
//       colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//     );
//   }

//   // Shimmer Placeholder
//   Widget _buildShimmerPlaceholder() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.count(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16.0,
//         mainAxisSpacing: 16.0,
//         padding: const EdgeInsets.all(16),
//         children: List.generate(8, (index) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
