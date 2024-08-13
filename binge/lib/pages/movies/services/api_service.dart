import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart'; // Adjust the path as needed

class ApiService {
  final String apiKey = '827ff2b76ef87771bf42fef7226d8093';
  final String baseUrl = 'https://api.themoviedb.org/3';

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
}
