import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? maxDate,
  }) async {
    final now = DateTime.now();
    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DatePickerBottomSheet(
        initialDate: initialDate ?? now,
        maxDate: maxDate ?? now,
      ),
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