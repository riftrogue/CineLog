import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';
import 'package:cinelog/features/explore/popular_week_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Movie> _trending = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.fetchTrendingMoviesWeek();
      final movies = data.map((m) => Movie.fromMap(m)).toList();
      setState(() {
        _trending = movies;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            Text('Failed to load: $_error'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.black,
            title: const Text(
              'CineLog',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.tealAccent),
                onPressed: () {},
              ),
            ],
          ),
          // Header sliver
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PopularWeekPage(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Row(
                    children: const [
                      Text(
                        'Popular this week',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Responsive sliver grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent; // available width inside sliver
                final crossAxisCount = width < 600 ? 3 : (width < 900 ? 4 : 6);
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _PosterTile(movie: _trending[index]),
                    childCount: _trending.length,
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
        ],
      ),
    );
  }
}

class _PosterTile extends StatefulWidget {
  const _PosterTile({required this.movie});
  final Movie movie;

  @override
  State<_PosterTile> createState() => _PosterTileState();
}

class _PosterTileState extends State<_PosterTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : (_hovered ? 1.02 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          // TODO: navigate to movie detail
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF171B1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A2F34), width: 1),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Hero(
                tag: 'poster-${widget.movie.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.movie.posterPath != null
                        ? CachedNetworkImage(
                            imageUrl: '${ApiService.imageBaseUrl}${widget.movie.posterPath}',
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 200),
                            placeholder: (context, url) => _ShimmerPlaceholder(),
                            errorWidget: (context, url, error) => const _ErrorPoster(),
                          )
                        : const _ErrorPoster(),
                    // Long-press overlay area for title/rating tooltip (desktop friendly)
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      child: Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: widget.movie.title,
                              waitDuration: const Duration(milliseconds: 500),
                              child: const SizedBox(height: 1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Rating: ${widget.movie.voteAverage.toStringAsFixed(1)}',
                            waitDuration: const Duration(milliseconds: 500),
                            child: const SizedBox(height: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _c.value * 2, 0),
              end: Alignment(1 + _c.value * 2, 0),
              colors: const [
                Color(0xFF22272B),
                Color(0xFF2A2F34),
                Color(0xFF22272B),
              ],
              stops: const [0.25, 0.5, 0.75],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorPoster extends StatelessWidget {
  const _ErrorPoster();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.movie, size: 40, color: Colors.tealAccent),
      ),
    );
  }
}
