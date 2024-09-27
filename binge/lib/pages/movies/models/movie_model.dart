class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Movie {
  final int id;  
  final String title;
  final String? posterPath; // Changed to nullable to handle missing data
  final String releaseDate;
  final String overview;
  final List<Genre> genres;
  final double voteAverage;  // Added voteAverage field

  Movie({
    required this.id,  
    required this.title,
    this.posterPath, // Make posterPath nullable
    required this.releaseDate,
    required this.overview,
    required this.genres,
    required this.voteAverage,  // Ensure this is required
  });

  // Getter for genreIds to return a list of genre IDs
  List<int> get genreIds => genres.map((genre) => genre.id).toList();

  factory Movie.fromJson(Map<String, dynamic> json) {
    var genreList = json['genres'] as List<dynamic>? ?? [];
    return Movie(
      id: json['id'] as int,  
      title: json['title'] as String,
      posterPath: json['poster_path'] as String?, // Allow for null posterPath
      releaseDate: json['release_date'] as String? ?? 'Unknown', // Provide default value for releaseDate
      overview: json['overview'] as String? ?? 'No overview available', // Provide default value for overview
      genres: genreList.map((genreJson) => Genre.fromJson(genreJson as Map<String, dynamic>)).toList(), // Ensure correct type casting
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0, // Safely parse voteAverage
    );
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, posterPath: $posterPath, releaseDate: $releaseDate, overview: $overview, genres: $genres, voteAverage: $voteAverage}';
  }
}
