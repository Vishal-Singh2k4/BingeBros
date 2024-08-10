import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:binge/routes/routes.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _currentIndex = 0;

  final List<OnboardPageModel> pages = [
    OnboardPageModel(
      title: "Welcome to BingeBros",
      description: "Your ultimate entertainment hub for movies, games, books, and anime. Explore it all in one place.",
    ),
    OnboardPageModel(
      title: "Discover Movies",
      description: "Browse through a vast collection of movies, from classics to the latest blockbusters.",
    ),
    OnboardPageModel(
      title: "Level Up with Games",
      description: "Immerse yourself in a world of gaming. Find your next favorite game here.",
    ),
    OnboardPageModel(
      title: "Dive into Books",
      description: "From fiction to non-fiction, explore a library of books tailored to your interests.",
    ),
    OnboardPageModel(
      title: "Anime for All",
      description: "Whether you're a seasoned otaku or new to anime, we've got something for everyone.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Onboarding'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider.builder(
              itemCount: pages.length,
              itemBuilder: (context, index, realIndex) {
                final page = pages[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              page.title,
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.0),
                            Text(
                              page.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: 500.0,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                enableInfiniteScroll: false, // Disable infinite scrolling
              ),
            ),
          ),
          if (_currentIndex == pages.length - 1)
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboardingCompleted', true);
                      Navigator.pushReplacementNamed(context, Routes.signIn);
                    },
                    child: Text('Get Started'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OnboardPageModel {
  final String title;
  final String description;

  OnboardPageModel({
    required this.title,
    required this.description,
  });
}
