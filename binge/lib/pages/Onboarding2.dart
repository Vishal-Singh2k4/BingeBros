import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedOnboardingScreen extends StatefulWidget {
  const AnimatedOnboardingScreen({super.key});

  @override
  State<AnimatedOnboardingScreen> createState() =>
      _AnimatedOnboardingScreenState();
}

class _AnimatedOnboardingScreenState extends State<AnimatedOnboardingScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  bool showIntroScreen = true;

  final List<OnboardingItem> onboardingItems = [
    OnboardingItem(
      title: 'Movies',
      subtitle: 'Get personalized movie recommendations based on your taste.',
      lottieAsset: 'assets/movie_animation.json',
    ),
    OnboardingItem(
      title: 'Anime',
      subtitle: 'Discover the latest and greatest anime series tailored for you.',
      lottieAsset: 'assets/anime_animation.json',
    ),
    OnboardingItem(
      title: 'Games',
      subtitle: 'Find the best games that match your gaming style and interests.',
      lottieAsset: 'assets/gaming_animation.json',
    ),
    OnboardingItem(
      title: 'Books',
      subtitle: 'Explore a world of books curated just for you.',
      lottieAsset: 'assets/book_animation.json',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: showIntroScreen
          ? _buildIntroductoryScreen(context, size)
          : Stack(
              children: [
                // Lottie animation from asset positioned just above the text
                Positioned(
                  top: size.height * 0.25, // Pushed further down
                  left: 0,
                  right: 0,
                  child: Lottie.asset(
                    onboardingItems[currentIndex].lottieAsset,
                    width: size.width / 1.5,  // Increased size
                    height: size.height / 3,  // Increased height
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
                // Scrolling content
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 270,
                    child: Column(
                      children: [
                        Flexible(
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: onboardingItems.length,
                            itemBuilder: (context, index) {
                              final items = onboardingItems[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    items.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20), // Adjusted gap
                                  Text(
                                    items.subtitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              );
                            },
                            onPageChanged: (value) {
                              setState(() {
                                currentIndex = value;
                              });
                            },
                          ),
                        ),
                        // Dot indicator
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int index = 0;
                                index < onboardingItems.length;
                                index++)
                              dotIndicator(isSelected: index == currentIndex),
                          ],
                        ),
                        const SizedBox(height: 30), // Adjusted bottom spacing
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: showIntroScreen
          ? null
          : FloatingActionButton(
              onPressed: () {
                if (currentIndex < onboardingItems.length - 1) {
                  pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.linear);
                } else {
                  // Logic to skip or finish the onboarding process
                  // For example, navigate to the home screen
                }
              },
              elevation: 0,
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_forward_ios, color: Colors.black),
            ),
    );
  }

  Widget dotIndicator({required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: AnimatedContainer(
        duration: const Duration(microseconds: 500),
        height: isSelected ? 8 : 6,
        width: isSelected ? 8 : 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.black26,
        ),
      ),
    );
  }

  Widget _buildIntroductoryScreen(BuildContext context, Size size) {
    return Stack(
      children: [
        // Lottie animation for the introductory screen
        Positioned(
          top: size.height * 0.25, // Same position as other screens
          left: 0,
          right: 0,
          child: Lottie.asset(
            'assets/introduction_animation.json', // Lottie animation file for intro screen
            width: size.width / 1.5,
            height: size.height / 3,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.55), // Adjusted for positioning below animation
              const Text(
                'Welcome to BingeBros!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Your ultimate entertainment hub for movies, anime, games, and books.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showIntroScreen = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String lottieAsset;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
  });
}
