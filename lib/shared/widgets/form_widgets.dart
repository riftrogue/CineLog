import 'package:flutter/material.dart';

/// A customizable star rating widget that supports half stars
class StarRatingWidget extends StatelessWidget {
  const StarRatingWidget({
    super.key,
    required this.rating,
    required this.onChanged,
    this.starSize = 32.0,
    this.activeColor = Colors.tealAccent,
    this.inactiveColor = Colors.grey,
    this.starCount = 5,
  });

  final double rating; // 0 to starCount (supports half stars like 3.5)
  final ValueChanged<double> onChanged;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;
  final int starCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (i) {
        final idx = i + 1;
        final currentRating = rating;
        final isFull = currentRating >= idx;
        final isHalf = currentRating >= idx - 0.5 && currentRating < idx;
        
        return GestureDetector(
          onTap: () {
            if (isFull) {
              // If star is full, make it half
              onChanged(idx - 0.5);
            } else if (isHalf) {
              // If star is half, clear all stars from this position
              onChanged(idx - 1.0);
            } else {
              // If star is empty, make it full
              onChanged(idx.toDouble());
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFull ? Icons.star : (isHalf ? Icons.star_half : Icons.star_outline),
              color: (isFull || isHalf) ? activeColor : inactiveColor,
              size: starSize,
            ),
          ),
        );
      }),
    );
  }
}

/// A toggle button widget with icon and label
class TogglePillWidget extends StatelessWidget {
  const TogglePillWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.activeColor = Colors.tealAccent,
    this.inactiveColor = Colors.grey,
    this.width = 60.0,
    this.height = 60.0,
    this.maxLabelWidth = 80.0,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final double maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isActive ? activeColor : inactiveColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? activeColor : inactiveColor,
                    size: 24,
                  ),
                ),
                if (isActive)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            width: maxLabelWidth,
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple poster display widget
class SimplePosterWidget extends StatelessWidget {
  const SimplePosterWidget({
    super.key,
    required this.posterPath,
    this.width = 60.0,
    this.height = 90.0,
    this.borderRadius = 8.0,
    this.placeholder,
  });

  final String? posterPath;
  final double width;
  final double height;
  final double borderRadius;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: posterPath != null
            ? Image.network(
                posterPath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _defaultPlaceholder(),
              )
            : placeholder ?? _defaultPlaceholder(),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: const Color(0xFF2A2F34),
      child: const Icon(Icons.movie, color: Colors.tealAccent),
    );
  }
}