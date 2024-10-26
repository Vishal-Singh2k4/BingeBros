import 'package:flutter/material.dart';
import 'package:binge/pages/baseScaffold.dart'; // Use your BaseScaffold class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/movie_model.dart'; // Import your Movie model
import 'services/api_service.dart'; // Import your Movie model
import 'firebase_service.dart'; // Import your Firebase service
import 'movie_detail_page.dart'; // Import the MovieDetailPage

class MoviesBookmarked extends StatefulWidget {
  static final GlobalKey<_MoviesBookmarkedState> moviesBookmarkedKey =
      GlobalKey<_MoviesBookmarkedState>();

  static final ValueNotifier<bool> shouldRefreshNotifier = ValueNotifier(false);

  @override
  _MoviesBookmarkedState createState() => _MoviesBookmarkedState();
}

class _MoviesBookmarkedState extends State<MoviesBookmarked>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService(); // Initialize ApiService
  final FirebaseService firebaseService =
      FirebaseService(); // Initialize FirebaseService
  List<Movie> watchlistMovies = []; // List to hold Movie objects
  List<Movie> watchedMovies = [];
  bool isLoading = true;
  late TabController _tabController; // Declare a TabController

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Update the current tab index whenever the tab changes
      });
    });
    _loadMovies();

    // Listen for refresh requests
    MoviesBookmarked.shouldRefreshNotifier.addListener(() {
      if (MoviesBookmarked.shouldRefreshNotifier.value) {
        refreshMovies();
        MoviesBookmarked.shouldRefreshNotifier.value = false; // Reset notifier
      }
    });
  }

  void refreshMovies() {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    _loadMovies(); // Call the method to load movies again
  }

  Future<void> _loadMovies() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';

    if (userId.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          List<dynamic> bookmarks = userDoc['movie_bookmark'] ?? [];
          List<dynamic> watched = userDoc['movie_watched'] ?? [];

          // Fetch movie details for the watchlist and watched movies
          watchlistMovies = await _fetchMoviesDetails(bookmarks);
          watchedMovies = await _fetchMoviesDetails(watched);
        }
      } catch (e) {
        print("Error loading movies: $e");
      } finally {
        setState(() {
          isLoading = false; // Loading finished
        });
      }
    } else {
      setState(() {
        isLoading = false; // No user logged in
      });
    }
  }

  Future<List<Movie>> _fetchMoviesDetails(List<dynamic> movieIds) async {
    List<Movie> movies = [];
    for (var id in movieIds) {
      try {
        Movie movie = await apiService.fetchMovieById(id.toString());
        movies.add(movie);
      } catch (e) {
        print("Error fetching movie details for ID $id: $e");
      }
    }
    return movies;
  }

  Future<void> _handleDeleteMovie(Movie movie) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';

    if (userId.isNotEmpty) {
      if (_tabController.index == 0) {
        // If the active tab is Watchlist, remove from watchlist
        await firebaseService.toggleBookmark(userId, movie.id);
        print('Removed from watchlist: ${movie.title}');
      } else if (_tabController.index == 1) {
        // If the active tab is Watched, remove from watched
        await firebaseService.toggleWatched(userId, movie.id);
        print('Removed from watched: ${movie.title}');
      }

      // Refresh the movie list after deletion
      refreshMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color unselectedTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[800]!;
    final Color tabIndicatorColor = isDarkMode ? Colors.white : Colors.black;

    return BaseScaffold(
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TabBar(
                    controller:
                        _tabController, // Set the controller for the TabBar
                    labelColor: primaryTextColor,
                    unselectedLabelColor: unselectedTextColor,
                    indicatorColor: tabIndicatorColor,
                    tabs: [
                      Tab(text: 'Watchlist'),
                      Tab(text: 'Watched'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller:
                          _tabController, // Set the controller for the TabBarView
                      children: [
                        _buildMoviesList(watchlistMovies,
                            'No movies in your watchlist', primaryTextColor),
                        _buildMoviesList(watchedMovies,
                            'No movies marked as watched', primaryTextColor),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMoviesList(
      List<Movie> movies, String emptyMessage, Color textColor) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userId = user?.uid ?? '';

    if (movies.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: TextStyle(fontSize: 20, color: textColor),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  movie.title,
                  style: TextStyle(color: textColor),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _handleDeleteMovie(movie),
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
              ),
              SizedBox(height: 10),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
