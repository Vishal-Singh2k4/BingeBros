import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import the movie model
import 'services/api_service.dart';
import 'package:binge/pages/baseScaffold.dart'; // Import your BaseScaffold
import 'firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final String userId; // Add userId parameter

  MovieDetailPage({required this.movie, required this.userId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  bool isBookmarked = false;
  bool isWatched = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isBookmarked =
        await _firebaseService.isBookmarked(widget.userId, widget.movie.id);
    isWatched =
        await _firebaseService.isWatched(widget.userId, widget.movie.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BaseScaffold(
      title: widget.movie.title,
      backgroundColor: isDarkMode ? Colors.black87 : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoviePoster(context, isDarkMode),
            SizedBox(height: 16.0),
            _buildTitleText(isDarkMode),
            SizedBox(height: 8.0),
            _buildReleaseDateRow(),
            SizedBox(height: 8.0),
            _buildGenreChips(isDarkMode),
            SizedBox(height: 16.0),
            _buildSynopsisSection(isDarkMode),
            SizedBox(height: 16.0),
            _buildRelatedMoviesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoviePoster(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
          fit: BoxFit.cover,
          height: 400,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              'https://via.placeholder.com/400x600.png?text=No+Image',
              fit: BoxFit.cover,
              height: 400,
              width: double.infinity,
            );
          },
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(
                Icons.bookmark_outline_outlined,
                color: isBookmarked
                    ? Colors.purple
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
              onPressed: () async {
                await _firebaseService.toggleBookmark(
                    widget.userId, widget.movie.id);
                setState(() {
                  isBookmarked = !isBookmarked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${widget.movie.title} ${isBookmarked ? 'added to Watchlist!' : 'removed from watchlist!'}'),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check,
                color: isWatched
                    ? Colors.green
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
              onPressed: () async {
                await _firebaseService.toggleWatched(
                    widget.userId, widget.movie.id);
                setState(() {
                  isWatched = !isWatched;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${widget.movie.title} ${isWatched ? 'marked as watched!' : 'removed from watched!'}'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleText(bool isDarkMode) {
    return Text(
      widget.movie.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildReleaseDateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Release date',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          widget.movie.releaseDate,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGenreChips(bool isDarkMode) {
    return Row(
      children: widget.movie.genres.map((genre) {
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Chip(
            label: Text(
              genre.name,
              style: TextStyle(
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSynopsisSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        SizedBox(height: 8.0),
        ExpandableText(
          text: widget.movie.overview,
        ),
      ],
    );
  }

  Widget _buildRelatedMoviesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Movies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.0),
        RelatedMovies(movieId: widget.movie.id),
      ],
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  ExpandableText({required this.text, this.maxLines = 3});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : widget.maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Text(
            expanded ? 'Read less' : 'Read more',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class RelatedMovies extends StatelessWidget {
  final int movieId;
  final String placeholderImageUrl =
      'https://via.placeholder.com/200x300.png?text=No+Image';

  RelatedMovies({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user != null ? user.uid : '';
    final apiService = ApiService(); // Create an instance of ApiService

    return FutureBuilder<List<Movie>>(
      future: apiService.getRelatedMovies(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Internet Error'));
        } else {
          final List<Movie> relatedMovies = snapshot.data ?? [];

          if (relatedMovies.isEmpty) {
            return Center(child: Text('No related movies available.'));
          }

          return Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedMovies.length,
              itemBuilder: (context, index) {
                final Movie movie = relatedMovies[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailPage(movie: movie, userId: userId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                            height: 130,
                            width: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                placeholderImageUrl,
                                height: 130,
                                width: 90,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                        // Updated Text widget to allow wrapping
                        Container(
                          width: 90, // Set the width to match the image
                          child: Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 12, // Reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2, // Allow up to 2 lines
                            overflow: TextOverflow
                                .ellipsis, // Show ellipsis for overflow
                            softWrap: true, // Allow wrapping
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
