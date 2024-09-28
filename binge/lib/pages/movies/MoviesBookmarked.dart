import 'package:flutter/material.dart';
import 'package:binge/pages/baseScaffold.dart'; // Use your BaseScaffold class

class MoviesBookmarked extends StatefulWidget {
  @override
  _MoviesBookmarkedState createState() => _MoviesBookmarkedState();
}

class _MoviesBookmarkedState extends State<MoviesBookmarked> {
  List<String> watchlistMovies = [
    "Movie 1",
    "Movie 2",
    "Movie 3"
  ]; // Example data for Watchlist
  List<String> watchedMovies = [
    "Movie 4",
    "Movie 5"
  ]; // Example data for Watched

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        // Ensures space for status bar
        child: DefaultTabController(
          length: 2, // Two tabs: Watchlist and Watched
          child: Column(
            children: [
              // Tab bar to switch between Watchlist and Watched
              TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'Watchlist'),
                  Tab(text: 'Watched'),
                ],
              ),
              // TabBarView to load the respective content based on the selected tab
              Expanded(
                child: TabBarView(
                  children: [
                    // Watchlist tab
                    _buildMoviesList(
                        watchlistMovies, 'No movies in your watchlist'),

                    // Watched tab
                    _buildMoviesList(
                        watchedMovies, 'No movies marked as watched'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build movie list for Watchlist or Watched tabs
  Widget _buildMoviesList(List<String> movies, String emptyMessage) {
    if (movies.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              movies[index],
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      );
    }
  }
}
