import 'package:flutter/material.dart';
import 'person_widgets.dart';

/// Widget for displaying cast and crew information with tabs
/// Allows switching between cast and crew views
class CastCrewSection extends StatefulWidget {
  const CastCrewSection({
    super.key,
    required this.cast,
    required this.crew,
  });

  final List<Map<String, dynamic>> cast;
  final List<Map<String, dynamic>> crew;

  @override
  State<CastCrewSection> createState() => _CastCrewSectionState();
}

class _CastCrewSectionState extends State<CastCrewSection> {
  bool _showCast = true; // true = Cast, false = Crew

  @override
  Widget build(BuildContext context) {
    // Don't show if no data available
    if (widget.cast.isEmpty && widget.crew.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab headers
        Row(
          children: [
            _TabHeader(
              title: 'Cast',
              isSelected: _showCast,
              onTap: () => setState(() => _showCast = true),
            ),
            const SizedBox(width: 32),
            _TabHeader(
              title: 'Crew',
              isSelected: !_showCast,
              onTap: () => setState(() => _showCast = false),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal scrollable list
        SizedBox(
          height: 200,
          child: _buildPersonList(),
        ),
      ],
    );
  }

  Widget _buildPersonList() {
    final people = _showCast ? widget.cast : widget.crew;
    
    if (people.isEmpty) {
      return Center(
        child: Text(
          'No ${_showCast ? 'cast' : 'crew'} information available',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (context, index) {
        final person = people[index];
        return PersonTile(person: person, isCast: _showCast);
      },
      separatorBuilder: (context, _) => const SizedBox(width: 12),
      itemCount: people.length,
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });
  
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? Colors.tealAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}