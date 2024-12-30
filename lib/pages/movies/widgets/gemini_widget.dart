import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Adjust the import based on your project structure
import '../models/movie_model.dart'; // Adjust the import based on your project structure

class RecommendationsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> likedMovies;

  const RecommendationsWidget({Key? key, required this.likedMovies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: ApiService().getGeminiRecommendations(likedMovies),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No recommendations available.'));
        } else {
          final recommendations = snapshot.data!;
          return ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(recommendations[index]),
              );
            },
          );
        }
      },
    );
  }
}
