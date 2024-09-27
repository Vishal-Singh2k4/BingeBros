import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import your Movie model
import 'package:binge/pages/movies/MoviesBookmarked.dart';

class MoviesLikedPage extends StatefulWidget {
  final List<Movie> likedMovies;

  MoviesLikedPage({required this.likedMovies});

  @override
  _MoviesLikedPageState createState() => _MoviesLikedPageState();
}

class _MoviesLikedPageState extends State<MoviesLikedPage> {
  // Track which movies are bookmarked using a Set
  Set<int> bookmarkedMovies = {};
  // Track which movies are marked as completed using a Set
  Set<int> completedMovies = {};

  // Method to clear all liked movies and bookmarked movies
  void _clearSelection() {
    setState(() {
      bookmarkedMovies.clear();
      widget.likedMovies.clear(); // Clear the liked movies list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All liked movies have been cleared"),
        duration: Duration(seconds: 1), // Set duration to 1 second
      ),
    );
  }

  // Method to delete a movie from the list
  void _deleteMovie(int index) {
    setState(() {
      widget.likedMovies.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Movie has been deleted"),
        duration: Duration(seconds: 1), // Set duration to 1 second
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liked Movies"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearSelection, // Clear selection on pressed
          ),
        ],
      ),
      body: widget.likedMovies.isEmpty
          ? Center(child: Text("No liked movies"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.likedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = widget.likedMovies[index];
                      final isBookmarked = bookmarkedMovies.contains(movie.id);
                      final isCompleted = completedMovies.contains(movie.id);

                      return ListTile(
                        title: Text(
                          movie.title,
                          style: TextStyle(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none, // Strike out if completed
                          ),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : null, // Change color to green if completed
                          ),
                          onPressed: () {
                            setState(() {
                              if (isCompleted) {
                                completedMovies.remove(movie.id); // Unmark as completed
                              } else {
                                completedMovies.add(movie.id); // Mark as completed
                              }
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? Color(0xFF9166FF) : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isBookmarked) {
                                    bookmarkedMovies.remove(movie.id); // Unbookmark movie
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${movie.title} has been removed from your watchlist'),
                                        duration: Duration(seconds: 1), // Set duration to 1 second
                                      ),
                                    );
                                  } else {
                                    bookmarkedMovies.add(movie.id); // Bookmark movie
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${movie.title} has been added to your watchlist'),
                                        duration: Duration(seconds: 1), // Set duration to 1 second
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteMovie(index); // Delete movie from the list
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the MoviesBookmarked page with the bookmarked movies
                      final bookmarkedMovieList = widget.likedMovies
                          .where((movie) => bookmarkedMovies.contains(movie.id))
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoviesBookmarked(
                            bookmarkedMovies: bookmarkedMovieList,
                          ),
                        ),
                      );
                    },
                    child: Text("Open Watchlist"),
                  ),
                ),
              ],
            ),
    );
  }
}
