import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'services/api_service.dart'; // Import the API service
import 'models/movie_model.dart'; // Import the model file
import 'movie_detail_page.dart'; // Import the movie detail page

class MoviesHomePageContent extends StatelessWidget {
  final ApiService apiService = ApiService(); // Create an instance of ApiService

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<Movie>>(
          future: apiService.fetchTrendingMovies(), // Call the fetchTrendingMovies method
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No movies found');
            } else {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index, realIndex) {
                              final movie = snapshot.data![index];
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
                                        borderRadius: BorderRadius.circular(16.0), // Rounded corners
                                        child: Image.network(
                                          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          fit: BoxFit.cover,
                                          height: 400, // Height as per the carousel
                                          width: double.infinity, // Full width
                                        ),
                                      ),
                                    ),
                                    // IMDb rating overlay
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
                                              movie.voteAverage.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Title inside the poster
                                    Positioned(
                                      bottom: 0, // Adjust this to position the title higher/lower
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                        margin: EdgeInsets.symmetric(horizontal: 8.0), // Add margin to fit inside the poster
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7), // Slightly darker for better readability
                                          borderRadius: BorderRadius.circular(12.0), // Match the overall theme
                                        ),
                                        child: Text(
                                          movie.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14, // Slightly smaller to fit better
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2, // Limit to two lines
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
                              viewportFraction: 0.7, // Controls the size of items in the carousel
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16.0, // Adjusted position from the top
                    left: 16.0, // Align text to the left or center as desired
                    right: 16.0,
                    child: Text(
                      'Trending Now',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Black color for the text
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
