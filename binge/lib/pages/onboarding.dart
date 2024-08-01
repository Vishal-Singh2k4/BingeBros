import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:binge/routes/routes.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboardingCompleted', true);
            Navigator.pushReplacementNamed(
                context, Routes.login); // Navigate to login page
          },
          child: Text('Complete Onboarding'),
        ),
      ),
    );
  }
}
