import 'package:flutter/material.dart';
import 'package:binge/pages/home.dart';
import 'package:binge/pages/login_screen.dart';
import 'package:binge/pages/sign_in_page.dart'; // Updated import
import 'package:binge/pages/splashscreen.dart';
import 'package:binge/pages/onboarding.dart';

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signIn = '/signIn';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case signIn: // Updated case
        return MaterialPageRoute(builder: (_) => SignInPage());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
