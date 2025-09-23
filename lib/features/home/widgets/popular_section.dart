import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/shared/widgets/poster_tile_widget.dart';
import 'package:cinelog/config/app_constants.dart';
import 'package:cinelog/services/api_service.dart';

/// Popular movies section for the home page
class PopularSection extends StatelessWidget {
  const PopularSection({
    super.key,
    required this.movies,
    this.onMovieTap,
    this.onSeeAllTap,
  });

  final List<Movie> movies;
  final Function(Movie)? onMovieTap;
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final columns = maxW < 600 ? 3 : (maxW < 900 ? 4 : 6);
          const spacing = 12.0;
          const outerPad = 24.0; // 12 left + 12 right
          final tileWidth = (maxW - outerPad - spacing * (columns - 1)) / columns;
          final tileHeight = tileWidth * 1.5; // aspect 2/3

          return SizedBox(
            height: tileHeight + 8, // a bit of breathing room
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return SizedBox(
                  width: tileWidth,
                  child: EnhancedPosterTile(
                    movie: movie,
                    onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
                  ),
                );
              },
              separatorBuilder: (context, _) => const SizedBox(width: spacing),
              itemCount: movies.length,
            ),
          );
        },
      ),
    );
  }
}

/// Full-screen popular movies page (for see all functionality)
class PopularMoviesPage extends StatefulWidget {
  const PopularMoviesPage({super.key});

  @override
  State<PopularMoviesPage> createState() => _PopularMoviesPageState();
}

class _PopularMoviesPageState extends State<PopularMoviesPage> {
  final _scrollController = ScrollController();
  final List<Movie> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_done || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() => _loading = true);
    
    try {
      if (reset) {
        _page = 1;
        _items.clear();
        _done = false;
      }
      
      // TODO: Use proper API service method when available
      // For now, using trending movies as placeholder
      final apiService = ApiService();
      final data = await apiService.fetchTrendingMoviesWeek(page: _page);
      final movies = data.map(Movie.fromMap).toList();
      
      setState(() {
        _items.addAll(movies);
        _page++;
        if (movies.isEmpty) _done = true;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.popularThisWeek),
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final crossAxisCount = width < 600 ? 3 : (width < 900 ? 4 : 6);
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _items.length) {
                          return const LoadingTile();
                        }
                        return PosterGridTile(movie: _items[index]);
                      },
                      childCount: _items.length + (_done ? 0 : 6),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 2 / 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  );
                },
              ),
            ),
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $_error'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

