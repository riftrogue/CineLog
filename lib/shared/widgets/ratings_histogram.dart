import 'package:flutter/material.dart';

/// Widget for displaying a ratings histogram with star rating
/// Shows a visual representation of rating distribution
class RatingsHistogram extends StatelessWidget {
  const RatingsHistogram({
    super.key,
    required this.rating,
  });

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