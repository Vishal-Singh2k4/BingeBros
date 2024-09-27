import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Ensure you have your Movie model imported
import 'MoviesSwiperPage.dart';
class MoviesLikedPage extends StatelessWidget {
  final List<Movie> bookmarkedMovies;

  MoviesLikedPage({required this.bookmarkedMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Movies'),
      ),
      body: bookmarkedMovies.isEmpty
          ? Center(child: Text('No bookmarked movies yet'))
          : ListView.builder(
              itemCount: bookmarkedMovies.length,
              itemBuilder: (context, index) {
                final movie = bookmarkedMovies[index];
                return ListTile(
                  title: Text(movie.title),
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    fit: BoxFit.contain,
                    height: 100,
                    width: 70,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return Center(child: Text('Image not available'));
                    },
                  ),
                  onTap: () {
                    // Handle tap on the bookmarked movie
                  },
                );
              },
            ),
    );
  }
}
