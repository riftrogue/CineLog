import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';

/// Controller for the home page that manages data loading and state
class HomeController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  bool _isLoading = true;
  String? _error;
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;

  /// Initialize the controller and load data
  Future<void> initialize() async {
    await loadData();
  }

  /// Load all data for the home page
  Future<void> loadData() async {
    setLoading(true);
    setError(null);

    try {
      // Load data in parallel for better performance
      final results = await Future.wait([
        _loadTrendingMovies(),
        _loadPopularMovies(),
        _loadTopRatedMovies(),
      ]);

      _trendingMovies = results[0];
      _popularMovies = results[1];
      _topRatedMovies = results[2];

      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await loadData();
  }

  /// Load trending movies from API
  Future<List<Movie>> _loadTrendingMovies() async {
    try {
      final data = await _apiService.fetchTrendingMoviesWeek();
      return data.map((m) => Movie.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Failed to load trending movies: $e');
      return [];
    }
  }

  /// Load popular movies from API
  Future<List<Movie>> _loadPopularMovies() async {
    try {
      // For now, use trending movies as popular since API service doesn't have popular method
      final data = await _apiService.fetchTrendingMoviesWeek();
      return data.map((m) => Movie.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Failed to load popular movies: $e');
      return [];
    }
  }

  /// Load top rated movies from API
  Future<List<Movie>> _loadTopRatedMovies() async {
    try {
      // For now, use trending movies as top rated since API service doesn't have top rated method
      final data = await _apiService.fetchTrendingMoviesWeek();
      return data.map((m) => Movie.fromMap(m)).toList();
    } catch (e) {
      debugPrint('Failed to load top rated movies: $e');
      return [];
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error message
  void setError(String? errorMessage) {
    if (_error != errorMessage) {
      _error = errorMessage;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    setError(null);
  }

}