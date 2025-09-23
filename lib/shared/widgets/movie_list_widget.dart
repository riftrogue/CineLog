import 'package:flutter/material.dart';
import '../../models/search_item.dart';

/// A reusable widget for displaying lists of movies or TV shows
/// Used in both home search and review log search features
class MovieListWidget extends StatelessWidget {
  final List<SearchItem> items;
  final bool isLoading;
  final String? errorMessage;
  final bool showLoadingIndicator;
  final Function(SearchItem item) onItemTap;
  final ScrollController? scrollController;
  final String emptyStateMessage;

  const MovieListWidget({
    super.key,
    required this.items,
    required this.isLoading,
    required this.onItemTap,
    this.errorMessage,
    this.showLoadingIndicator = false,
    this.scrollController,
    this.emptyStateMessage = 'No results found',
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return _buildErrorState(context);
    }

    if (items.isEmpty && !isLoading) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (showLoadingIndicator && isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: items.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final item = items[index];
              return _buildMovieItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieItem(BuildContext context, SearchItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => onItemTap(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie poster
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: item.posterPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w300${item.posterPath}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPosterPlaceholder(context),
                        ),
                      )
                    : _buildPosterPlaceholder(context),
              ),
              const SizedBox(width: 16),
              // Movie details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.year != null)
                      Text(
                        item.year!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    const SizedBox(height: 8),
                    // Movie type indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.mediaType == 'tv' ? 'TV Show' : 'Movie',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.movie,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyStateMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


}

/// A specialized version for infinite scroll scenarios
class InfiniteScrollMovieList extends StatelessWidget {
  final List<SearchItem> items;
  final bool isLoadingMore;
  final bool hasMoreResults;
  final String? errorMessage; 
  final Function(SearchItem item) onItemTap;
  final VoidCallback? onLoadMore;
  final String emptyStateMessage;

  const InfiniteScrollMovieList({
    super.key,
    required this.items,
    required this.isLoadingMore,
    required this.hasMoreResults,
    required this.onItemTap,
    this.errorMessage,
    this.onLoadMore,
    this.emptyStateMessage = 'No results found',
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            hasMoreResults &&
            !isLoadingMore &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: MovieListWidget(
        items: items,
        isLoading: isLoadingMore,
        errorMessage: errorMessage,
        onItemTap: onItemTap,
        emptyStateMessage: emptyStateMessage,
        showLoadingIndicator: false, // We show loading at the bottom instead
      ),
    );
  }
}