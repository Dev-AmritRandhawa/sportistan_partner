import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sportistan_partners/nav_bar/bookings.dart';
import 'package:sportistan_partners/nav_bar/home.dart';
import 'package:sportistan_partners/nav_bar/profile_edit/profile.dart';

class NavHome extends StatefulWidget {
  const NavHome({super.key});

  @override
  State<NavHome> createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {}

  final _widgetOptions = [
    const Home(),
    const Bookings(),
    const Profile(),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomSheet: Container(
          margin: Platform.isIOS
              ? EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 25)
              : const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GNav(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              activeColor: Colors.blueGrey.shade500,
              iconSize: MediaQuery.of(context).size.width / 15,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.height / 50,
                  vertical: MediaQuery.of(context).size.height / 50),
              duration: const Duration(milliseconds: 300),
              gap: MediaQuery.of(context).size.height / 50,
              color: Colors.grey.shade500,
              tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.library_books,
                  text: 'Bookings',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
        body: _widgetOptions.elementAt(_selectedIndex));
  }
}
