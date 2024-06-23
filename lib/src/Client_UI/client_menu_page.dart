import 'package:cu_events/src/constants.dart';
import 'package:cu_events/src/models/client_model.dart';
import 'package:cu_events/src/reusable_widget/custom_listtile.dart';
import 'package:cu_events/src/services/auth_service.dart';
import 'package:cu_events/src/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ClientMenuPage extends StatefulWidget {
  final ClientModel? updatedUser;
  const ClientMenuPage({
    Key? key,
    this.updatedUser,
  }) : super(key: key);

  @override
  State<ClientMenuPage> createState() => _ClientMenuPageState();
}

class _ClientMenuPageState extends State<ClientMenuPage> {
  bool _isLoading = true;
  final _auth = AuthService();
  ClientModel? _clientModel;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchClientDetails();
  }

  Future<void> _fetchClientDetails() async {
    final user = _auth.user;

    try {
      final userData = await user.first;
      if (userData != null) {
        _clientModel = await _firestoreService.getClientDetails(userData.uid);
      }
    } catch (e) {
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
          return FutureBuilder<ClientModel?>(
            future: FirestoreService().getClientDetails(snapshot.data!.uid),
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
                final clientmodel = userSnapshot.data;
                return _buildLoggedInHeader(context, clientmodel);
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
                  'Hey, Client',
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

  Widget _buildLoggedInHeader(BuildContext context, ClientModel? clientModel) {
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
          if (_clientModel != null) ...[
            CircleAvatar(
              radius: 35,
              backgroundColor: primaryBckgnd,
              child: Text(
                clientModel!.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ] else ...[
            CircleAvatar(
              radius: 35,
              backgroundColor: primaryBckgnd,
              child: Text(
                'G',
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
                  clientModel!.name, // Replace with client name
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  clientModel.email, // Replace with client email or other info
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
                  minHeight: 186.0,
                  maxHeight: 186.0,
                  child: Container(
                    color: Colors.grey[50],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.black),
                                onPressed: () => Navigator.pop(context)),
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
                          menuListTile(
                            'Your Profile',
                            () {
                              Navigator.pushNamed(context, '/clientProfile');
                            },
                            'assets/icons/categories/profile.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'Discover',
                        tiles: [
                          // Client-specific menu tiles
                          menuListTile(
                            'Add Event', 
                            () {},
                            'assets/icons/categories/login.svg',
                          ),
                          menuListTile(
                            'Update Event', 
                            () {},
                            'assets/icons/categories/login.svg',
                          ),
                          menuListTile(
                            'Delete Event',
                            () {},
                            'assets/icons/categories/login.svg',
                          ),
                          menuListTile(
                            'Analytics',
                            () {},
                            'assets/icons/categories/login.svg',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CustomListTileGroup(
                        header: 'Support', // Optional header
                        tiles: [
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
                        header: 'More', 
                        tiles: [
                          menuListTile(
                            'Log Out',
                            () => {
                              _auth.signOut(),
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false),
                            },
                            'assets/icons/categories/logout.svg',
                          ),
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
