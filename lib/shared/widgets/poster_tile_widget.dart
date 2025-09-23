import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cinelog/models/movie.dart';
import 'package:cinelog/services/api_service.dart';
import 'package:cinelog/shared/pages/movie_detail_page.dart';

/// A reusable poster tile widget that supports different styles and interactions
class PosterTileWidget extends StatefulWidget {
  const PosterTileWidget({
    super.key,
    required this.movie,
    this.showHoverEffects = false,
    this.showTooltips = false,
    this.aspectRatio = 2 / 3,
    this.borderRadius = 10.0,
    this.onTap,
  });

  final Movie movie;
  final bool showHoverEffects;
  final bool showTooltips;
  final double aspectRatio;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  State<PosterTileWidget> createState() => _PosterTileWidgetState();
}

class _PosterTileWidgetState extends State<PosterTileWidget> {
  bool _hovered = false;
  bool _pressed = false;

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MovieDetailPage(movie: widget.movie),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.showHoverEffects 
        ? (_pressed ? 0.97 : (_hovered ? 1.02 : 1.0))
        : 1.0;

    Widget child = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF171B1E),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: const Color(0xFF2A2F34), width: 1),
        boxShadow: widget.showHoverEffects && _hovered
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
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Hero(
            tag: 'poster-${widget.movie.id}',
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPosterImage(),
                if (widget.showTooltips) _buildTooltipOverlay(),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.showHoverEffects) {
      child = AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: child,
      );
    }

    return MouseRegion(
      onEnter: widget.showHoverEffects ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.showHoverEffects ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        onTapDown: widget.showHoverEffects ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: widget.showHoverEffects ? () => setState(() => _pressed = false) : null,
        onTapUp: widget.showHoverEffects ? (_) => setState(() => _pressed = false) : null,
        onTap: _handleTap,
        child: child,
      ),
    );
  }

  Widget _buildPosterImage() {
    if (widget.movie.posterPath != null) {
      return CachedNetworkImage(
        imageUrl: '${ApiService.imageBaseUrl}${widget.movie.posterPath}',
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (context, url) => const ShimmerPlaceholder(),
        errorWidget: (context, url, error) => const ErrorPoster(),
      );
    }
    return const ErrorPoster();
  }

  Widget _buildTooltipOverlay() {
    return Positioned(
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
    );
  }
}

/// Loading placeholder with shimmer effect
class ShimmerPlaceholder extends StatefulWidget {
  const ShimmerPlaceholder({super.key});

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
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

/// Error poster fallback
class ErrorPoster extends StatelessWidget {
  const ErrorPoster({super.key});

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

/// Simple loading tile for grid layouts
class LoadingTile extends StatelessWidget {
  const LoadingTile({
    super.key,
    this.borderRadius = 10.0,
  });

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF171B1E),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFF2A2F34), width: 1),
      ),
    );
  }
}

/// Grid-specific poster tile for consistent grid layouts
class PosterGridTile extends StatelessWidget {
  const PosterGridTile({
    super.key,
    required this.movie,
    this.onTap,
  });

  final Movie movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PosterTileWidget(
      movie: movie,
      showHoverEffects: false,
      showTooltips: false,
      onTap: onTap,
    );
  }
}

/// Enhanced poster tile with hover effects for feature displays
class EnhancedPosterTile extends StatelessWidget {
  const EnhancedPosterTile({
    super.key,
    required this.movie,
    this.onTap,
  });

  final Movie movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PosterTileWidget(
      movie: movie,
      showHoverEffects: true,
      showTooltips: true,
      onTap: onTap,
    );
  }
}