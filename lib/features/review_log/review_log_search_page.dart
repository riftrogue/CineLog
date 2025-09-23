import 'package:flutter/material.dart';
import 'package:cinelog/config/app_routes.dart';
import 'package:cinelog/features/review_log/review_log_search_controller.dart';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/shared/widgets/search_input_widget.dart';
import 'package:cinelog/shared/widgets/search_results_list.dart';

class ReviewLogSearchPage extends StatefulWidget {
  const ReviewLogSearchPage({super.key});

  @override
  State<ReviewLogSearchPage> createState() => _ReviewLogSearchPageState();
}

class _ReviewLogSearchPageState extends State<ReviewLogSearchPage> {
  late final ReviewLogSearchController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ReviewLogSearchController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _controller.search(query);
    } else {
      _controller.clearSearch();
    }
  }

  void _onSearchSubmitted(String query) {
    _controller.search(query);
  }

  void _onResultTap(SearchItem item) {
    Navigator.pushNamed(
      context,
      AppRoutes.reviewLogEntry,
      arguments: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Search to Review'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SearchInputWidget(
            controller: _searchController,
            onChanged: (_) {},
            onSubmitted: _onSearchSubmitted,
            hintText: 'Search movies, TV shows, people...',
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (!_controller.isLoading && _controller.results.isEmpty && _controller.currentQuery.isEmpty) {
                  return const _SearchHint();
                }

                return SearchResultsList(
                  results: _controller.results,
                  isLoading: _controller.isLoading,
                  onTap: _onResultTap,
                );
              },
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 48, color: Colors.tealAccent),
          SizedBox(height: 16),
          Text(
            'Search to log a review',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find movies, shows, or people to review',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
