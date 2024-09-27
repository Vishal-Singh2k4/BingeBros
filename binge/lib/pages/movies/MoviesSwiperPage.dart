import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'services/api_service.dart'; // Import your API service
import 'models/movie_model.dart'; // Import your Movie model
import 'package:binge/pages/baseScaffold.dart';
import 'MoviesLikedPage.dart';

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
            ElevatedButton(
              onPressed: () => openGenresModal(context),
              child: Text('Select Genres'),
            ),
            Expanded( 
              child: matchEngine == null
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: SwipeCards(
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
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('No more movies!'),
                              ));
                            },
                            leftSwipeAllowed: true,
                            rightSwipeAllowed: true,
                          ),
                        ),
                        
       Center(
  child: SizedBox(
    width: 200, // Set the width of the button as needed
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LikedMoviesPage(likedMovies: likedMovies),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF9166FF),
        padding: EdgeInsets.symmetric(vertical: 2.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'View Liked Movies',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
)
 
                      ],
                      
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
class LikedMoviesPage extends StatefulWidget {
  final List<Movie> likedMovies;

  LikedMoviesPage({required this.likedMovies});

  @override
  _LikedMoviesPageState createState() => _LikedMoviesPageState();
}

class _LikedMoviesPageState extends State<LikedMoviesPage> {
  List<Movie> bookmarkedMovies = []; // Store bookmarked movies

  void generateMovieList(BuildContext context) async {
    List<String> movieTitles = widget.likedMovies.map((movie) => movie.title).toList();
    print("Liked Movies Titles: $movieTitles");

    ApiService apiService = ApiService();
    await apiService.fetchMovieRecommendations(movieTitles);
  }

  void _toggleBookmark(Movie movie) {
    setState(() {
      if (bookmarkedMovies.contains(movie)) {
        bookmarkedMovies.remove(movie);
      } else {
        bookmarkedMovies.add(movie);
      }
    });
    // Show a Snackbar to inform the user about the action
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(bookmarkedMovies.contains(movie) ? '${movie.title} bookmarked!' : '${movie.title} removed from bookmarks!'), duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Movies'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: widget.likedMovies.isEmpty
          ? Center(
              child: Text('No liked movies yet'),
            )
          : Column(
              children: [
                ElevatedButton(
                  onPressed: () => generateMovieList(context),
                  child: Text('Generate'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.likedMovies.length,
                    itemBuilder: (context, index) {
                      final movie = widget.likedMovies[index];
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
                        trailing: IconButton(
                          icon: Icon(bookmarkedMovies.contains(movie) ? Icons.bookmark : Icons.bookmark_border),
                          onPressed: () => _toggleBookmark(movie),
                        ),
                        onTap: () {
                          // Handle tap on the movie
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MoviesLikedPage(bookmarkedMovies: bookmarkedMovies),
                      ),
                    );
                  },
                  child: Text('View Bookmarked Movies'),
                ),
              ],
            ),
    );
  }
}
