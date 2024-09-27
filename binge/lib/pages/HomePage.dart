import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:binge/notifiers/category_notifier.dart';
import 'package:binge/pages/games/GamesHomePage.dart';
import 'package:binge/pages/games/GamesSwiperPage.dart';
import 'package:binge/pages/games/GamesLikedPage.dart';
import 'package:binge/pages/books/BooksHomePage.dart';
import 'package:binge/pages/books/BooksSwiperPage.dart';
import 'package:binge/pages/books/BooksLikedPage.dart';
import 'package:binge/pages/movies/MoviesHomePage.dart';
import 'package:binge/pages/movies/MoviesSwiperPage.dart';
import 'package:binge/pages/movies/MoviesLikedPage.dart';
import 'package:binge/pages/anime/AnimeHomePage.dart';
import 'package:binge/pages/anime/AnimeSwiperPage.dart';
import 'package:binge/pages/anime/AnimeLikedPage.dart';
import 'package:binge/pages/SettingsPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Update the _pages list dynamically based on the selected category
  List<Widget> _getPages(String category) {
    switch (category) {
      case 'Games':
        return [
          GamesHomePageContent(),
          GamesSwiperPage(),
          GamesLikedPage(),
          SettingsPage(),
        ];
      case 'Books':
        return [
          BooksHomePageContent(),
          BooksSwiperPage(),
          BooksLikedPage(),
          SettingsPage(),
        ];
      case 'Movies':
        return [
          MoviesHomePageContent(),
          MoviesSwiperPage(),
          MoviesLikedPage(likedMovies: [],),
          SettingsPage(),
        ];
      case 'Anime':
        return [
          AnimeHomePageContent(),
          AnimeSwiperPage(),
          AnimeLikedPage(),
          SettingsPage(),
        ];
      default:
        return [
          GamesHomePageContent(),
          GamesSwiperPage(),
          GamesLikedPage(),
          SettingsPage(),
        ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        return false;
      },
      child: Consumer<CategoryNotifier>(
        builder: (context, categoryNotifier, _) {
          return Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _getPages(categoryNotifier
                  .selectedCategory), // Get the pages based on the selected category
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '', // Remove text label
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.play_circle_fill),
                  label: '', // Remove text label
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark),
                  label: '', // Remove text label
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings), // Updated icon to settings
                  label: '', // Remove text label
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xFF9166FF), // Highlighted item color
              unselectedItemColor: Colors.grey, // Non-highlighted item color
              backgroundColor: Colors.black, // Black background color
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedIconTheme:
                  IconThemeData(size: 35), // Increase icon size for selected
              unselectedIconTheme:
                  IconThemeData(size: 30), // Slightly larger for unselected
              elevation: 16, // Elevated to give depth
              showSelectedLabels: false, // Ensure labels are hidden
              showUnselectedLabels: false,
            ),
          );
        },
      ),
    );
  }
}
