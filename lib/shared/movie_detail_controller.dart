import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/movie_detail_data.dart';
import '../services/api_service.dart';

/// Controller for managing movie detail page state and business logic
/// Handles API calls, loading states, and data transformations
class MovieDetailController extends ChangeNotifier {
  final TmdbApiService _api = TmdbApiService();
  
  // Core data
  late final Movie _movie;
  MovieDetailData? _detailData;
  
  // UI state
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;
  String? _error;

  // Getters
  Movie get movie => _movie;
  MovieDetailData? get detailData => _detailData;
  bool get isLoading => _isLoading;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  String? get error => _error;
  
  // Convenience getters that delegate to detailData
  String get director => _detailData?.director ?? '';
  String get directorLabel => _detailData?.directorLabel ?? '';
  String get runtime => _detailData?.runtime ?? '';
  String get year => _detailData?.year ?? '';
  String get overview => _detailData?.overview ?? '';
  String? get backdropUrl => _detailData?.backdropUrl;
  List<Map<String, dynamic>> get genres => _detailData?.genres ?? [];
  double get voteAverage => _detailData?.voteAverage ?? _movie.voteAverage;
  List<Map<String, dynamic>> get cast => _detailData?.cast ?? [];
  List<Map<String, dynamic>> get crew => _detailData?.crew ?? [];
  String get displayTitle => _detailData?.displayTitle ?? _movie.title;
  bool get hasLongOverview => _detailData?.hasLongOverview ?? false;

  /// Initialize controller with movie data
  void initialize(Movie movie) {
    _movie = movie;
    _detailData = MovieDetailData.empty(
      mediaType: movie.mediaType,
      originalTitle: movie.title,
      originalReleaseDate: movie.releaseDate,
      originalVoteAverage: movie.voteAverage,
    );
    _loadDetails();
  }

  /// Load movie/TV details and credits from API
  Future<void> _loadDetails() async {
    _setLoading(true);
    _error = null;
    
    try {
      Future<Map<String, dynamic>?> detailsFuture;
      Future<Map<String, dynamic>?> creditsFuture;
      
      if (_movie.mediaType == 'tv') {
        detailsFuture = _api.tvDetails(_movie.id);
        creditsFuture = _api.tvCredits(_movie.id);
      } else {
        // Default to movie for 'movie' and unknown types
        detailsFuture = _api.movieDetails(_movie.id);
        creditsFuture = _api.movieCredits(_movie.id);
      }
      
      final results = await Future.wait([detailsFuture, creditsFuture]);
      
      _detailData = _detailData!.withData(
        details: results[0],
        credits: results[1],
      );
      
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  /// Toggle description expansion state
  void toggleDescriptionExpansion() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  /// Handle action button tap (rate, log, review)
  void onActionButtonTap(BuildContext context) {
    // TODO: Navigate to review/rate page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rate, log, review feature coming soon!'),
      ),
    );
  }

  /// Retry loading data after an error
  void retry() {
    if (_error != null) {
      _loadDetails();
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

}