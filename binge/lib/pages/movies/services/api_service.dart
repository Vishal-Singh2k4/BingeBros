import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart'; // Adjust the path as needed

class ApiService {
  final String apiKey = '827ff2b76ef87771bf42fef7226d8093';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String geminiApiUrl = 'https://api.gemini.com/v1/'; // Replace with the actual Gemini API URL
  final String geminiApiKey = 'AIzaSyBPvmKxGignLAvfxrlu6HB6iaWht7rYhnw'; // Add your Gemini API key here

  // Fetch trending movies for the "Trending" section
  Future<List<Movie>> fetchTrendingMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  // Fetch top recommended movies for the "Your Preferences" section
  Future<List<Movie>> fetchTopRecommendedMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top recommended movies');
    }
  }

  // Fetch related movies for the "Related Movies" section in MovieDetailPage
  Future<List<Movie>> getRelatedMovies(int movieId) async {
    final response = await http.get(Uri.parse('$baseUrl/movie/$movieId/similar?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load related movies');
    }
  }

  // Fetch movies based on selected genres
  Future<List<Movie>> fetchMoviesByGenres(List<String> genres) async {
    // Join genres to create a query string (e.g., "28,12")
    final genreString = genres.join(',');
    final response = await http.get(Uri.parse('$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreString'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies by genres');
    }
  }

  // Fetch movie recommendations from Gemini API
  Future<List<String>> fetchMovieRecommendations(List<String> movieTitles) async {
    // Create the prompt for the Gemini API
    String prompt = 'Give only movie recommendations in a JSON format based on the list provided: ${movieTitles.join(', ')}';

    // Create the request body
    Map<String, dynamic> requestBody = {
      'prompt': prompt,
      'max_tokens': 100, // Adjust based on your needs
      // Add other parameters if necessary
    };

    // Make the POST request to the Gemini API
    final response = await http.post(
      Uri.parse('$geminiApiUrl/your-endpoint'), // Replace with the actual endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $geminiApiKey', // Use your Gemini API key here
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Here, we assume the response is a list of recommended movie titles
      List<String> recommendations = List<String>.from(data['recommendations']); // Adjust this based on the actual structure of the response
      return recommendations;
    } else {
      throw Exception('Failed to get recommendations from Gemini API');
    }
  }
}
