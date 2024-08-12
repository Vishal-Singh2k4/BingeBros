import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:binge/pages/HomePage.dart';
import 'package:binge/pages/card_planet.dart';
import 'package:concentric_transition/concentric_transition.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({Key? key}) : super(key: key);

  final data = [
    CardPlanetData(
      title: "Welcome to BingeBros!",
      subtitle:
          "Your ultimate entertainment hub for movies, anime, games, and books.",
      lottieAsset: "assets/introduction_animation.json",
      backgroundColor: const Color(0xFF9066FF),
      titleColor: Colors.pink,
      subtitleColor: Colors.white,
      background: LottieBuilder.asset("assets/bg.json"),
    ),
    CardPlanetData(
      title: "Movies",
      subtitle: "Get personalized movie recommendations based on your taste.",
      lottieAsset: "assets/movie_animation.json",
      backgroundColor: const Color(0xFFCCBAFA), // Hexadecimal color for #CCBAFA
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        colors: data.map((e) => e.backgroundColor).toList(),
        itemCount: data.length,
        itemBuilder: (int index) {
          // Determine if the current page is the last page
          bool isLastPage = index == data.length - 1;
          return CardPlanet(data: data[index], isLastPage: isLastPage);
        },
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
      ),
    );
  }
}
