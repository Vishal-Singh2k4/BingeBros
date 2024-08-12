import 'package:binge/pages/Onboard.dart';
import 'package:binge/pages/Onboarding2.dart';
import 'package:flutter/material.dart';
import 'package:binge/pages/HomePage.dart';
import 'package:binge/pages/SplashScreen.dart';
import 'package:binge/pages/Onboarding2.dart';
import 'package:binge/pages/SignInPage.dart';
import 'package:binge/pages/UsernameSetupPage.dart';
import 'package:binge/pages/MyVerify.dart';
import 'package:binge/pages/SwiperPage.dart';   // Ensure this import is correct
import 'package:binge/pages/LikedPage.dart';    // Ensure this import is correct
import 'package:binge/pages/SettingsPage.dart'; // Updated to import SettingsPage

class Routes {
  static const String home = '/home';
  static const String login = '/login';
  static const String signIn = '/signIn';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String usernameSetup = '/usernameSetup';
  static const String verify = '/verify';
  static const String swiper = '/swiper';
  static const String liked = '/liked';
  static const String settings = '/settings';  // Updated to settings

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
      case swiper:
        return MaterialPageRoute(builder: (_) => SwiperPage());
      case liked:
        return MaterialPageRoute(builder: (_) => LikedPage());
      case Routes.settings:  // Use the correct constant expression
        return MaterialPageRoute(builder: (_) => SettingsPage()); // Ensure SettingsPage is imported correctly
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
