import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'services/api_service.dart'; // Import the API service
import 'models/movie_model.dart'; // Import the model file
import 'movie_detail_page.dart'; // Import the movie detail page
import 'package:binge/pages/baseScaffold.dart';

class MoviesHomePageContent extends StatefulWidget {
  @override
  _MoviesHomePageContentState createState() => _MoviesHomePageContentState();
}

class _MoviesHomePageContentState extends State<MoviesHomePageContent> {
  final ApiService apiService = ApiService(); // Create an instance of ApiService
  List<Movie>? movies;
  String searchQuery = '';
  List<Movie>? searchResults;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies();
  }

  Future<void> fetchTrendingMovies() async {
    try {
      final List<Movie> trendingMovies = await apiService.fetchTrendingMovies();
      setState(() {
        movies = trendingMovies;
      });
    } catch (error) {
      print('Error fetching trending movies: $error');
    }
  }

  Future<void> searchMovies() async {
    if (searchQuery.isNotEmpty) {
      try {
        final List<Movie> searchedMovies = await apiService.searchMovies(searchQuery);
        setState(() {
          searchResults = searchedMovies; // Set searched movies
        });
      } catch (error) {
        print('Error searching movies: $error');
      }
    } else {
      setState(() {
        searchResults = null; // Clear search results if query is empty
      });
      fetchTrendingMovies(); // Fetch trending movies if search query is empty
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearchResults() {
    setState(() {
      searchQuery = '';
      searchResults = null;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _clearSearchResults(); // Clear search results when tapping outside
      },
      child: BaseScaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                child: TextField(
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search for movies...',
                    filled: true,
                    fillColor: Color(0xFF9166FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchMovies(); // Call searchMovies on button press
                        FocusScope.of(context).unfocus(); // Dismiss keyboard
                      },
                      color: Colors.white,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value; // Update searchQuery
                    });
                    searchMovies(); // Trigger search on text change
                  },
                  onSubmitted: (value) {
                    searchMovies(); // Call searchMovies on keyboard submit
                    FocusScope.of(context).unfocus(); // Dismiss keyboard
                  },
                ),
              ),
              if (searchResults != null && searchResults!.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black, // Dark mode background
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ListView.builder(
                      itemCount: searchResults!.length,
                      itemBuilder: (context, index) {
                        final movie = searchResults![index];
                        return ListTile(
                          leading: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                            width: 50, // Thumbnail width
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error); // Fallback icon if image fails to load
                            },
                          ),
                          title: Text(
                            movie.title ?? 'Unknown Title',
                            style: TextStyle(color: Colors.white), // White text color for dark mode
                          ), 
                          subtitle: Text(
                            'Rating: ${movie.voteAverage ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey), // Grey subtitle color
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MovieDetailPage(movie: movie),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              Expanded(
                flex: searchResults != null && searchResults!.isNotEmpty ? 2 : 5, // Adjust flex based on search results
                child: CarouselSlider.builder(
                  itemCount: movies?.length ?? 0,
                  itemBuilder: (context, index, realIndex) {
                    final movie = movies![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailPage(movie: movie),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                fit: BoxFit.cover,
                                height: 400,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text('Image not available'));
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  SizedBox(width: 4.0),
                                  Text(
                                    movie.voteAverage?.toString() ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                movie.title ?? 'Unknown Title',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 400.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
