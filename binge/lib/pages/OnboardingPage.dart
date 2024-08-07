import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:binge/routes/routes.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Onboarding'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboardingCompleted', true);
            Navigator.pushReplacementNamed(context, Routes.signIn);
          },
          child: Text('Complete Onboarding'),
        ),
      ),
    );
  }
}
