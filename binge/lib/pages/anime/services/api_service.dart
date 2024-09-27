import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart'; // Adjust the path as needed

class ApiService {
  final String apiKey =
      '827ff2b76ef87771bf42fef7226d8093'; // Replace with your actual API key
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Fetch trending anime for the "Trending" section
  Future<List<Anime>> fetchTrendingAnime() async {
    final response =
        await http.get(Uri.parse('$baseUrl/trending/tv/week?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trending anime');
    }
  }

  // Fetch top recommended anime for the "Your Preferences" section
  Future<List<Anime>> fetchTopRecommendedAnime() async {
    final response =
        await http.get(Uri.parse('$baseUrl/tv/top_rated?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top recommended anime');
    }
  }

  // Fetch related anime for the "Related Anime" section in AnimeDetailPage
  Future<List<Anime>> getRelatedAnime(int animeId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/tv/$animeId/similar?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load related anime');
    }
  }
}
