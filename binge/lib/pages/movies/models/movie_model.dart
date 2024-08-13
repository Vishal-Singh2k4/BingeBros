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
  final String posterPath;
  final String releaseDate;
  final String overview;
  final List<Genre> genres;
  final double voteAverage;  // Add voteAverage field

  Movie({
    required this.id,  
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.overview,
    required this.genres,
    required this.voteAverage,  // Ensure this is required
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    var genreList = json['genres'] as List<dynamic>? ?? [];
    return Movie(
      id: json['id'] as int,  
      title: json['title'] as String,
      posterPath: json['poster_path'] as String,
      releaseDate: json['release_date'] as String,
      overview: json['overview'] as String,
      genres: genreList.map((genreJson) => Genre.fromJson(genreJson)).toList(),
      voteAverage: (json['vote_average'] as num).toDouble(),  // Map voteAverage and ensure it's a double
    );
  }
}
