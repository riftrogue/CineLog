import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/services/api_service.dart';
import 'package:cinelog/shared/widgets/custom_date_picker.dart';

class ReviewLogEntryPage extends StatefulWidget {
  const ReviewLogEntryPage({super.key, required this.item});
  final SearchItem item;

  @override
  State<ReviewLogEntryPage> createState() => _ReviewLogEntryPageState();
}

class _ReviewLogEntryPageState extends State<ReviewLogEntryPage> {
  DateTime? _date = DateTime.now();
  double _rating = 0;
  bool _liked = false;
  bool _firstTimeWatch = false;
  bool _noSpoilers = false;
  final _reviewController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await CustomDatePicker.show(
      context: context,
      initialDate: _date ?? now,
      maxDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    // For now, just pop with a basic result. Integrate with persistence later.
    Navigator.of(context).pop({
      'id': widget.item.id,
      'mediaType': widget.item.mediaType,
      'title': widget.item.title,
      'date': _date?.toIso8601String(),
      'rating': _rating,
      'liked': _liked,
      'review': _reviewController.text.trim(),
      'tags': _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE d MMMM, yyyy');
    final dateText = _date != null ? df.format(_date!) : 'Add date';
    final posterUrl = widget.item.posterPath != null
        ? '${TmdbApiService.imageBaseUrl}${widget.item.posterPath}'
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('I Watched', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.tealAccent),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Movie Header Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 90,
                    child: posterUrl == null
                        ? Container(
                            color: const Color(0xFF2A2F34),
                            child: const Icon(Icons.movie, color: Colors.tealAccent),
                          )
                        : CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.displayTitle, 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          Divider(color: Colors.grey.withOpacity(0.3), height: 1),
          
          // Date Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: _pickDate,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateText, 
                            style: TextStyle(
                              color: _date != null ? Colors.white : Colors.white54, 
                              fontSize: 16
                            ),
                          ),
                          if (_date != null)
                            GestureDetector(
                              onTap: () => setState(() => _date = null),
                              child: const Icon(Icons.close, color: Colors.grey, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Divider(color: Colors.grey.withOpacity(0.3), height: 1),
          
          // Rating and Like Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Rate', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      _StarRating(
                        rating: _rating,
                        onChanged: (v) => setState(() => _rating = v),
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _liked = !_liked),
                            icon: Icon(
                              _liked ? Icons.favorite : Icons.favorite_border,
                              color: _liked ? Colors.tealAccent : Colors.grey,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const Text('Like', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.grey.withOpacity(0.3), height: 1),
          
          // Review Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _reviewController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add review...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),
          
          Divider(color: Colors.grey.withOpacity(0.3), height: 1),
          
          // Bottom Icons Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PillIcon(
                  label: _firstTimeWatch ? "I've seen this before" : 'First-time watch',
                  icon: Icons.visibility,
                  isActive: _firstTimeWatch,
                  onTap: () => setState(() => _firstTimeWatch = !_firstTimeWatch),
                ),
                _PillIcon(
                  label: _noSpoilers ? 'Contains spoilers' : 'No spoilers',
                  icon: Icons.security,
                  isActive: _noSpoilers,
                  onTap: () => setState(() => _noSpoilers = !_noSpoilers),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onChanged});
  final double rating; // 0..5 (supports half stars like 3.5)
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
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
              color: (isFull || isHalf) ? Colors.tealAccent : Colors.grey,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({
    required this.label, 
    required this.icon, 
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.tealAccent.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isActive ? Colors.tealAccent : Colors.grey.withOpacity(0.5), 
                      width: 1
                    ),
                  ),
                  child: Icon(
                    icon, 
                    color: isActive ? Colors.tealAccent : Colors.grey, 
                    size: 24
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
                        color: Colors.tealAccent,
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
            width: 80,
            child: Text(
              label, 
              style: TextStyle(
                color: isActive ? Colors.tealAccent : Colors.grey, 
                fontSize: 12
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


