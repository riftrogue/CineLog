import 'package:flutter/material.dart';
import 'package:cinelog/config/app_constants.dart';

/// Activity section for the home page showing recent user activity
class ActivitySection extends StatelessWidget {
  const ActivitySection({
    super.key,
    this.onSeeAllTap,
  });

  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.timeline,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onSeeAllTap != null)
                  TextButton(
                    onPressed: onSeeAllTap,
                    child: const Text(
                      AppConstants.seeAll,
                      style: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.star,
              text: 'You rated The Matrix 5 stars',
              time: '2 hours ago',
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.favorite,
              text: 'You liked Inception',
              time: '1 day ago',
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              icon: Icons.visibility,
              text: 'You watched Dune: Part Two',
              time: '3 days ago',
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Start logging movies to see your activity here',
                style: TextStyle(
                  color: AppConstants.textHintColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String text,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: AppConstants.textHintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}