import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';
import 'package:cinelog/shared/pages/movie_detail_page.dart';

class PopularWeekPage extends StatefulWidget {
  const PopularWeekPage({super.key});

  @override
  State<PopularWeekPage> createState() => _PopularWeekPageState();
}

class _PopularWeekPageState extends State<PopularWeekPage> {
  final _api = ApiService();
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
      final data = await _api.fetchTrendingMoviesWeek(page: _page);
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
      appBar: AppBar(title: const Text('Popular this week')),
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
                          return const _LoadingTile();
                        }
                        return _PosterTileGrid(movie: _items[index]);
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

class _PosterTileGrid extends StatelessWidget {
  const _PosterTileGrid({required this.movie});
  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: Hero(
        tag: 'poster-${movie.id}',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF171B1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF2A2F34), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: movie.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: '${ApiService.imageBaseUrl}${movie.posterPath}',
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.movie, size: 40, color: Colors.tealAccent),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171B1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2F34), width: 1),
      ),
    );
  }
}


