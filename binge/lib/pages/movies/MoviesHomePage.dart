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
      // Consider setting movies to an empty list or showing an error message
    }
  }

  Future<void> searchMovies() async {
    if (searchQuery.isNotEmpty) {
      try {
        final List<Movie> searchedMovies = await apiService.searchMovies(searchQuery);
        setState(() {
          movies = searchedMovies; // Set searched movies
        });
      } catch (error) {
        print('Error searching movies: $error');
      }
    } else {
      fetchTrendingMovies(); // Fetch trending movies if search query is empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for movies...',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      searchMovies(); // Call searchMovies on button press
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value; // Update searchQuery
                  });
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: searchQuery.isNotEmpty ? apiService.searchMovies(searchQuery) : apiService.fetchTrendingMovies(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                    return Center(child: Text('No movies found'));
                  } else {
                    movies = snapshot.data; // Set movies to the fetched data
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CarouselSlider.builder(
                                  itemCount: movies!.length,
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
                                                    movie.voteAverage?.toString() ?? 'N/A', // Handle null case
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
                                                movie.title ?? 'Unknown Title', // Handle null case
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
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
