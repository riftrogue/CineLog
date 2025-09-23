import 'package:flutter/material.dart';

/// App-wide constants including colors, API keys, and strings
class AppConstants {
  // API Configuration
  static const String tmdbApiKey = 'your_api_key_here';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // App Colors
  static const Color primaryColor = Colors.tealAccent;
  static const Color backgroundColor = Colors.black;
  static const Color surfaceColor = Color(0xFF171B1E);
  static const Color borderColor = Color(0xFF2A2F34);
  static const Color errorColor = Colors.red;
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Colors.white70;
  static const Color textHintColor = Colors.grey;

  // App Strings
  static const String appName = 'CineLog';
  static const String homeTitle = 'CineLog';
  static const String reviewLogTitle = 'Review Log';
  static const String activityTitle = 'Activity';
  static const String profileTitle = 'Profile';
  static const String diaryTitle = 'Diary';

  // Tab Indices
  static const int homeTab = 0;
  static const int reviewLogTab = 1;
  static const int activityTab = 2;
  static const int profileTab = 3;

  // Popular Section
  static const String popularThisWeek = 'Popular this week';
  static const String seeAll = 'See all';

  // Search
  static const String searchHint = 'Search for movies & TV shows';
  static const String noResultsFound = 'No results found';
  static const String searchToStart = 'Start searching for movies & TV shows';

  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String genericError = 'Something went wrong';
  static const String loadingFailed = 'Failed to load data';
  static const String retryLabel = 'Retry';

  // Review Entry
  static const String iWatched = 'I Watched';
  static const String addReview = 'Add review...';
  static const String addDate = 'Add date';
  static const String firstTimeWatch = 'First-time watch';
  static const String seenBefore = "I've seen this before";
  static const String noSpoilers = 'No spoilers';
  static const String containsSpoilers = 'Contains spoilers';
}