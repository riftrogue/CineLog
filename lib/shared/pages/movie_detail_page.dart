import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import '../movie_detail_controller.dart';
import '../widgets/cast_crew_section.dart';
import '../widgets/ratings_histogram.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.movie});
  final Movie movie;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MovieDetailController();
    _controller.initialize(widget.movie);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.error != null) {
          return Scaffold(
            appBar: AppBar(title: Text(_controller.displayTitle)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error loading details: ${_controller.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.retry,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 16),
                      _buildSynopsisSection(),
                      _buildRatingsSection(),
                      const SizedBox(height: 32),
                      CastCrewSection(
                        cast: _controller.cast,
                        crew: _controller.crew,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.backdropUrl != null)
              CachedNetworkImage(
                imageUrl: _controller.backdropUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(color: const Color(0xFF171B1E)),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Poster
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 120,
            height: 180,
            child: widget.movie.posterPath != null
                ? CachedNetworkImage(
                    imageUrl: 'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: const Color(0xFF2A2F34),
                    child: const Icon(Icons.movie, size: 48, color: Colors.tealAccent),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        // Title and info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controller.displayTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_controller.year.isNotEmpty)
                Text(
                  _controller.year,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              if (_controller.director.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${_controller.directorLabel}\n${_controller.director}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
              if (_controller.runtime.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _controller.runtime,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
              if (_controller.genres.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _controller.genres.map((genre) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.tealAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        genre['name'] as String? ?? '',
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsisSection() {
    if (_controller.overview.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _controller.toggleDescriptionExpansion,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            child: Text(
              _controller.overview,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: _controller.isDescriptionExpanded ? null : 3,
              overflow: _controller.isDescriptionExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
        ),
        if (!_controller.isDescriptionExpanded && _controller.hasLongOverview) ...[
          const SizedBox(height: 4),
          const Text(
            '...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RATINGS',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        RatingsHistogram(rating: _controller.voteAverage),
      ],
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F34),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _controller.onActionButtonTap(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF171B1E),
                  child: Icon(Icons.person, color: Colors.white70),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rate, log, review, add to list + more',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.more_horiz, color: Colors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}