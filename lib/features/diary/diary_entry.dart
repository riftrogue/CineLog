/// Diary entry model representing a movie watching record
class DiaryEntry {
  final String id;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final DateTime watchedDate;
  final double rating; // 0.0 to 5.0, 0.0 means no rating
  final String? review;
  final bool liked;
  final bool rewatched;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DiaryEntry({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.watchedDate,
    this.rating = 0.0,
    this.review,
    this.liked = false,
    this.rewatched = false,
    this.tags = const [],
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? watchedDate;

  /// Create DiaryEntry from map
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as String,
      movieId: map['movieId'] as int,
      movieTitle: map['movieTitle'] as String,
      moviePosterPath: map['moviePosterPath'] as String?,
      watchedDate: DateTime.parse(map['watchedDate'] as String),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      review: map['review'] as String?,
      liked: map['liked'] as bool? ?? false,
      rewatched: map['rewatched'] as bool? ?? false,
      tags: (map['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert DiaryEntry to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'watchedDate': watchedDate.toIso8601String(),
      'rating': rating,
      'review': review,
      'liked': liked,
      'rewatched': rewatched,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create empty DiaryEntry
  factory DiaryEntry.empty() {
    return DiaryEntry(
      id: '',
      movieId: 0,
      movieTitle: '',
      watchedDate: DateTime.now(),
    );
  }

  /// Copy with modifications
  DiaryEntry copyWith({
    String? id,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    DateTime? watchedDate,
    double? rating,
    String? review,
    bool? liked,
    bool? rewatched,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      watchedDate: watchedDate ?? this.watchedDate,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      liked: liked ?? this.liked,
      rewatched: rewatched ?? this.rewatched,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get formatted date string
  String get formattedDate {
    return '${watchedDate.day}/${watchedDate.month}/${watchedDate.year}';
  }

  /// Get rating as stars string
  String get ratingStars {
    if (rating == 0) return 'No rating';
    final fullStars = rating.floor();
    final hasHalf = rating - fullStars >= 0.5;
    final stars = '★' * fullStars + (hasHalf ? '½' : '');
    return '$stars (${rating.toStringAsFixed(1)})';
  }

  /// Check if entry has a review
  bool get hasReview => review != null && review!.trim().isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DiaryEntry(id: $id, movieTitle: $movieTitle, watchedDate: $watchedDate, rating: $rating)';
  }
}
