import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

/// Widget for displaying a person (cast or crew member) in a tile format
class PersonTile extends StatelessWidget {
  const PersonTile({
    super.key,
    required this.person,
    required this.isCast,
  });

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
                      errorWidget: (context, url, error) => const PersonPlaceholder(),
                    )
                  : const PersonPlaceholder(),
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

/// Placeholder widget for when person profile image is not available
class PersonPlaceholder extends StatelessWidget {
  const PersonPlaceholder({super.key});
  
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