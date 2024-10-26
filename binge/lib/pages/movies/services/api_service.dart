import 'dart:async'; // Import this for Completer
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/movie_model.dart'; // Adjust the path as needed

class ApiService {
  final String apiKey = '827ff2b76ef87771bf42fef7226d8093';
  final String baseUrl = 'https://api.themoviedb.org/3';
  late final Gemini gemini; // Use late initialization for the gemini instance

  ApiService() {
    // Initialize the Gemini API with your API key in the constructor body
    gemini = Gemini.init(apiKey: 'AIzaSyCrP98B26g2SbnZQLrHNSXDNXjOdIvaVbI');
  }

  // Fetch trending movies for the "Trending" section
  Future<List<Movie>> fetchTrendingMovies() async {
    final response = await http
        .get(Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'));

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
    final response =
        await http.get(Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey'));

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
    final response = await http
        .get(Uri.parse('$baseUrl/movie/$movieId/similar?api_key=$apiKey'));

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
    final genreString = genres.join(',');
    final response = await http.get(Uri.parse(
        '$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreString'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies by genres');
    }
  }

  // Search movies
  Future<List<Movie>> searchMovies(String query) async {
    final response = await http
        .get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data); // Log the entire response for debugging

      final List<dynamic> results = data['results'];
      results.forEach((movie) =>
          print(movie)); // Log each movie result for further inspection

      return results.take(10).map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<List<Movie>> fetchMonthTopRatedMovies() async {
    final DateTime now = DateTime.now();
    final DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);

    final response = await http.get(
      Uri.parse(
          '$baseUrl/discover/movie?api_key=$apiKey&sort_by=vote_average.desc&primary_release_date.gte=${lastMonth.toIso8601String()}&primary_release_date.lte=${now.toIso8601String()}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top rated movies of the month');
    }
  }

  Future<Movie> fetchMovieById(String movieId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Failed to load movie');
    }
  }

  Future<List<Movie>> fetchYearTopRatedMovies() async {
    final int currentYear = DateTime.now().year;

    final response = await http.get(
      Uri.parse(
          '$baseUrl/discover/movie?api_key=$apiKey&sort_by=vote_average.desc&primary_release_year=$currentYear'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top rated movies of the year');
    }
  }

  Future<List<Movie>> fetchTopRatedMovies() async {
    final response =
        await http.get(Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<List<String>> getGeminiRecommendations(
      List<Map<String, dynamic>> likedMovies) async {
    final prompt = jsonEncode(likedMovies);
    final requestPrompt = '''
You are a movie recommendation system. Given the following list of movies, please provide exactly *5* similar movie titles (DO NOT REPEAT THE GIVEN TITLES) in a *valid JSON array format*. The titles should be surrounded by double quotes and separated by commas. Ensure that the output does not contain any additional text, explanations, or formatting errors.

Here are the movies:
$prompt

Your output should look like this: ["Recommended Movie name 1", "Recommended Movie name 2", "Recommended Movie name 3", "Recommended Movie name 4", "Recommended Movie name 5"]
''';

    print('Request Prompt: $requestPrompt'); // Log the request prompt

    final recommendationsCompleter =
        Completer<List<String>>(); // Changed to return List<String>
    List<String> recommendations = [];
    StringBuffer rawOutputBuffer = StringBuffer(); // Buffer to hold raw output
    bool isCompleted = false; // Track if the completer has been completed

    try {
      final stream = gemini.streamGenerateContent(requestPrompt);
      await for (final value in stream) {
        if (value.output != null) {
          // Append the output to the buffer
          rawOutputBuffer.write(value.output);
          print(
              'Raw API Response: ${value.output}'); // Print the raw API response

          // Attempt to parse the output after each append
          String cleanedOutput = rawOutputBuffer.toString().trim();

          try {
            // Check if cleanedOutput is a valid JSON array
            if (cleanedOutput.startsWith('[') && cleanedOutput.endsWith(']')) {
              recommendations = List<String>.from(jsonDecode(cleanedOutput));
              print("RECOMMENDATIONS");
              print(recommendations);
              // Complete the future when all data is received
              if (!isCompleted) {
                isCompleted = true; // Set the flag to true
                recommendationsCompleter.complete(recommendations);
              }
            }
          } catch (e) {
            print(
                'Failed to parse response: $cleanedOutput'); // Log the response that failed to parse
            log('JSON parsing error', error: e);
            if (!isCompleted) {
              isCompleted = true; // Set the flag to true
              recommendationsCompleter.completeError('Failed to parse JSON');
            }
          }
        } else {
          print('No recommendations returned.');
          if (!isCompleted) {
            isCompleted = true; // Set the flag to true
            recommendationsCompleter
                .completeError('No recommendations returned');
          }
        }
      }
    } catch (e) {
      log('streamGenerateContent exception', error: e);
      if (!isCompleted) {
        isCompleted = true; // Set the flag to true
        recommendationsCompleter
            .completeError('Failed to load recommendations from Gemini: $e');
      }
    }

    // Await the completer's future
    return recommendationsCompleter.future;
  }
}
