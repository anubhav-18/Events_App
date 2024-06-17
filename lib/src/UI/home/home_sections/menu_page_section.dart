import 'dart:io';

import 'package:cu_events/src/UI/home/homepage.dart';
import 'package:cu_events/src/UI/login/logout_dialog.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/provider/favourite_provider.dart';
import 'package:cu_events/src/reusable_widget/custom_listtile.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatefulWidget {
  final UserModel? updatedUser;
  const MenuPage({
    super.key,
    this.updatedUser,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  bool _isLoading = true;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = widget.updatedUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final _auth = Provider.of<AuthService>(context, listen: false);
    final user = _auth.user;
    final FirestoreService _firestoreService = FirestoreService();

    try {
      final userData = await user.first;
      if (userData != null) {
        // Check if userData is not null
        _userModel = await _firestoreService.getUserDetails(userData.uid);
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    final AuthService _auth = Provider.of<AuthService>(context);
    final user = _auth.user;
    return StreamBuilder<User?>(
      stream: user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is logged in, fetch user details from Firestore
          return FutureBuilder<UserModel?>(
            future: FirestoreService().getUserDetails(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                // Show shimmer while fetching user details
                return _buildDrawerHeaderShimmer();
              } else if (userSnapshot.hasError) {
                // Show error message
                return ListTile(
                  title: Text('Error: ${userSnapshot.error}'),
                );
              } else {
                final userModel = userSnapshot.data;
                return _buildLoggedInHeader(context, userModel);
              }
            },
          );
        } else {
          // User is not logged in, show login button
          return _buildLoggedOutHeader(context);
        }
      },
    );
  }

  Widget _buildLoggedOutHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: primaryBckgnd,
            child: SvgPicture.asset(
              'assets/icons/profile.svg',
              width: 35,
              height: 35,
              colorFilter: const ColorFilter.mode(whiteColor, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, CUIANS',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              width: double.infinity, // Adjust width as needed
              height: 40.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 120.0,
              height: 20.0,
              color: Colors.white,
            ),
            const SizedBox(height: 4.0),
            Container(
              width: 180.0,
              height: 16.0,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInHeader(BuildContext context, UserModel? userModel) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding:
          const EdgeInsets.only(top: 24.0, left: 16, bottom: 24, right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_userModel != null && userModel?.profilePicture != null) ...[
            CircleAvatar(
              radius: 35,
              backgroundColor: primaryBckgnd,
              backgroundImage: NetworkImage(_userModel?.profilePicture ?? ''),
              child: Text(
                userModel?.firstName[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ] else ...[
            CircleAvatar(
              radius: 35,
              backgroundColor: primaryBckgnd,
              child: Text(
                userModel?.firstName[0].toUpperCase() ?? 'U',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel?.firstName ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  userModel?.email ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double uniformPadding = 8.0;
    final AuthService _auth = Provider.of<AuthService>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: AnnotatedRegion(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.dark, // Dark icons for status bar
          ),
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: _SliverAppBarDelegate(
                  minHeight: _auth.currentUser != null ? 190 : 185.0,
                  maxHeight: _auth.currentUser != null ? 190 : 185.0,
                  child: Container(
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.black),
                              onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Homepage(
                                    updatedUser: _userModel,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        _buildProfileHeader(context),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(uniformPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      CustomListTileGroup(
                        tiles: [
                          if (_auth.currentUser != null) ...[
                            menuListTile(
                              'Your Profile',
                              () {
                                Navigator.pushNamed(context, '/yourprofile');
                              },
                              'assets/icons/categories/profile.svg',
                            ),
                          ] else ...[
                            menuListTile(
                              'Login',
                              () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (Route<dynamic> route) => false,
                                );
                              },
                              'assets/icons/categories/login.svg',
                            )
                          ]
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        tiles: [
                          menuListTile(
                            'Rate Us',
                            () async {
                              if (Platform.isAndroid) {
                                await launchUrl(
                                  Uri.parse(
                                      "https://play.google.com/store/apps/details?id=com.yourapp.id"),
                                );
                              } else if (Platform.isIOS) {
                                await launchUrl(
                                  Uri.parse(
                                      "https://apps.apple.com/app/idYOUR_APP_ID"),
                                );
                              }
                            },
                            'assets/icons/categories/rateus.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'Discover', // Optional header
                        tiles: [
                          menuListTile(
                            'Home',
                            () => Navigator.of(context).pushNamed('/home'),
                            'assets/icons/categories/home.svg',
                          ),
                          menuListTile(
                            'All Events',
                            () => Navigator.of(context).pushNamed('/allevents'),
                            'assets/icons/categories/all_events.svg',
                          ),
                          menuListTile(
                            'Categories',
                            () => Navigator.of(context).pushNamed('/category'),
                            'assets/icons/categories/categories.svg',
                          ),
                          menuListTile(
                            'Favourites',
                            () => Navigator.of(context).pushNamed('/favourite'),
                            'assets/icons/categories/heart.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'Support', // Optional header
                        tiles: [
                          // menuListTile(
                          //   'Contact Us',
                          //   () {},
                          //   'assets/icons/categories/contact_us.svg',
                          // ),
                          menuListTile(
                            'Feedback',
                            () => Navigator.of(context).pushNamed('/feedback'),
                            'assets/icons/categories/feedback.svg',
                          ),
                          menuListTile(
                            'FAQ',
                            () => Navigator.of(context).pushNamed('/faq'),
                            'assets/icons/categories/faq.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'Legal & About', // Optional header
                        tiles: [
                          menuListTile(
                            'About',
                            () => Navigator.of(context).pushNamed('/aboutus'),
                            'assets/icons/categories/about_us.svg',
                          ),
                          menuListTile(
                            'Privacy & Policy',
                            () => Navigator.of(context).pushNamed('/privacy'),
                            'assets/icons/categories/privacy_policy.svg',
                          ),
                          menuListTile(
                            'Terms Of Services',
                            () => Navigator.of(context).pushNamed('/tos'),
                            'assets/icons/categories/edit.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'More', // Optional header
                        tiles: [
                          menuListTile(
                            'Settings',
                            () => Navigator.of(context).pushNamed('/settings'),
                            'assets/icons/categories/settings.svg',
                          ),
                          menuListTile(
                            'Invite Friends',
                            () => Navigator.of(context).pushNamed('/invite'),
                            'assets/icons/categories/edit.svg',
                          ),
                          if (_auth.currentUser != null) ...[
                            menuListTile(
                              'Log Out',
                              () {
                                showDialog(
                                  context: context,
                                  builder: (context) => LogoutDialog(
                                    onLogout: () async {
                                      await _auth.signOut();
                                      FirebaseAuth.instance
                                          .authStateChanges()
                                          .listen((User? user) {
                                        if (user == null) {
                                          // User logged out
                                          // Reset favorite provider or clear favorites
                                          favoriteProvider.clearFavorites();
                                        } else {
                                          // User logged in
                                          favoriteProvider.updateUser(user);
                                        }
                                      });
                                      showCustomSnackBar(
                                          context, 'Successfully Logged Out');
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                  ),
                                );
                              },
                              'assets/icons/categories/logout.svg',
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile menuListTile(String title, Function() onTap, String imgPath) {
    return ListTile(
      tileColor: whiteColor,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 17,
        backgroundColor: Colors.grey.withOpacity(0.2),
        child: SvgPicture.asset(
          imgPath,
          width: 20,
          height: 20,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcIn),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
