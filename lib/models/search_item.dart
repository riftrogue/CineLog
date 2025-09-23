class SearchItem {
  final int id;
  final String mediaType; // movie, tv, person, etc.
  final String title;
  final String? posterPath;
  final String? date; // release_date or first_air_date
  final double voteAverage;

  SearchItem({
    required this.id,
    required this.mediaType,
    required this.title,
    required this.posterPath,
    required this.date,
    required this.voteAverage,
  });

  factory SearchItem.fromMap(Map<String, dynamic> map) {
    final mediaType = (map['media_type'] ?? '').toString();
    String title = '';
    if (mediaType == 'movie') {
      title = (map['title'] ?? '').toString();
    } else if (mediaType == 'tv') {
      title = (map['name'] ?? '').toString();
    } else {
      title = (map['title'] ?? map['name'] ?? '').toString();
    }
    return SearchItem(
      id: (map['id'] as num).toInt(),
      mediaType: mediaType,
      title: title,
      posterPath: map['poster_path'] as String?,
      date: (map['release_date'] ?? map['first_air_date'])?.toString(),
      voteAverage: (map['vote_average'] is num) ? (map['vote_average'] as num).toDouble() : 0.0,
    );
  }

  String get displayTitle => title.isEmpty ? '(Untitled)' : title;

  String? get year => (date != null && date!.isNotEmpty) ? date!.split('-').first : null;

  factory SearchItem.empty() {
    return SearchItem(
      id: 0,
      mediaType: 'movie',
      title: '',
      posterPath: null,
      date: null,
      voteAverage: 0.0,
    );
  }
}
