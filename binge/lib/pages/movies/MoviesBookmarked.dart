import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import your Movie model

class MoviesBookmarked extends StatefulWidget {
  final List<Movie> bookmarkedMovies;

  MoviesBookmarked({required this.bookmarkedMovies});

  @override
  _MoviesBookmarkedState createState() => _MoviesBookmarkedState();
}

class _MoviesBookmarkedState extends State<MoviesBookmarked> {
  // Track which movies are bookmarked using a Set
  Set<int> bookmarkedMovies = {};
  // Track which movies are marked as completed using a Set
  Set<int> completedMovies = {};

  // Method to clear all liked movies and bookmarked movies
  void _clearSelection() {
    setState(() {
      bookmarkedMovies.clear();
      widget.bookmarkedMovies.clear(); // Clear the liked movies list
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
      widget.bookmarkedMovies.removeAt(index);
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
        title: Text("Bookmarked movies"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearSelection, // Clear selection on pressed
          ),
        ],
      ),
      body: widget.bookmarkedMovies.isEmpty
          ? Center(child: Text("No bookmarked movies"))
          : ListView.builder(
              itemCount: widget.bookmarkedMovies.length,
              itemBuilder: (context, index) {
                final movie = widget.bookmarkedMovies[index];
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
    );
  }
}
