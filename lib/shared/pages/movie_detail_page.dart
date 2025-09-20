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
      final detailsFuture = _api.movieDetails(widget.movie.id);
      final creditsFuture = _api.movieCredits(widget.movie.id);
      
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
    if (_credits == null) return '';
    final crew = _credits!['crew'] as List<dynamic>? ?? [];
    final director = crew.firstWhere(
      (person) => person['job'] == 'Director',
      orElse: () => null,
    );
    return director?['name'] ?? '';
  }

  String get _runtime {
    if (_details == null) return '';
    final minutes = _details!['runtime'] as int?;
    if (minutes == null || minutes == 0) return '';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
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
            expandedHeight: 300,
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
                                'DIRECTED BY\n$_director',
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
                  _RatingsHistogram(rating: widget.movie.voteAverage),
                  const SizedBox(height: 32),
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