import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import your Movie model
import 'services/api_service.dart'; // Import your API service
import 'package:flutter/services.dart';
import 'package:binge/pages/baseScaffold.dart'; // Import your BaseScaffold

class MoviesLikedPage extends StatefulWidget {
  final List<Movie> likedMovies;

  MoviesLikedPage({required this.likedMovies});

  @override
  _MoviesLikedPageState createState() => _MoviesLikedPageState();
}

class _MoviesLikedPageState extends State<MoviesLikedPage> {
  Set<int> bookmarkedMovies = {};
  Set<int> completedMovies = {};
  final ApiService apiService = ApiService(); // Initialize the API service
  bool isLoading = false; // Variable to manage loading state

  void _clearSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Clear"),
        content: Text("Are you sure you want to clear all liked movies?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without action
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                bookmarkedMovies.clear();
                widget.likedMovies.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("All liked movies have been cleared"),
                  duration: Duration(seconds: 1),
                ),
              );
              Navigator.of(context).pop(); // Close the dialog after clearing
            },
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }

  // Method to get recommendations based on liked movies
  void _getGeminiRecommendations() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    // Prepare the liked movies for the recommendation service
    final likedMoviesList = widget.likedMovies.map((movie) {
      return {
        'id': movie.id,
        'title': movie.title,
        'genre_ids': movie.genreIds,
        // Add other properties if necessary
      };
    }).toList();

    try {
      List<String> recommendations =
          await apiService.getGeminiRecommendations(likedMoviesList);

      if (recommendations.isNotEmpty) {
        // Show recommendations in an AlertDialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Recommendations"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: recommendations.map((title) {
                return ListTile(
                  title: Text(title),
                  trailing: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard functionality
                      Clipboard.setData(ClipboardData(text: title));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$title copied to clipboard")),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No recommendations found")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching recommendations")),
      );
    } finally {
      setState(() {
        isLoading = false; // Reset loading state to false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: "Liked Movies",
      appBar: AppBar(
        title: Text("Liked Movies"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: widget.likedMovies.isEmpty ? null : _clearSelection,
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
                        title: Text(movie.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked ? Color(0xFF9166FF) : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isBookmarked) {
                                    bookmarkedMovies.remove(movie.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${movie.title} has been removed from your watchlist'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    bookmarkedMovies.add(movie.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${movie.title} has been added to your watchlist'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isCompleted ? Icons.check : Icons.done,
                                color: isCompleted ? Colors.green : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isCompleted) {
                                    completedMovies.remove(movie.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${movie.title} has been marked as not watched'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    completedMovies.add(movie.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${movie.title} has been marked as watched'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _getGeminiRecommendations,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator() // Show loading indicator
                              : Text("Generate"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
