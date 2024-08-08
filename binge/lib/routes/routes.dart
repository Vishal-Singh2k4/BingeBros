import 'package:flutter/material.dart';
import 'package:binge/pages/HomePage.dart';
import 'package:binge/pages/SplashScreen.dart';
import 'package:binge/pages/OnboardingPage.dart';
import 'package:binge/pages/SignInPage.dart';
import 'package:binge/pages/UsernameSetupPage.dart';
import 'package:binge/pages/MyVerify.dart'; // Add this import

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signIn = '/signIn';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String usernameSetup = '/usernameSetup';
  static const String verify = '/verify'; // Add this route

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomePage());
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
      case signIn:
        return MaterialPageRoute(builder: (_) => SignInPage());
      case usernameSetup:
        return MaterialPageRoute(builder: (_) => UsernameSetupPage());
      case verify:
        final String phoneNumber = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => MyVerify(phoneNumber: phoneNumber));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
