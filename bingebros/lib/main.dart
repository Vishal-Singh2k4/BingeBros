import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => SignInPage(),
        '/usernameSetup': (context) => UsernameSetupPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
