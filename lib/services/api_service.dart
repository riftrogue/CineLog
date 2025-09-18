import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple TMDB API service focused on trending movies of the week.
class ApiService {
	ApiService({http.Client? client}) : _client = client ?? http.Client();

	static const String _apiKey = '81b26b91023ecc1b1ba634b981ad06ae';
	static const String _baseUrl = 'https://api.themoviedb.org/3';
	static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

	final http.Client _client;

		/// Fetch trending movies of the week.
		/// Returns a list of plain maps (id, title, posterPath, releaseDate, voteAverage).
		/// Supports pagination via [page] (1-based).
		Future<List<Map<String, dynamic>>> fetchTrendingMoviesWeek({int page = 1}) async {
			final uri = Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey&language=en-US&page=$page');

		final res = await _client.get(uri);
		if (res.statusCode != 200) {
			throw Exception('TMDB request failed: ${res.statusCode}');
		}

		final data = json.decode(res.body) as Map<String, dynamic>;
		final results = (data['results'] as List<dynamic>? ?? []);

		return results.map<Map<String, dynamic>>((raw) {
			final map = raw as Map<String, dynamic>;
			return {
				'id': map['id'] as int,
				'title': (map['title'] ?? map['name'] ?? '').toString(),
				'posterPath': map['poster_path'] as String?,
				'releaseDate': (map['release_date'] ?? map['first_air_date'] ?? '').toString(),
				'voteAverage': (map['vote_average'] is num) ? (map['vote_average'] as num).toDouble() : 0.0,
			};
		}).toList();
	}
}

