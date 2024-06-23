import 'package:cu_events/src/UI/btm_nav_section/favourite.dart';
import 'package:cu_events/src/UI/btm_nav_section/hackathon/hackathon_add.dart';
import 'package:cu_events/src/UI/btm_nav_section/hackathon/hackathon_page.dart';
import 'package:cu_events/src/UI/home/homepage.dart';
import 'package:cu_events/src/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BtmNavBar extends StatefulWidget {
  final int index;
  const BtmNavBar({super.key, this.index = 0});
  @override
  State<BtmNavBar> createState() => _BtmNavBarState();
}

class _BtmNavBarState extends State<BtmNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _btmnavindex = 0;

  void onAnyIndex(int index) {
    setState(() {
      _btmnavindex = index;
    });
  }

  Widget pageCaller(int index) {
    switch (index) {
      case 0:
        {
          return const Homepage();
        }
      case 1:
        {
          return const HackathonsPage();
        }
      case 2:
        {
          return const FavoritePage();
        }
    }
    return const AddHackathonPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: pageCaller(_btmnavindex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          iconSize: 30,
          selectedItemColor: primaryBckgnd,
          unselectedItemColor: Colors.black.withOpacity(0.7),
          selectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          backgroundColor: whiteColor,
          elevation: 8,
          currentIndex: _btmnavindex,
          onTap: (value) {
            setState(() {
              _btmnavindex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
              activeIcon: Icon(
                Icons.home_filled,
              ),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_outlined), label: 'Hackathon',activeIcon: Icon(Icons.emoji_events,),),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart), label: 'WishList',activeIcon: Icon(CupertinoIcons.heart_fill,),),
            BottomNavigationBarItem(
                icon: Icon(Icons.forum_outlined), label: 'Network',activeIcon: Icon(Icons.forum,),),
          ]),
    );
  }
}
