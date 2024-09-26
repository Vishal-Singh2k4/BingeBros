import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'services/api_service.dart'; // Import your API service
import 'models/movie_model.dart'; // Import your Movie model

class MoviesSwiperPage extends StatefulWidget {
  @override
  _MoviesSwiperPageState createState() => _MoviesSwiperPageState();
}

class _MoviesSwiperPageState extends State<MoviesSwiperPage> {
  ApiService apiService = ApiService();
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine; // Changed to nullable
  List<Movie> likedMovies = [];
  List<String> selectedGenres = [];
  final List<String> availableGenres = [
    '28', // Action
    '12', // Adventure
    '16', // Animation
    '35', // Comedy
    '80', // Crime
    '18', // Drama
    '14', // Fantasy
    '27', // Horror
    '9648', // Mystery
    '10749', // Romance
    '878', // Science Fiction
    '53', // Thriller
    '10752', // War
    '37', // Western
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the genre selection to an empty list
    selectedGenres = [];
  }

  // Fetch movies based on selected genres
  void fetchMoviesByGenres() async {
    if (selectedGenres.isEmpty) {
      // Optionally handle the case where no genres are selected
      return;
    }

    // Fetch movies based on selected genres
    List<Movie> movies = await apiService.fetchMoviesByGenres(selectedGenres);

    setState(() {
      swipeItems = movies.map((movie) {
        return SwipeItem(
          content: movie,
          likeAction: () {
            likedMovies.add(movie);
          },
          nopeAction: () {
            print('Nope ${movie.title}');
          },
          superlikeAction: () {
            likedMovies.add(movie); // Add to likedMovies for both swipe right and superlike
            print('Superliked ${movie.title}');
          },
        );
      }).toList();

      // Initialize matchEngine after fetching movies
      matchEngine = MatchEngine(swipeItems: swipeItems);
    });
  }

  // Handle genre selection
  void updateSelectedGenres(int index, bool selected) {
    String genre = availableGenres[index];
    setState(() {
      if (selected) {
        selectedGenres.add(genre);
      } else {
        selectedGenres.remove(genre);
      }
      fetchMoviesByGenres(); // Fetch movies after genre selection
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Genre selection wrapped around
          Container(
            padding: EdgeInsets.all(8.0),
            height: 50.0, // Adjust height for the genre selection
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableGenres.length,
              itemBuilder: (context, index) {
                String genre = availableGenres[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          updateSelectedGenres(index, !selectedGenres.contains(genre));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedGenres.contains(genre) ? Colors.blue : Colors.grey, // Use backgroundColor
                        ),
                        child: Text(genre),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: matchEngine == null // Check if matchEngine is initialized
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        child: SwipeCards(
                          matchEngine: matchEngine!,
                          itemBuilder: (BuildContext context, int index) {
                            final movie = swipeItems[index].content as Movie;
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: movie.posterPath != null // Check if posterPath is not null
                                        ? Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                            fit: BoxFit.cover,
                                            height: 250, // Adjusted poster size
                                            width: double.infinity,
                                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                              if (loadingProgress == null) return child; // Image loaded
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
                                          )
                                        : Container(
                                            height: 250,
                                            width: double.infinity,
                                            color: Colors.grey, // Placeholder color if no poster
                                            child: Center(child: Text('No Image Available')),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      movie.title,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onStackFinished: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No more movies!'),
                            ));
                          },
                          leftSwipeAllowed: true,
                          rightSwipeAllowed: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Liked Movies: ${likedMovies.length}'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to a page showing the liked movies
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LikedMoviesPage(likedMovies: likedMovies),
                            ),
                          );
                        },
                        child: Text('View Liked Movies'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// LikedMoviesPage to display the list of liked movies
class LikedMoviesPage extends StatelessWidget {
  final List<Movie> likedMovies;

  LikedMoviesPage({required this.likedMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: likedMovies.isEmpty
          ? Center(
              child: Text('No liked movies yet'),
            )
          : ListView.builder(
              itemCount: likedMovies.length,
              itemBuilder: (context, index) {
                final movie = likedMovies[index];
                return ListTile(
                  title: Text(movie.title),
                  leading: Image.network('https://image.tmdb.org/t/p/w500${movie.posterPath}'),
                );
              },
            ),
    );
  }
}
