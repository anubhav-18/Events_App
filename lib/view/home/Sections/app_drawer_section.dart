import 'package:flutter/material.dart';
import 'package:cu_events/constants.dart'; // Import your color palette
import 'package:google_fonts/google_fonts.dart'; // Import for custom fonts

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgndColor, // Set background color
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
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
          ), // New
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
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: primaryBckgnd,
      ),
      child: Text(
        'Hey, CUIANS',
        style: GoogleFonts.montserrat(
          // Use your custom font here
          textStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
      BuildContext context, IconData icon, String title, Function() onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
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
