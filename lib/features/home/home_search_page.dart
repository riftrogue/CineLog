import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';
import 'package:cinelog/features/explore/popular_week_page.dart' show MovieDetailPage;

class HomeSearchPage extends StatefulWidget {
  const HomeSearchPage({super.key});

  @override
  State<HomeSearchPage> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState extends State<HomeSearchPage> {
  final _api = TmdbApiService();
  final _controller = TextEditingController();
  Timer? _debounce;

  List<SearchItem> _results = const [];
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(value.trim());
    });
    setState(() {});
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _error = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.searchMulti(query);
      final list = (data?['results'] as List<dynamic>? ?? []);
      final items = list.map((e) => SearchItem.fromMap(e as Map<String, dynamic>)).toList();
      setState(() => _results = items);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(SearchItem item) {
    if (item.mediaType == 'movie' || item.mediaType == 'tv') {
      // Convert to our lightweight Movie used by MovieDetailPage
      final m = Movie(
        id: item.id,
        title: item.displayTitle,
        posterPath: item.posterPath,
        releaseDate: item.date ?? '',
        voteAverage: 0,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MovieDetailPage(movie: m)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search movies, series…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF171B1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2F34)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2F34)),
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Error: $_error'),
            ),
          Expanded(
            child: _results.isEmpty && (_controller.text.isEmpty)
                ? const _SearchHint()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      if (item.mediaType != 'movie' && item.mediaType != 'tv') {
                        return const SizedBox.shrink();
                      }
                      return ListTile(
                        onTap: () => _openDetail(item),
                        leading: _PosterThumb(path: item.posterPath),
                        title: Text(item.displayTitle),
                        subtitle: Text(
                          [if (item.year != null) item.year!, item.mediaType.toUpperCase()].join(' · '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      );
                    },
                    separatorBuilder: (context, _) => const Divider(height: 1),
                    itemCount: _results.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search, size: 48, color: Colors.tealAccent),
          SizedBox(height: 12),
          Text('Search for a movie or show'),
        ],
      ),
    );
  }
}

class _PosterThumb extends StatelessWidget {
  const _PosterThumb({required this.path});
  final String? path;
  @override
  Widget build(BuildContext context) {
    final url = path == null ? null : '${TmdbApiService.imageBaseUrl}$path';
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 48,
        height: 72,
        child: url == null
            ? Container(
                color: const Color(0xFF2A2F34),
                child: const Icon(Icons.movie, color: Colors.tealAccent),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
