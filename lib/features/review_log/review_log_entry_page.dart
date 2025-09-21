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
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DatePickerBottomSheet(
        initialDate: _date ?? now,
        maxDate: now,
      ),
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
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
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
          
          const Divider(color: Color(0xFF2A2F34), height: 1),
          
          // Date Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: _pickDate,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Text('Date', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                              child: const Icon(Icons.close, color: Colors.white54, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: Color(0xFF2A2F34), height: 1),
          
          // Rating and Like Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text('Rate', style: TextStyle(color: Colors.white70, fontSize: 16)),
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
                              color: _liked ? Colors.red : Colors.white54,
                              size: 28,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          const Text('Like', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(color: Color(0xFF2A2F34), height: 1),
          
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
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ),
          
          const Divider(color: Color(0xFF2A2F34), height: 1),
          
          // Bottom Icons Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _PillIcon(label: 'First-time watch', icon: Icons.visibility),
                _PillIcon(label: 'No spoilers', icon: Icons.security),
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
              color: (isFull || isHalf) ? const Color(0xFF5A7A8A) : const Color(0xFF5A7A8A),
              size: 32,
            ),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF3A4A5A), width: 1),
          ),
          child: Icon(icon, color: const Color(0xFF5A7A8A), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          style: const TextStyle(color: Color(0xFF5A7A8A), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DatePickerBottomSheet extends StatefulWidget {
  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.maxDate,
  });
  
  final DateTime initialDate;
  final DateTime maxDate;

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late PageController _pageController;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
    
    // Calculate how many months back from now
    final now = DateTime.now();
    _currentPageIndex = (now.year - _currentMonth.year) * 12 + (now.month - _currentMonth.month);
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
      final now = DateTime.now();
      _currentMonth = DateTime(now.year, now.month - index);
    });
  }

  void _previousMonth() {
    if (_currentPageIndex < 120) { // Limit to 10 years back
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextMonth() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<DateTime> _getDaysInMonthForDate(DateTime monthDate) {
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0);
    final daysInMonth = <DateTime>[];
    
    // Add empty days for the start of the week
    final startWeekday = firstDay.weekday % 7;
    for (int i = 0; i < startWeekday; i++) {
      daysInMonth.add(firstDay.subtract(Duration(days: startWeekday - i)));
    }
    
    // Add all days in the month
    for (int day = 1; day <= lastDay.day; day++) {
      daysInMonth.add(DateTime(monthDate.year, monthDate.month, day));
    }
    
    return daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Container(
      height: 450,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: Icon(
                        Icons.chevron_left, 
                        color: _currentPageIndex < 120 ? Colors.white70 : Colors.white30,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_currentMonth),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: Icon(
                        Icons.chevron_right, 
                        color: _currentPageIndex > 0 ? Colors.white70 : Colors.white30,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  child: const Text('Done', style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            ),
          ),
          
          // Weekday headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Swipeable Calendar grid
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              reverse: true, // Swipe left to go to previous month
              itemCount: 121, // Current month + 120 months back (10 years)
              itemBuilder: (context, pageIndex) {
                final monthDate = DateTime(now.year, now.month - pageIndex);
                final daysInMonth = _getDaysInMonthForDate(monthDate);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemCount: daysInMonth.length,
                    itemBuilder: (context, index) {
                      final date = daysInMonth[index];
                      final isCurrentMonth = date.month == monthDate.month;
                      final isSelected = _selectedDate.year == date.year && 
                                       _selectedDate.month == date.month && 
                                       _selectedDate.day == date.day;
                      final isToday = now.year == date.year && 
                                    now.month == date.month && 
                                    now.day == date.day;
                      final isFuture = date.isAfter(now);
                      
                      return GestureDetector(
                        onTap: !isFuture ? () {
                          setState(() => _selectedDate = date);
                        } : null,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.tealAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday && !isSelected ? Border.all(color: Colors.tealAccent.withOpacity(0.5)) : null,
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: isFuture ? Colors.white24 :
                                       isSelected ? Colors.black :
                                       isCurrentMonth ? Colors.white : Colors.white38,
                                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }


}
