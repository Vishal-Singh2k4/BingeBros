import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:binge/routes/routes.dart';

class CardPlanetData {
  final String title;
  final String subtitle;
  final String lottieAsset;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Widget? background;

  CardPlanetData({
    required this.title,
    required this.subtitle,
    required this.lottieAsset,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    this.background,
  });
}

class CardPlanet extends StatelessWidget {
  const CardPlanet({
    required this.data,
    required this.isLastPage,
    Key? key,
  }) : super(key: key);

  final CardPlanetData data;
  final bool isLastPage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (data.background != null) data.background!,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Flexible(
                flex: 20,
                child: Lottie.asset(data.lottieAsset),
              ),
              const Spacer(flex: 1),
              if (isLastPage)
                SizedBox(
                    height: 70), // Add padding above the text for the last page
              Text(
                data.title.toUpperCase(),
                style: TextStyle(
                  color: data.titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                maxLines: 1,
              ),
              const Spacer(flex: 1),
              Text(
                data.subtitle,
                style: TextStyle(
                  color: data.subtitleColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const Spacer(flex: 10),
            ],
          ),
        ),
        if (isLastPage)
          Positioned(
            bottom: 30,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    const Color(0xFFCCBAFA), // Background color of the circle
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_forward, size: 30, color: Colors.white),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingCompleted', true);
                  Navigator.pushReplacementNamed(context, Routes.signIn);
                },
              ),
            ),
          ),
      ],
    );
  }
}
