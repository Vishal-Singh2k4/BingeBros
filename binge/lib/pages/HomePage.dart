import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge/routes/routes.dart';
import 'package:binge/pages/SwiperPage.dart'; // Import your pages
import 'package:binge/pages/LikedPage.dart';   // Import your pages
import 'package:binge/pages/SettingsPage.dart'; // Updated import for Settings page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),   // Assuming this is your existing home content
    SwiperPage(),        // Your Swiper page
    LikedPage(),         // Your Liked page
    SettingsPage(),      // Updated to Settings page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '', // Remove text label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: '', // Remove text label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '', // Remove text label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // Updated icon to settings
            label: '', // Remove text label
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purpleAccent, // Highlighted item color
        unselectedItemColor: Colors.grey, // Non-highlighted item color
        backgroundColor: Colors.black, // Black background color
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 35), // Increase icon size for selected
        unselectedIconTheme: IconThemeData(size: 30), // Slightly larger for unselected
        elevation: 16,  // Elevated to give depth
        showSelectedLabels: false,  // Ensure labels are hidden
        showUnselectedLabels: false,
      ),
    );
  }
}

// Assuming HomePageContent is defined elsewhere
class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Welcome to the Home Page Content'),
    );
  }
}
