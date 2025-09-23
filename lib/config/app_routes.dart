import 'package:flutter/material.dart';
import 'package:cinelog/core/app_scaffold.dart';
import 'package:cinelog/features/diary/diary_page.dart';
import 'package:cinelog/features/review_log/review_log_search_page.dart';
import 'package:cinelog/features/review_log/review_log_entry_page.dart';
import 'package:cinelog/features/profile/profile_page.dart';
import 'package:cinelog/shared/pages/movie_detail_page.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/models/search_item.dart';

/// Centralized route management for the app
class AppRoutes {
  // Route Names
  static const String home = '/';
  static const String diary = '/diary';
  static const String reviewLog = '/review-log';
  static const String reviewLogEntry = '/review-log/entry';
  static const String profile = '/profile';
  static const String movieDetail = '/movie-detail';

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(),
          settings: settings,
        );

      case diary:
        return MaterialPageRoute(
          builder: (_) => const DiaryPage(),
          settings: settings,
        );

      case reviewLog:
        return MaterialPageRoute(
          builder: (_) => const ReviewLogSearchPage(),
          settings: settings,
        );

      case reviewLogEntry:
        final args = settings.arguments as SearchItem?;
        return MaterialPageRoute(
          builder: (_) => ReviewLogEntryPage(
            item: args ?? SearchItem.empty(),
          ),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case movieDetail:
        final args = settings.arguments as Movie?;
        return MaterialPageRoute(
          builder: (_) => MovieDetailPage(
            movie: args ?? Movie.empty(),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }

  /// Navigate to a specific route with optional arguments
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.of(context).pushReplacementNamed(
        routeName,
        arguments: arguments,
      );
    } else {
      return Navigator.of(context).pushNamed(
        routeName,
        arguments: arguments,
      );
    }
  }

  /// Navigate to movie detail page
  static Future<void> navigateToMovieDetail(
    BuildContext context,
    Movie movie,
  ) {
    return navigateTo(context, movieDetail, arguments: movie);
  }

  /// Navigate to review log entry page
  static Future<void> navigateToReviewLogEntry(
    BuildContext context,
    SearchItem item,
  ) {
    return navigateTo(context, reviewLogEntry, arguments: item);
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navigate back with result
  static void navigateBackWithResult<T>(BuildContext context, T result) {
    Navigator.of(context).pop(result);
  }
}

/// Page shown when route is not found
class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}