import 'dart:convert';
import 'package:http/http.dart' as http;

/// New TMDB API client targeting your Cloudflare Worker proxy.
/// Default baseUrl: https://tmdb-proxy.riftrogue.workers.dev
class TmdbApiService {
	TmdbApiService({
		String baseUrl = 'https://tmdb-proxy.riftrogue.workers.dev',
		http.Client? client,
	})  : _baseUrl = baseUrl,
				_client = client ?? http.Client();

	final String _baseUrl;
	final http.Client _client;

	static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

	Future<Map<String, dynamic>?> _get(
		String path, {
		Map<String, dynamic>? query,
	}) async {
		try {
			final uri = Uri.parse('$_baseUrl$path').replace(
				queryParameters: query?.map((k, v) => MapEntry(k, v.toString())),
			);
			final res = await _client.get(uri, headers: const {
				'Accept': 'application/json',
			});
			if (res.statusCode != 200) {
				return null;
			}
			return json.decode(res.body) as Map<String, dynamic>;
		} catch (_) {
			return null;
		}
	}

	// Search
	Future<Map<String, dynamic>?> searchMulti(String query, {int page = 1}) {
		return _get('/search/multi', query: {
			'query': query,
			'page': page,
		});
	}

	// Movies
	Future<Map<String, dynamic>?> moviePopular({int page = 1}) =>
			_get('/movie/popular', query: {'page': page});
	Future<Map<String, dynamic>?> movieTopRated({int page = 1}) =>
			_get('/movie/top_rated', query: {'page': page});
	Future<Map<String, dynamic>?> movieUpcoming({int page = 1}) =>
			_get('/movie/upcoming', query: {'page': page});
	Future<Map<String, dynamic>?> movieNowPlaying({int page = 1}) =>
			_get('/movie/now_playing', query: {'page': page});
	Future<Map<String, dynamic>?> movieDetails(int id) => _get('/movie/$id');
	Future<Map<String, dynamic>?> movieCredits(int id) => _get('/movie/$id/credits');

	// TV
	Future<Map<String, dynamic>?> tvPopular({int page = 1}) =>
			_get('/tv/popular', query: {'page': page});
	Future<Map<String, dynamic>?> tvTopRated({int page = 1}) =>
			_get('/tv/top_rated', query: {'page': page});
	Future<Map<String, dynamic>?> tvOnTheAir({int page = 1}) =>
			_get('/tv/on_the_air', query: {'page': page});
	Future<Map<String, dynamic>?> tvAiringToday({int page = 1}) =>
			_get('/tv/airing_today', query: {'page': page});
	Future<Map<String, dynamic>?> tvDetails(int id) => _get('/tv/$id');
	Future<Map<String, dynamic>?> tvSeason(int id, int seasonNumber) =>
			_get('/tv/$id/season/$seasonNumber');
	Future<Map<String, dynamic>?> tvCredits(int id) => _get('/tv/$id/credits');

	// People
	Future<Map<String, dynamic>?> personDetails(int id) => _get('/person/$id');
	Future<Map<String, dynamic>?> personMovieCredits(int id) =>
			_get('/person/$id/movie_credits');
	Future<Map<String, dynamic>?> personTvCredits(int id) =>
			_get('/person/$id/tv_credits');

	// Trending
	Future<Map<String, dynamic>?> trendingAllDay({int page = 1}) =>
			_get('/trending/all/day', query: {'page': page});
	Future<Map<String, dynamic>?> trendingAllWeek({int page = 1}) =>
			_get('/trending/all/week', query: {'page': page});
}

// Compatibility shim to avoid breaking existing code while migrating
// - Keeps imageBaseUrl constant and a minimal trending fetch used by Home/Popular pages.
class ApiService {
	ApiService({String? baseUrl, http.Client? client})
			: _impl = TmdbApiService(baseUrl: baseUrl ?? 'https://tmdb-proxy.riftrogue.workers.dev', client: client);

	static const String imageBaseUrl = TmdbApiService.imageBaseUrl;
	final TmdbApiService _impl;

	/// Returns a simplified list of items from trending-all-week results.
	Future<List<Map<String, dynamic>>> fetchTrendingMoviesWeek({int page = 1}) async {
		final data = await _impl.trendingAllWeek(page: page);
		final results = (data?['results'] as List<dynamic>? ?? []);
		return results.map<Map<String, dynamic>>((raw) {
			final map = raw as Map<String, dynamic>;
			return {
				'id': map['id'] as int,
				'title': (map['title'] ?? map['name'] ?? '').toString(),
				'posterPath': map['poster_path'] as String?,
				'releaseDate': (map['release_date'] ?? map['first_air_date'] ?? '').toString(),
				'voteAverage': (map['vote_average'] is num) ? (map['vote_average'] as num).toDouble() : 0.0,
				'mediaType': (map['media_type'] ?? 'movie').toString(),
			};
		}).toList();
	}
}

