import 'package:cu_events/src/UI/home/home_sections/menu_page_section.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePicture extends StatefulWidget {
  final UserModel? updatedUser;
  const ProfilePicture({super.key, this.updatedUser});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  bool _isLoading = true;
  UserModel? _userModel;
  TextEditingController _firstNameController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _userModel = widget.updatedUser;
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = _auth.currentUser;

      // final userData = await user.first;
      if (user != null) {
        UserModel? userModel = await _firestoreService.getUserDetails(user.uid);
        if (userModel != null && mounted) {
          setState(() {
            _userModel = userModel;
            _firstNameController =
                TextEditingController(text: userModel.firstName);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching user details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                return _profileShimmer();
              } else if (userSnapshot.hasError) {
                // Show error message
                return ListTile(
                  title: Text('Error: ${userSnapshot.error}'),
                );
              } else {
                final userModel = userSnapshot.data;
                return _profilePicture(context, userModel);
              }
            },
          );
        } else {
          // User is not logged in, show login button
          return _profilePictureLoggedOut(context);
        }
      },
    );
  }

  Widget _profilePicture(BuildContext context, UserModel? userModel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MenuPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ));
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: whiteColor,
          child: Text(
                  _firstNameController.text.isNotEmpty
                      ? _firstNameController.text[0].toUpperCase()
                      : '',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.black),
                ),
        ),
      ),
    );
  }

  Widget _profilePictureLoggedOut(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MenuPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0); // Start from right
            var end = Offset.zero; // End at the default position
            var curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16, left: 8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: whiteColor,
          child: SvgPicture.asset(
            'assets/icons/profile.svg',
            colorFilter: const ColorFilter.mode(
              greycolor2,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        margin: const EdgeInsets.only(right: 16, left: 8),
        child: const CircleAvatar(
          radius: 18,
        ),
      ),
    );
  }
}
