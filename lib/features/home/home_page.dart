import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/features/home/home_controller.dart';
import 'package:cinelog/features/home/home_search_page.dart';
import 'package:cinelog/features/home/widgets/section_header.dart';
import 'package:cinelog/features/home/widgets/popular_section.dart';
import 'package:cinelog/features/home/widgets/activity_section.dart';
import 'package:cinelog/config/app_constants.dart';
import 'package:cinelog/config/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onMovieTap(Movie movie) {
    AppRoutes.navigateToMovieDetail(context, movie);
  }

  void _onPopularSeeAll() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PopularMoviesPage(),
      ),
    );
  }

  void _onActivitySeeAll() {
    // Navigate to activity page when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity page coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppConstants.primaryColor,
            ),
          );
        }

        if (_controller.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppConstants.errorColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load: ${_controller.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _controller.refresh,
                  child: const Text(AppConstants.retryLabel),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          color: AppConstants.primaryColor,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: AppConstants.backgroundColor,
                title: const Text(
                  AppConstants.homeTitle,
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppConstants.primaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HomeSearchPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Popular This Week Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: AppConstants.popularThisWeek,
                  actionText: AppConstants.seeAll,
                  onActionTap: _onPopularSeeAll,
                ),
              ),

              // Popular Movies Horizontal List
              PopularSection(
                movies: _controller.trendingMovies,
                onMovieTap: _onMovieTap,
                onSeeAllTap: _onPopularSeeAll,
              ),

              // Activity Section
              ActivitySection(
                onSeeAllTap: _onActivitySeeAll,
              ),

              // Add some bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
