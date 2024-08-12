import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:binge/routes/routes.dart';
import 'package:binge/providers/AuthProvider.dart'
    as custom_auth; // Alias for custom AuthProvider

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
      // User is logged in
      Navigator.pushReplacementNamed(context, Routes.home);
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
          'assets/Wa5v8hxVSb.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
