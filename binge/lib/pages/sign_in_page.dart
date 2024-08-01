import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binge/providers/auth_provider.dart';
import 'package:binge/routes/routes.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Log in the user and navigate to the home page
                await Provider.of<AuthProvider>(context, listen: false).login();
                Navigator.pushReplacementNamed(context, Routes.home);
              },
              child: Text('Sign In and Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
