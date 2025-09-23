import 'package:flutter/material.dart';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/shared/services/search_service.dart';

/// Controller for managing home search state and functionality
class HomeSearchController extends ChangeNotifier {
  List<SearchItem> _results = [];
  bool _isLoading = false;
  String _currentQuery = '';

  List<SearchItem> get results => _results;
  bool get isLoading => _isLoading;
  String get currentQuery => _currentQuery;
  bool get hasResults => _results.isNotEmpty;
  bool get showEmptyState => !_isLoading && _results.isEmpty && _currentQuery.isNotEmpty;

  /// Search for movies and TV shows
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _clearResults();
      return;
    }

    _currentQuery = query.trim();
    _setLoading(true);

    try {
      final searchResults = await SearchService.searchMulti(_currentQuery);
      _results = searchResults;
    } catch (e) {
      debugPrint('Home search error: $e');
      _results = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Clear search results and query
  void clearSearch() {
    _clearResults();
    _currentQuery = '';
  }

  void _clearResults() {
    _results = [];
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}