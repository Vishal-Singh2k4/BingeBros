import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'services/api_service.dart'; // Import your API service
import 'models/movie_model.dart'; // Import your Movie model

void main() {
  runApp(MaterialApp(home: GenreSelectionPage()));
}

class GenreSelectionPage extends StatefulWidget {
  @override
  _GenreSelectionPageState createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
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

  void updateSelectedGenres(int index, bool selected) {
    String genre = availableGenres[index];
    setState(() {
      if (selected) {
        selectedGenres.add(genre);
      } else {
        selectedGenres.remove(genre);
      }
    });
  }

  void navigateToSwiper() {
    if (selectedGenres.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MoviesSwiperPage(selectedGenres: selectedGenres),
        ),
      );
    } else {
      // Show a message if no genres are selected
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select at least one genre'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Genres')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            height: 50.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: availableGenres.length,
              itemBuilder: (context, index) {
                String genre = availableGenres[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      updateSelectedGenres(
                          index, !selectedGenres.contains(genre));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGenres.contains(genre)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: Text(genre),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: navigateToSwiper,
            child: Text('Go to Movies Swiper'),
          ),
        ],
      ),
    );
  }
}

class MoviesSwiperPage extends StatefulWidget {
  final List<String> selectedGenres;

  MoviesSwiperPage({required this.selectedGenres});

  @override
  _MoviesSwiperPageState createState() => _MoviesSwiperPageState();
}

class _MoviesSwiperPageState extends State<MoviesSwiperPage> {
  ApiService apiService = ApiService();
  List<SwipeItem> swipeItems = [];
  MatchEngine? matchEngine;
  List<Movie> likedMovies = [];

  @override
  void initState() {
    super.initState();
    fetchMoviesByGenres();
  }

  void fetchMoviesByGenres() async {
    List<Movie> movies =
        await apiService.fetchMoviesByGenres(widget.selectedGenres);
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
            likedMovies.add(movie);
            print('Superliked ${movie.title}');
          },
        );
      }).toList();

      matchEngine = MatchEngine(swipeItems: swipeItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movies Swiper')),
      body: matchEngine == null
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
                              child: movie.posterPath != null
                                  ? Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                      fit: BoxFit.cover,
                                      height: 250,
                                      width: double.infinity,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
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
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Center(
                                            child: Text('Image not available'));
                                      },
                                    )
                                  : Container(
                                      height: 250,
                                      width: double.infinity,
                                      color: Colors.grey,
                                      child: Center(
                                          child: Text('No Image Available')),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LikedMoviesPage(likedMovies: likedMovies),
                      ),
                    );
                  },
                  child: Text('View Liked Movies'),
                ),
              ],
            ),
    );
  }
}

class LikedMoviesPage extends StatelessWidget {
  final List<Movie> likedMovies;

  LikedMoviesPage({required this.likedMovies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wish List')),
      body: likedMovies.isEmpty
          ? Center(child: Text('No liked movies yet'))
          : ListView.builder(
              itemCount: likedMovies.length,
              itemBuilder: (context, index) {
                final movie = likedMovies[index];
                return ListTile(
                  title: Text(movie.title),
                  leading: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}'),
                );
              },
            ),
    );
  }
}
