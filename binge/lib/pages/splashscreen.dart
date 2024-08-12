import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:binge/routes/routes.dart';
import 'package:binge/providers/AuthProvider.dart'
    as custom_auth; // Alias for custom AuthProvider
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  Future<void> _startDelay() async {
    await Future.delayed(Duration(milliseconds: 3500));
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final authProvider =
        Provider.of<custom_auth.AuthProvider>(context, listen: false);

    // Check Firebase Auth state
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if username exists in Firestore
      final firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        String? username = userData['username'];

        if (username == null || username.isEmpty) {
          // Redirect to Username Setup page
          Navigator.pushReplacementNamed(context, Routes.usernameSetup);
        } else {
          // User has a username, proceed to Home page
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        // User document does not exist, handle accordingly
        // Redirect to Username Setup page
        Navigator.pushReplacementNamed(context, Routes.usernameSetup);
      }
    } else {
      // User is not logged in, check onboarding status
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

      if (onboardingCompleted) {
        Navigator.pushReplacementNamed(context, Routes.signIn);
      } else {
        Navigator.pushReplacementNamed(context, Routes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Lottie.asset(
          'assets/Animation - 1722392924740.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
