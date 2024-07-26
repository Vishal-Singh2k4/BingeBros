import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/sign_in_page.dart';
import 'pages/home_page.dart';
import 'pages/username_setup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BingeBros',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Stream that listens to authentication changes
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          // Check if the user is new or existing
          return FutureBuilder<User?>(
            future: _auth.currentUser?.reload().then((_) => _auth.currentUser),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasData) {
                User? user = userSnapshot.data;
                // If the user is new, navigate to the UsernameSetupPage
                if (user != null && user.displayName == null) {
                  return UsernameSetupPage();
                } else {
                  return HomePage();
                }
              } else {
                return SignInPage();
              }
            },
          );
        }
        return SignInPage();
      },
    );
  }
}
