import 'package:cu_events/src/UI/Client_UI/client_menu_page/client_profile_picture.dart';
import 'package:cu_events/src/UI/User_UI/home/home_sections/search_view.dart';
import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/user_model.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final _auth = AuthService();
  UserModel? _userModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'CU Events',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontFamily: 'KingsmanDemo', color: Colors.black, fontSize: 36),
          ),
        ),
        backgroundColor: greyColor,
        actions: [
          // Search Button
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0); // Start from bottom
                  const end = Offset.zero; // End at top
                  const curve = Curves.easeInOut; // Animation curve

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
          ),
          // Menu 
          const ClientProfilePicture()
        ],
        centerTitle: true,
        elevation: 8,
      ),
      body: Center(
        child: Text(
          'Welcome Client',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
