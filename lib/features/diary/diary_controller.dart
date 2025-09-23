import 'package:flutter/material.dart';
import 'package:cinelog/features/diary/diary_entry.dart';

/// Controller for the diary page that manages diary entries and state
class DiaryController extends ChangeNotifier {
  // State variables
  bool _isLoading = false;
  String? _error;
  List<DiaryEntry> _entries = [];
  DateTime _selectedDate = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DiaryEntry> get entries => _entries;
  DateTime get selectedDate => _selectedDate;

  /// Get entries for a specific date
  List<DiaryEntry> get entriesForSelectedDate {
    return _entries.where((entry) {
      return entry.watchedDate.year == _selectedDate.year &&
          entry.watchedDate.month == _selectedDate.month &&
          entry.watchedDate.day == _selectedDate.day;
    }).toList();
  }

  /// Initialize the controller
  Future<void> initialize() async {
    await loadEntries();
  }

  /// Load diary entries (from local storage or API)
  Future<void> loadEntries() async {
    setLoading(true);
    setError(null);

    try {
      // TODO: Load from actual data source (SQLite, API, etc.)
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      
      _entries = [
        DiaryEntry(
          id: '1',
          movieId: 550,
          movieTitle: 'Fight Club',
          moviePosterPath: '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
          watchedDate: DateTime.now().subtract(const Duration(days: 1)),
          rating: 5.0,
          review: 'An absolute masterpiece. The cinematography, acting, and story are all perfect.',
          liked: true,
          rewatched: false,
        ),
        DiaryEntry(
          id: '2',
          movieId: 13,
          movieTitle: 'Forrest Gump',
          moviePosterPath: '/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
          watchedDate: DateTime.now().subtract(const Duration(days: 3)),
          rating: 4.5,
          review: 'A heartwarming story that never gets old.',
          liked: true,
          rewatched: true,
        ),
      ];

      setLoading(false);
    } catch (e) {
      setError(e.toString());
      setLoading(false);
    }
  }

  /// Add a new diary entry
  Future<void> addEntry(DiaryEntry entry) async {
    try {
      // TODO: Save to actual data source
      _entries.add(entry);
      notifyListeners();
    } catch (e) {
      setError('Failed to add entry: ${e.toString()}');
    }
  }

  /// Update an existing diary entry
  Future<void> updateEntry(DiaryEntry updatedEntry) async {
    try {
      final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        notifyListeners();
      }
    } catch (e) {
      setError('Failed to update entry: ${e.toString()}');
    }
  }

  /// Delete a diary entry
  Future<void> deleteEntry(String entryId) async {
    try {
      _entries.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
    } catch (e) {
      setError('Failed to delete entry: ${e.toString()}');
    }
  }

  /// Set the selected date for viewing entries
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
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

  /// Refresh entries
  Future<void> refresh() async {
    await loadEntries();
  }

  /// Get total number of entries
  int get totalEntries => _entries.length;

  /// Get total number of movies watched (unique movies)
  int get totalMoviesWatched {
    final uniqueMovies = <int>{};
    for (final entry in _entries) {
      uniqueMovies.add(entry.movieId);
    }
    return uniqueMovies.length;
  }

  /// Get average rating
  double get averageRating {
    if (_entries.isEmpty) return 0.0;
    final ratingsWithValues = _entries.where((entry) => entry.rating > 0);
    if (ratingsWithValues.isEmpty) return 0.0;
    
    final sum = ratingsWithValues.fold<double>(0, (sum, entry) => sum + entry.rating);
    return sum / ratingsWithValues.length;
  }

}