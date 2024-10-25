import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import your Movie model
import 'services/api_service.dart'; // Import your API service
import 'package:flutter/services.dart';
import 'package:binge/pages/baseScaffold.dart'; // Import your BaseScaffold
import 'movie_detail_page.dart'; // Import the movie detail page
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class MoviesLikedPage extends StatefulWidget {
  final List<Movie> likedMovies;

  MoviesLikedPage({required this.likedMovies});

  @override
  _MoviesLikedPageState createState() => _MoviesLikedPageState();
}

class _MoviesLikedPageState extends State<MoviesLikedPage> {
  Set<int> bookmarkedMovies = {};
  Set<int> completedMovies = {};
  final ApiService apiService = ApiService();
  final FirebaseService _firebaseService = FirebaseService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMovieStates();
  }

  Future<void> _loadMovieStates() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      for (Movie movie in widget.likedMovies) {
        // Check bookmark and watched status in one go
        await _fetchMovieState(userId, movie.id);
      }
      setState(() {});
    }
  }

  Future<void> _fetchMovieState(String userId, int movieId) async {
    bool isBookmarked = await _firebaseService.isBookmarked(userId, movieId);
    bool isWatched = await _firebaseService.isWatched(userId, movieId);

    if (isBookmarked) bookmarkedMovies.add(movieId);
    if (isWatched) completedMovies.add(movieId);
  }

  void _clearSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Clear"),
        content: Text("Are you sure you want to clear all liked movies?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                bookmarkedMovies.clear();
                widget.likedMovies.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("All liked movies have been cleared")),
              );
              Navigator.of(context).pop();
            },
            child: Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _getGeminiRecommendations() async {
    setState(() {
      isLoading = true;
    });

    final likedMoviesList = widget.likedMovies.map((movie) {
      return {
        'id': movie.id,
        'title': movie.title,
        'genre_ids': movie.genreIds,
      };
    }).toList();

    try {
      List<String> recommendations =
          await apiService.getGeminiRecommendations(likedMoviesList);

      if (recommendations.isNotEmpty) {
        _showRecommendationsDialog(recommendations);
      } else {
        _showSnackBar("No recommendations found");
      }
    } catch (error) {
      _showSnackBar("Error fetching recommendations");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showRecommendationsDialog(List<String> recommendations) {
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
                  Clipboard.setData(ClipboardData(text: title));
                  _showSnackBar("$title copied to clipboard");
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
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                      final User? user = FirebaseAuth.instance.currentUser;
                      final String userId = user?.uid ?? '';

                      return ListTile(
                        leading: movie.posterPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                  width: 50,
                                  height: 75,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 50,
                                      height: 75,
                                      color: Colors.grey,
                                      child: Center(child: Text('No Image')),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 75,
                                color: Colors.grey,
                                child: Center(child: Text('No Image')),
                              ),
                        title: Text(movie.title),
                        subtitle: Text(
                            'Rating: ${movie.voteAverage.toStringAsFixed(1)}'),
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
                                    _firebaseService.toggleBookmark(
                                        userId, movie.id);
                                    _showSnackBar(
                                        '${movie.title} has been removed from your watchlist');
                                  } else {
                                    bookmarkedMovies.add(movie.id);
                                    _firebaseService.toggleBookmark(
                                        userId, movie.id);
                                    _showSnackBar(
                                        '${movie.title} has been added to your watchlist');
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
                                    _firebaseService.toggleWatched(
                                        userId, movie.id);
                                    _showSnackBar(
                                        '${movie.title} has been marked as not watched');
                                  } else {
                                    completedMovies.add(movie.id);
                                    _firebaseService.toggleWatched(
                                        userId, movie.id);
                                    _showSnackBar(
                                        '${movie.title} has been marked as watched');
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailPage(movie: movie, userId: userId),
                            ),
                          );
                        },
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
                          onPressed:
                              isLoading ? null : _getGeminiRecommendations,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text("Get Recommendations"),
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
