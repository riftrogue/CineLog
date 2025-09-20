import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.movie});
  final Movie movie;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final _api = TmdbApiService();
  Map<String, dynamic>? _details;
  Map<String, dynamic>? _credits;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      Future<Map<String, dynamic>?> detailsFuture;
      Future<Map<String, dynamic>?> creditsFuture;
      
      if (widget.movie.mediaType == 'tv') {
        detailsFuture = _api.tvDetails(widget.movie.id);
        creditsFuture = _api.tvCredits(widget.movie.id);
      } else {
        // Default to movie for 'movie' and unknown types
        detailsFuture = _api.movieDetails(widget.movie.id);
        creditsFuture = _api.movieCredits(widget.movie.id);
      }
      
      final results = await Future.wait([detailsFuture, creditsFuture]);
      setState(() {
        _details = results[0];
        _credits = results[1];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String get _director {
    if (widget.movie.mediaType == 'tv') {
      // For TV shows, get creators from details
      if (_details == null) return '';
      final creators = _details!['created_by'] as List<dynamic>? ?? [];
      if (creators.isNotEmpty) {
        final creatorNames = creators.map((c) => c['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
        return creatorNames.isNotEmpty ? creatorNames.join(', ') : '';
      }
      return '';
    } else {
      // For movies, get director from crew
      if (_credits == null) return '';
      final crew = _credits!['crew'] as List<dynamic>? ?? [];
      final director = crew.firstWhere(
        (person) => person['job'] == 'Director',
        orElse: () => null,
      );
      return director?['name'] ?? '';
    }
  }

  String get _directorLabel {
    return widget.movie.mediaType == 'tv' ? 'CREATED BY' : 'DIRECTED BY';
  }

  String get _runtime {
    if (_details == null) return '';
    
    if (widget.movie.mediaType == 'tv') {
      // For TV shows, show episode runtime and number of seasons/episodes
      final episodeRuntime = _details!['episode_run_time'] as List<dynamic>?;
      final seasons = _details!['number_of_seasons'] as int?;
      final episodes = _details!['number_of_episodes'] as int?;
      
      final parts = <String>[];
      if (episodeRuntime != null && episodeRuntime.isNotEmpty) {
        final avgRuntime = episodeRuntime.first as int;
        parts.add('${avgRuntime}m episodes');
      }
      if (seasons != null && seasons > 0) {
        parts.add('$seasons season${seasons > 1 ? 's' : ''}');
      }
      if (episodes != null && episodes > 0) {
        parts.add('$episodes episodes');
      }
      return parts.join(' • ');
    } else {
      // For movies, show total runtime
      final minutes = _details!['runtime'] as int?;
      if (minutes == null || minutes == 0) return '';
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    }
  }

  String get _year {
    final date = widget.movie.releaseDate;
    return date.isNotEmpty ? date.split('-').first : '';
  }

  String get _overview {
    return _details?['overview'] ?? '';
  }

  String? get _backdropUrl {
    final path = _details?['backdrop_path'] as String?;
    return path != null ? '${TmdbApiService.imageBaseUrl}$path' : null;
  }

  List<Map<String, dynamic>> get _genres {
    if (_details == null) return [];
    return (_details!['genres'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  double get _actualRating {
    if (_details == null) return widget.movie.voteAverage;
    final rating = _details!['vote_average'];
    if (rating is num) return rating.toDouble();
    return widget.movie.voteAverage;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (_backdropUrl != null)
                    CachedNetworkImage(
                      imageUrl: _backdropUrl!,
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                  imageUrl: '${TmdbApiService.imageBaseUrl}${widget.movie.posterPath}',
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
                              widget.movie.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_year.isNotEmpty)
                              Text(
                                _year,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            if (_director.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '$_directorLabel\n$_director',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (_runtime.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                _runtime,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                            if (_genres.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _genres.map((genre) {
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
                  ),
                  const SizedBox(height: 16),
                  // Synopsis
                  if (_overview.isNotEmpty) ...[
                    Text(
                      _overview,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Ratings section
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
                  _RatingsHistogram(rating: _actualRating),
                  const SizedBox(height: 32),
                  // Cast & Crew section
                  _CastCrewSection(credits: _credits),
                  const SizedBox(height: 24),
                  // Action button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2F34),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: Navigate to review/rate page
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rate, log, review feature coming soon!')),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF171B1E),
                                child: Icon(Icons.person, color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Rate, log, review, add to list + more',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Icon(Icons.more_horiz, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CastCrewSection extends StatefulWidget {
  const _CastCrewSection({required this.credits});
  final Map<String, dynamic>? credits;

  @override
  State<_CastCrewSection> createState() => _CastCrewSectionState();
}

class _CastCrewSectionState extends State<_CastCrewSection> {
  bool _showCast = true; // true = Cast, false = Crew

  List<Map<String, dynamic>> get _cast {
    if (widget.credits == null) return [];
    return (widget.credits!['cast'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .take(20)
        .toList();
  }

  List<Map<String, dynamic>> get _crew {
    if (widget.credits == null) return [];
    return (widget.credits!['crew'] as List<dynamic>? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .take(20)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.credits == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab headers
        Row(
          children: [
            _TabHeader(
              title: 'Cast',
              isSelected: _showCast,
              onTap: () => setState(() => _showCast = true),
            ),
            const SizedBox(width: 32),
            _TabHeader(
              title: 'Crew',
              isSelected: !_showCast,
              onTap: () => setState(() => _showCast = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal scrollable list
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemBuilder: (context, index) {
              final person = _showCast ? _cast[index] : _crew[index];
              return _PersonTile(person: person, isCast: _showCast);
            },
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemCount: _showCast ? _cast.length : _crew.length,
          ),
        ),
      ],
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.tealAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person, required this.isCast});
  final Map<String, dynamic> person;
  final bool isCast;

  @override
  Widget build(BuildContext context) {
    final name = person['name'] as String? ?? 'Unknown';
    final profilePath = person['profile_path'] as String?;
    final role = isCast 
        ? (person['character'] as String? ?? '')
        : (person['job'] as String? ?? '');

    final imageUrl = profilePath != null 
        ? '${TmdbApiService.imageBaseUrl}$profilePath'
        : null;

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 120,
              height: 120,
              color: const Color(0xFF2A2F34),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const _PersonPlaceholder(),
                    )
                  : const _PersonPlaceholder(),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (role.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              role,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonPlaceholder extends StatelessWidget {
  const _PersonPlaceholder();
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.white70,
      ),
    );
  }
}

class _RatingsHistogram extends StatelessWidget {
  const _RatingsHistogram({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    // Mock histogram data - in a real app, you'd get this from your API
    final bars = [0.1, 0.15, 0.25, 0.4, 0.7, 0.9, 0.6, 0.3, 0.2, 0.1];
    final normalizedRating = (rating / 2).clamp(0.0, 5.0); // Convert 10-scale to 5-scale
    
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars.length, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    height: bars[index] * 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < normalizedRating ? Colors.green : Colors.grey,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          normalizedRating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}