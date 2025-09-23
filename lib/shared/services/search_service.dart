import 'dart:async';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/services/api_service.dart';

/// Shared search service that provides common search functionality
/// Used by both Home Search and Review Log Search
class SearchService {
  static final TmdbApiService _api = TmdbApiService();
  
  /// Search for movies, TV shows, and people
  /// Returns a list of SearchItem objects
  static Future<List<SearchItem>> searchMulti(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      final data = await _api.searchMulti(query.trim());
      final list = (data?['results'] as List<dynamic>? ?? []);
      return list.map((e) => SearchItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow; // Let the calling code handle the error
    }
  }
  
  /// Create a debounced search function
  /// Returns a function that debounces search calls
  static Function(String) createDebouncedSearch({
    required Function(String) onSearch,
    Duration delay = const Duration(milliseconds: 400),
  }) {
    Timer? debounce;
    
    return (String query) {
      debounce?.cancel();
      debounce = Timer(delay, () {
        onSearch(query);
      });
    };
  }
}

/// Search state management helper
class SearchState<T> {
  final List<T> results;
  final bool loading;
  final String? error;
  final String query;
  
  const SearchState({
    this.results = const [],
    this.loading = false,
    this.error,
    this.query = '',
  });
  
  SearchState<T> copyWith({
    List<T>? results,
    bool? loading,
    String? error,
    String? query,
  }) {
    return SearchState<T>(
      results: results ?? this.results,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }
  
  /// Returns true if results are empty and query is not empty
  bool get hasNoResults => results.isEmpty && query.isNotEmpty && !loading;
  
  /// Returns true if should show search hint (empty query)
  bool get shouldShowHint => query.isEmpty && results.isEmpty;
}