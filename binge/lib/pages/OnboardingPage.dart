import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(BingeBrosApp(isOnboardingComplete: isOnboardingComplete));
}

class BingeBrosApp extends StatelessWidget {
  final bool isOnboardingComplete;

  BingeBrosApp({required this.isOnboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isOnboardingComplete ? '/main' : '/onboarding',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          buildOnboardingPage(
            context,
            'Gaming',
            'Get personalized game recommendations.',
            'assets/gaming_animation.json',
          ),
          buildOnboardingPage(
            context,
            'Anime',
            'Find the best anime for you.',
            'assets/anime_animation.json',
          ),
          buildOnboardingPage(
            context,
            'Books',
            'Discover books you\'ll love.',
            'assets/books_animation.json',
          ),
          buildOnboardingPage(
            context,
            'Get Started',
            'Join BingeBros now!',
            'assets/heart_animation.json',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildOnboardingPage(BuildContext context, String title, String description, String animationPath, {bool isLast = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(animationPath, height: 300),
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        SizedBox(height: 40),
        if (isLast)
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_complete', true);

              // Navigate to main screen
              Navigator.of(context).pushReplacementNamed('/main');
            },
            child: Text('Get Started'),
          ),
      ],
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BingeBros'),
      ),
      body: Center(
        child: Text('Welcome to BingeBros!'),
      ),
    );
  }
}
