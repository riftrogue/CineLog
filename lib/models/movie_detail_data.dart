import '../services/api_service.dart';

/// Data model for movie/TV show details with computed properties
/// Handles all data transformations and business logic for movie details
class MovieDetailData {
  final Map<String, dynamic>? details;
  final Map<String, dynamic>? credits;
  final String mediaType;
  final String originalTitle;
  final String originalReleaseDate;
  final double originalVoteAverage;

  const MovieDetailData({
    required this.details,
    required this.credits,
    required this.mediaType,
    required this.originalTitle,
    required this.originalReleaseDate,
    required this.originalVoteAverage,
  });

  /// Director for movies or creator for TV shows
  String get director {
    if (mediaType == 'tv') {
      // For TV shows, get creators from details
      if (details == null) return '';
      final creators = details!['created_by'] as List<dynamic>? ?? [];
      if (creators.isNotEmpty) {
        final creatorNames = creators
            .map((c) => c['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        return creatorNames.isNotEmpty ? creatorNames.join(', ') : '';
      }
      return '';
    } else {
      // For movies, get director from crew
      if (credits == null) return '';
      final crew = credits!['crew'] as List<dynamic>? ?? [];
      final director = crew.firstWhere(
        (person) => person['job'] == 'Director',
        orElse: () => null,
      );
      return director?['name'] ?? '';
    }
  }

  /// Label for director/creator based on media type
  String get directorLabel {
    return mediaType == 'tv' ? 'CREATED BY' : 'DIRECTED BY';
  }

  /// Runtime information formatted for display
  String get runtime {
    if (details == null) return '';
    
    if (mediaType == 'tv') {
      // For TV shows, show episode runtime and number of seasons/episodes
      final episodeRuntime = details!['episode_run_time'] as List<dynamic>?;
      final seasons = details!['number_of_seasons'] as int?;
      final episodes = details!['number_of_episodes'] as int?;
      
      final parts = <String>[];
      if (episodeRuntime != null && episodeRuntime.isNotEmpty) {
        final avgRuntime = episodeRuntime.first as int;
        parts.add('${avgRuntime}m episodes');
      }
      if (seasons != null && seasons > 0) {
        parts.add('$seasons season${seasons > 1 ? 's' : ''}');
      }
      if (episodes != null && episodes > 0) {
        parts.add('$episodes episodes');
      }
      return parts.join(' • ');
    } else {
      // For movies, show total runtime
      final minutes = details!['runtime'] as int?;
      if (minutes == null || minutes == 0) return '';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    }
  }

  /// Release year extracted from date
  String get year {
    final date = originalReleaseDate;
    return date.isNotEmpty ? date.split('-').first : '';
  }

  /// Overview/synopsis text
  String get overview {
    return details?['overview'] ?? '';
  }

  /// Full backdrop image URL
  String? get backdropUrl {
    final path = details?['backdrop_path'] as String?;
    return path != null ? '${TmdbApiService.imageBaseUrl}$path' : null;
  }

  /// List of genres
  List<Map<String, dynamic>> get genres {
    if (details == null) return [];
    return (details!['genres'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// Vote average from details or fallback to original
  double get voteAverage {
    if (details == null) return originalVoteAverage;
    final rating = details!['vote_average'];
    if (rating is num) return rating.toDouble();
    return originalVoteAverage;
  }

  /// Cast members (limited to top 20)
  List<Map<String, dynamic>> get cast {
    if (credits == null) return [];
    return (credits!['cast'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .take(20)
        .toList();
  }

  /// Crew members (limited to top 20)
  List<Map<String, dynamic>> get crew {
    if (credits == null) return [];
    return (credits!['crew'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .take(20)
        .toList();
  }

  /// Whether we have valid data loaded
  bool get isLoaded => details != null && credits != null;

  /// Whether overview text is long enough to warrant expansion
  bool get hasLongOverview => overview.length > 150;

  /// Title to display (from details or fallback to original)
  String get displayTitle {
    if (details == null) return originalTitle;
    if (mediaType == 'tv') {
      return details!['name'] as String? ?? originalTitle;
    }
    return details!['title'] as String? ?? originalTitle;
  }

  /// Create empty instance for loading state
  static MovieDetailData empty({
    required String mediaType,
    required String originalTitle,
    required String originalReleaseDate,
    required double originalVoteAverage,
  }) {
    return MovieDetailData(
      details: null,
      credits: null,
      mediaType: mediaType,
      originalTitle: originalTitle,
      originalReleaseDate: originalReleaseDate,
      originalVoteAverage: originalVoteAverage,
    );
  }

  /// Create instance with loaded data
  MovieDetailData withData({
    required Map<String, dynamic>? details,
    required Map<String, dynamic>? credits,
  }) {
    return MovieDetailData(
      details: details,
      credits: credits,
      mediaType: mediaType,
      originalTitle: originalTitle,
      originalReleaseDate: originalReleaseDate,
      originalVoteAverage: originalVoteAverage,
    );
  }
}