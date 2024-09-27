import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'services/api_service.dart'; // Import your API service
import 'models/movie_model.dart'; // Import your Movie model
import 'package:binge/pages/baseScaffold.dart';
import 'MoviesLikedPage.dart'; // Import the liked movies page

class MoviesSwiperPage extends StatefulWidget {
  @override
  _MoviesSwiperPageState createState() => _MoviesSwiperPageState();
}

class _MoviesSwiperPageState extends State<MoviesSwiperPage> {
  ApiService apiService = ApiService();
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;
  List<Movie> likedMovies = [];
  List<String> selectedGenres = [];

  final List<Map<String, String>> availableGenres = [
    {'id': '28', 'name': 'Action'},
    {'id': '12', 'name': 'Adventure'},
    {'id': '16', 'name': 'Animation'},
    {'id': '35', 'name': 'Comedy'},
    {'id': '80', 'name': 'Crime'},
    {'id': '18', 'name': 'Drama'},
    {'id': '14', 'name': 'Fantasy'},
    {'id': '27', 'name': 'Horror'},
    {'id': '9648', 'name': 'Mystery'},
    {'id': '10749', 'name': 'Romance'},
    {'id': '878', 'name': 'Science Fiction'},
    {'id': '53', 'name': 'Thriller'},
    {'id': '10752', 'name': 'War'},
    {'id': '37', 'name': 'Western'},
  ];

  @override
  void initState() {
    super.initState();
    selectedGenres = [];
  }

  void fetchMoviesByGenres() async {
    if (selectedGenres.isEmpty) {
      return;
    }

    List<Movie> movies = await apiService.fetchMoviesByGenres(selectedGenres);

    if (movies.isNotEmpty) {
      setState(() {
        swipeItems = movies.map((movie) {
          return SwipeItem(
            content: movie,
            likeAction: () {
              _addMovieToLiked(movie); // Call the method to handle liking a movie
            },
            nopeAction: () {
              print('Nope ${movie.title}');
            },
            superlikeAction: () {
              _addMovieToLiked(movie); // Call the method for super liking a movie
            },
          );
        }).toList();

        matchEngine = MatchEngine(swipeItems: swipeItems);
      });
    } else {
      setState(() {
        swipeItems.clear(); // Clear swipe items if no movies found
        matchEngine = null; // Reset the match engine
      });
    }
  }

  void _addMovieToLiked(Movie movie) {
    setState(() {
      // Only add the movie if it's not already liked
      if (!likedMovies.any((likedMovie) => likedMovie.id == movie.id)) {
        likedMovies.add(movie);
      }
    });
  }

  void updateSelectedGenres(String genreId, bool selected) {
    setState(() {
      if (selected) {
        selectedGenres.add(genreId);
      } else {
        selectedGenres.remove(genreId);
      }
    });
  }

  void openGenresModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                height: 400,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Select Genres',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: availableGenres.length,
                        itemBuilder: (context, index) {
                          final genre = availableGenres[index];
                          final isSelected = selectedGenres.contains(genre['id']);
                          return CheckboxListTile(
                            title: Text(genre['name']!),
                            value: isSelected,
                            onChanged: (bool? selected) {
                              setState(() {
                                updateSelectedGenres(genre['id']!, selected!);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        fetchMoviesByGenres();
                      },
                      child: Text('Done'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10), // Add space at the top for padding
            if (selectedGenres.isEmpty)
              Expanded(
                child: Center(
                  child: Text("No genres selected. Please select genres to view movies."),
                ),
              )
            else if (swipeItems.isEmpty && matchEngine == null)
              Expanded(
                child: Center(child: Text("Select genres to show movies.")), // Updated message
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: matchEngine == null
                          ? Center(child: CircularProgressIndicator())
                          : SwipeCards(
                              matchEngine: matchEngine!,
                              itemBuilder: (BuildContext context, int index) {
                                final movie = swipeItems[index].content as Movie;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16.0),
                                            child: movie.posterPath != null
                                                ? Image.network(
                                                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
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
                                                  )
                                                : Container(
                                                    height: 150,
                                                    width: double.infinity,
                                                    color: Colors.grey,
                                                    child: Center(child: Text('No Image Available')),
                                                  ),
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
                                  ),
                                );
                              },
                              onStackFinished: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("End of Movies"),
                                    content: Text("You've gone through all the movies. Would you like to start again?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          fetchMoviesByGenres();
                                        },
                                        child: Text("Yes"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("No"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 10), // Add space between movie cards and button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MoviesLikedPage(likedMovies: likedMovies)),
                        );
                      },
                      child: Text("View Liked Movies"),
                    ),
                    SizedBox(height: 10), // Add space at the bottom for padding
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openGenresModal(context);
        },
        child: Icon(Icons.category),
        tooltip: 'Select Genres',
      ),
    );
  }
}
