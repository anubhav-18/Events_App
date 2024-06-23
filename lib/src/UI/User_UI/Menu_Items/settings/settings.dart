import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cu_events/src/UI/User_UI/Menu_Items/settings/reset_password.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/controller/notification.dart';
import 'package:cu_events/src/reusable_widget/custom_snackbar.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  bool _notificationsEnabled = true; // Default to enabled
  final String notificationPrefKey =
      'notificationsEnabled'; // Key for preferences
  late SharedPreferences _prefs;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool(notificationPrefKey) ?? true;
    });
  }

  Future<void> _setNotificationPref(bool value) async {
    await _prefs.setBool(notificationPrefKey, value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _deleteAccount() async {
    // Show a confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: whiteColor,
              title: const Text('Delete Account'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel',style: TextStyle(color: primaryBckgnd),),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Delete',style: TextStyle(color: primaryBckgnd),),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if the dialog is dismissed

    if (confirmDelete) {
      try {
        // Get the current user's UID
        final user = _authService.currentUser;
        if (user != null) {
          // Delete user data from Firestore
          await _firestoreService.deleteUserAccount(user.uid);

          // Sign out the user from Firebase Auth
          await _authService.signOut();

          // Navigate to login/registration page or appropriate screen
          // You might want to use Navigator.pushNamedAndRemoveUntil
          // to prevent going back to the SettingsPage after deletion
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login', // Replace with your login/registration route
            (Route<dynamic> route) => false,
          );

          showCustomSnackBar(context, 'Account deleted successfully');
        }
      } catch (e) {
        showCustomSnackBar(context, 'Failed to delete account: $e',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        elevation: 0,
        backgroundColor: greyColor,
      ),
      body: ListView(
        children: <Widget>[
          // Notifications Section
          const SizedBox(
            height: 10,
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            activeColor: whiteColor,
            inactiveThumbColor: whiteColor,
            activeTrackColor: Colors.black.withOpacity(0.6),
            inactiveTrackColor: Colors.black.withOpacity(0.6),
            onChanged: (value) async {
              await _setNotificationPref(value);
              if (value) {
                NotificationService.initialize();
                showCustomSnackBar(context, 'Notification Service is enabled');
              } else {
                AwesomeNotifications().cancelAll();
                showCustomSnackBar(context, 'Notification Service is disabled');
              }
            },
            secondary: const Icon(Icons.notifications),
          ),
          // Change Password
          if (_auth.isSignedInWithEmailAndPassword())
            ListTile(
              leading: SvgPicture.asset('assets/icons/password.svg'),
              title: const Text('Reset Password'),
              onTap: () {
                Navigator.push(
                  // Use context from build method
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordPage(),
                  ),
                );
              },
            ),
          // Delete Account
          if (_auth.currentUser != null)
            ListTile(
              leading: SvgPicture.asset(
                'assets/icons/delete-forever.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
              ),
              title: const Text('Delete Account'),
              onTap: _deleteAccount,
            ),
        ],
      ),
    );
  }
}

class CustomSwitchListTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeBorderColor;

  const CustomSwitchListTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.activeBorderColor = Colors.blue, // Customize the border color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: primaryBckgnd,
      secondary: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: value
                ? activeBorderColor
                : Colors.transparent, // Show border only when active
            width: 2.0, // Customize the border width
          ),
          borderRadius:
              BorderRadius.circular(20.0), // Optional: Rounded corners
        ),
        child: const Icon(Icons.notifications),
      ),
    );
  }
}
