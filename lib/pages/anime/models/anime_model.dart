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

class Anime {
  final int id;
  final String title;
  final String posterPath;
  final String releaseDate; // Ensure this is non-nullable
  final String overview;
  final List<Genre> genres;
  final double voteAverage;

  Anime({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate, // Ensure this is non-nullable
    required this.overview,
    required this.genres,
    required this.voteAverage,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    var genreList = json['genres'] as List<dynamic>? ?? [];
    return Anime(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'No Title',
      posterPath: json['poster_path'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? 'Unknown Release Date',
      overview: json['overview'] as String? ?? 'No Overview Available',
      genres: genreList.map((genreJson) => Genre.fromJson(genreJson)).toList(),
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
