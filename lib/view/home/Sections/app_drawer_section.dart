import 'dart:io';
import 'package:cu_events/controller/auth_service.dart';
import 'package:cu_events/models/user_model.dart';
import 'package:cu_events/reusable_widget/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cu_events/controller/firestore_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = Provider.of<AuthService>(context, listen: false);
    final FirestoreService _firestoreService = FirestoreService();

    return Drawer(
      backgroundColor: backgndColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<User?>(
            stream: _auth.user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 180,
                  color: primaryBckgnd,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: whiteColor,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                // User is logged in, fetch user details from Firestore
                return FutureBuilder<UserModel?>(
                  future: _firestoreService.getUserDetails(snapshot.data!.uid),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // Show a loading indicator or placeholder
                      return Container(
                        height: 180,
                        color: primaryBckgnd,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: whiteColor,
                          ),
                        ),
                      );
                    } else if (userSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${userSnapshot.error}'),
                      );
                    } else {
                      final userModel = userSnapshot.data;
                      final user = snapshot.data!;
                      String? name = user.displayName;
                      List<String>? nameParts = name?.split(" ");
                      String firstName =
                          (nameParts != null && nameParts.isNotEmpty)
                              ? nameParts.first
                              : 'User';
                      return _buildDrawerHeaderLoggedIN(
                        context,
                        userModel?.firstName ?? firstName,
                        userModel?.email ?? user.email ?? '',
                      );
                    }
                  },
                );
              } else {
                // User is not logged in, show logo with text
                return _buildDrawerHeaderLoggedOUT(context);
              }
            },
          ),
          _buildDrawerTile(
            context,
            Icons.home,
            'Home',
            () => Navigator.of(context).pushNamed('/home'),
          ),
          _buildDrawerTile(
            context,
            Icons.event,
            'All Events',
            () => Navigator.of(context).pushNamed('/allevents'),
          ),
          _buildDrawerTile(
            context,
            Icons.category,
            'Categories',
            () => Navigator.of(context).pushNamed('/category'),
          ), // New
          const Divider(color: Colors.grey, height: 1), // Add a divider
          _buildDrawerTile(
            context,
            Icons.info,
            'About Us',
            () => Navigator.of(context).pushNamed('/aboutus'),
          ), // New
          _buildDrawerTile(
            context,
            Icons.feedback,
            'Feedback',
            () => Navigator.of(context).pushNamed('/feedback'),
          ), // New
          _buildDrawerTile(
            context,
            Icons.settings,
            'Settings',
            () => Navigator.of(context).pushNamed('/home'),
          ),
          _buildDrawerTile(
            context,
            Icons.star_rate,
            'Rate Us',
            () async {
              if (Platform.isAndroid) {
                await launchUrl(
                  Uri.parse(
                      "https://play.google.com/store/apps/details?id=com.yourapp.id"),
                );
              } else if (Platform.isIOS) {
                await launchUrl(
                  Uri.parse("https://apps.apple.com/app/idYOUR_APP_ID"),
                );
              }
            },
          ),
          const Divider(color: Colors.grey, height: 1),
          _buildDrawerTile(
            context,
            Icons.policy,
            'Privacy Policy',
            () => Navigator.of(context).pushNamed('/home'),
          ),
          _buildDrawerTile(
            context,
            Icons.call,
            'Contact Us',
            () => Navigator.of(context).pushNamed('/home'),
          ),
          // Logout Tile
          if (_auth.currentUser != null)
            _buildDrawerTile(
              context,
              Icons.logout,
              'Log Out',
              () async {
                await _auth.signOut();
                showCustomSnackBar(context, 'Successfully Logged Out');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            )
          else
            _buildDrawerTile(
              context,
              Icons.login,
              'Log In',
              () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeaderLoggedIN(
      BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.only(top: 10,bottom: 5,left: 10,right: 10),
      height: 180,
      color: primaryBckgnd,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    child: Image.asset(
                      'assets/icons/logo/cuevents.png',
                      height: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hey, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    textStyle:
                        Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeaderLoggedOUT(BuildContext context) {
    return Container(
      height: 180,
      color: primaryBckgnd,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/icons/logo/cuevents.png',
                    height: 80,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hey, CUIANS',
                  style: GoogleFonts.montserrat(
                    textStyle:
                        Theme.of(context).textTheme.headlineMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTile(
      BuildContext context, IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: textColor,
            ),
      ),
      onTap: onTap,
    );
  }
}
