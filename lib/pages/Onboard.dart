import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:binge/pages/HomePage.dart';
import 'package:binge/pages/card_planet.dart';
import 'package:concentric_transition/concentric_transition.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final data = [
    CardPlanetData(
      title: "Welcome to BingeBros!",
      subtitle:
          "Your ultimate entertainment hub for movies, anime, games, and books.",
      lottieAsset: "assets/introduction_animation.json",
      backgroundColor: const Color(0xFF9066FF),
      titleColor: Colors.black,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/bg.json"),
    ),
    CardPlanetData(
      title: "Movies",
      subtitle: "Get personalized movie recommendations based on your taste.",
      lottieAsset: "assets/movie_animation.json",
      backgroundColor: const Color(0xFFCCBAFA),
      titleColor: Colors.purple,
      subtitleColor: const Color.fromRGBO(0, 10, 56, 1),
      background: LottieBuilder.asset("assets/bg.json"),
    ),
    CardPlanetData(
      title: "Anime",
      subtitle:
          "Discover the latest and greatest anime series tailored for you.",
      lottieAsset: "assets/anime_animation.json",
      backgroundColor: const Color(0xFF9066FF),
      titleColor: Colors.yellow,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/bg.json"),
    ),
    CardPlanetData(
      title: "Books",
      subtitle: "Explore a world of books curated just for you.",
      lottieAsset: "assets/books_animation.json",
      backgroundColor: const Color(0xFFCCBAFA),
      titleColor: Colors.blue,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/bg.json"),
    ),
    CardPlanetData(
      title: "Games",
      subtitle:
          "Find the best games that match your gaming style and interests.",
      lottieAsset: "assets/gaming_animation.json",
      backgroundColor: const Color(0xFF9066FF),
      titleColor: Colors.orange,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/bg.json"),
    ),
  ];

  // Variable to track the current index of the page
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if we are on the first page
        if (_currentIndex == 0) {
          // Do nothing when on the first page
          return false;
        } else {
          // Move to the previous page
          setState(() {
            _currentIndex--;
          });
          return false; // Prevent the default back button behavior
        }
      },
      child: Scaffold(
        body: ConcentricPageView(
          colors: data.map((e) => e.backgroundColor).toList(),
          itemCount: data.length,
          onChange: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (int index) {
            // Determine if the current page is the last page
            bool isLastPage = index == data.length - 1;
            return CardPlanet(data: data[index], isLastPage: isLastPage);
          },
        ),
      ),
    );
  }
}
