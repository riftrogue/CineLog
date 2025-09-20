import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cinelog/models/search_item.dart';
import 'package:cinelog/services/api_service.dart';

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
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1900),
      lastDate: now,
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
    final dateText = _date != null ? df.format(_date!) : 'Pick a date';
    final posterUrl = widget.item.posterPath != null
        ? '${TmdbApiService.imageBaseUrl}${widget.item.posterPath}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('I Watched'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.displayTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(widget.item.mediaType.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Date + Rating + Like row
          Row(
            children: [
              const Text('Date'),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(dateText),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _StarRating(
                rating: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() => _liked = !_liked),
                icon: Icon(_liked ? Icons.favorite : Icons.favorite_border),
                color: _liked ? Colors.pinkAccent : Colors.white70,
                tooltip: 'Like',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Add review…'),
          const SizedBox(height: 6),
          TextField(
            controller: _reviewController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Write your thoughts…',
              filled: true,
              fillColor: const Color(0xFF171B1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2F34)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Add tags…'),
          const SizedBox(height: 6),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(
              hintText: 'Comma separated (e.g. horror, first-time watch)',
              filled: true,
              fillColor: const Color(0xFF171B1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2A2F34)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _PillIcon(label: 'First-time watch', icon: Icons.visibility),
              _PillIcon(label: 'No spoilers', icon: Icons.masks),
            ],
          )
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.onChanged});
  final double rating; // 0..5
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = rating >= idx;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(idx.toDouble()),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 24,
          ),
        );
      }),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF171B1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2A2F34)),
          ),
          child: Icon(icon, color: Colors.white70),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
