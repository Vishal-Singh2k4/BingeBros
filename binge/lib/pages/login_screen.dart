import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binge/providers/auth_provider.dart';
import 'package:binge/routes/routes.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).login();
                Navigator.pushReplacementNamed(
                    context, Routes.home); // Navigate to home page
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, Routes.signIn); // Navigate to sign-in page
              },
              child: Text('Go to Sign-In Page'),
            ),
          ],
        ),
      ),
    );
  }
}
