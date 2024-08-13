import 'package:flutter/material.dart';
import 'models/movie_model.dart'; // Import the movie model
import 'services/api_service.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  MovieDetailPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  fit: BoxFit.cover,
                  height: 400, // Increased height for the main movie poster
                  width: double.infinity,
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              movie.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Release date',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  movie.releaseDate,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: movie.genres.map((genre) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text(genre.name),
                    backgroundColor: Colors.grey[800],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text(
              'Synopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8.0),
            ExpandableText(
              text: movie.overview,
            ),
            SizedBox(height: 16.0),
            Text(
              'Related Movies',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 8.0),
            RelatedMovies(movieId: movie.id),
          ],
        ),
      ),
      backgroundColor: Colors.black87,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: expanded ? null : widget.maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, color: Colors.white),
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
  RelatedMovies({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(); // Create an instance of ApiService

    return FutureBuilder(
      future: apiService.getRelatedMovies(movieId), // Call the instance method
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching related movies.'));
        } else {
          List<Movie> relatedMovies = snapshot.data as List<Movie>;
          return Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: relatedMovies.length,
              itemBuilder: (context, index) {
                Movie movie = relatedMovies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                          height: 130, // Adjusted height for a better fit
                          width: 90, // Maintain aspect ratio
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        width: 90, // Ensure the text width matches the poster width
                        child: Text(
                          movie.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, // Adjusted font size for better readability
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2, // Limit to two lines
                          overflow: TextOverflow.ellipsis, // Add ellipsis for long titles
                        ),
                      ),
                    ],
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
