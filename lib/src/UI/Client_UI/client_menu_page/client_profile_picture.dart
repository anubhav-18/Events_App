import 'package:cu_events/src/UI/Client_UI/client_menu_page.dart';
import 'package:cu_events/src/UI/User_UI/home/home_sections/menu_page_section.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/client_model.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

class ClientProfilePicture extends StatefulWidget {
  final ClientModel? updatedClient;
  const ClientProfilePicture({Key? key, this.updatedClient}) : super(key: key);

  @override
  State<ClientProfilePicture> createState() => _ClientProfilePictureState();
}

class _ClientProfilePictureState extends State<ClientProfilePicture> {
  bool _isLoading = true;
  ClientModel? _clientModel;
  TextEditingController _nameController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchClientDetails();
    _clientModel = widget.updatedClient;
  }

  Future<void> _fetchClientDetails() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        ClientModel? clientModel =
            await _firestoreService.getClientDetails(user.uid);
        if (clientModel != null && mounted) {
          setState(() {
            _clientModel = clientModel;
            _nameController = TextEditingController(text: clientModel.name);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Handle errors here (e.g., show error message)
      print('Error fetching client details: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.user;
    return StreamBuilder<User?>(
      stream: user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User is logged in, fetch client details from Firestore
          return FutureBuilder<ClientModel?>(
            future: _firestoreService.getClientDetails(snapshot.data!.uid),
            builder: (context, clientSnapshot) {
              if (clientSnapshot.connectionState == ConnectionState.waiting) {
                // Show shimmer while fetching client details
                return _profileShimmer();
              } else if (clientSnapshot.hasError) {
                // Show error message
                return ListTile(
                  title: Text('Error: ${clientSnapshot.error}'),
                );
              } else {
                final clientModel = clientSnapshot.data;
                return _profilePicture(context, clientModel);
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

  Widget _profilePicture(BuildContext context, ClientModel? clientModel) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ClientMenuPage(),
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
            _nameController.text.isNotEmpty
                ? _nameController.text[0].toUpperCase()
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
