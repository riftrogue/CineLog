class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String releaseDate; // keep as string (YYYY-MM-DD or empty)
  final double voteAverage;
  final String mediaType; // movie, tv, etc.

  const Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
    required this.voteAverage,
    this.mediaType = 'movie', // default to movie for backward compatibility
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int,
      title: (map['title'] ?? '').toString(),
      posterPath: map['posterPath'] as String?,
      releaseDate: (map['releaseDate'] ?? '').toString(),
      voteAverage: (map['voteAverage'] is num) ? (map['voteAverage'] as num).toDouble() : 0.0,
      mediaType: (map['mediaType'] ?? 'movie').toString(),
    );
  }
}
