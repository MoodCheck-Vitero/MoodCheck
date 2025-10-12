import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  final List<String> weekDays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];

  final Map<int, int> moodCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  final Map<int, String> moodEmojis = {
    1: '😡',
    2: '😞',
    3: '😐',
    4: '🙂',
    5: '😄',
  };

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedMonth = DateFormat('MMMM yyyy').format(_focusedMonth);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final int startWeekday = firstDayOfMonth.weekday % 7;
    final int totalDays = lastDayOfMonth.day;
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final prevMonthLastDay = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    final List<Map<String, dynamic>> days = [];

    for (int i = 0; i < startWeekday; i++) {
      final dayNum = prevMonthLastDay - startWeekday + i + 1;
      days.add({'day': dayNum, 'current': false});
    }

    for (int d = 1; d <= totalDays; d++) {
      days.add({'day': d, 'current': true});
    }

    int nextDay = 1;
    while (days.length % 7 != 0) {
      days.add({'day': nextDay++, 'current': false});
    }

    final totalMoods = moodCount.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff009d03),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: const Text(
          "Calendar",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        toolbarHeight: 58,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(12),
          child: SizedBox(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Calendar Grid
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left, color: Colors.black),
                          onPressed: _previousMonth,
                        ),
                        Text(
                          formattedMonth,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right, color: Colors.black),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 7,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: weekDays
                          .map((d) => Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      itemCount: days.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final entry = days[index];
                        final int dayNumber = entry['day'] as int;
                        final bool isCurrent = entry['current'] as bool;
                        final Color textColor = isCurrent ? Colors.grey[800]! : Colors.grey[400]!;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Mood Count Card (Matching Insights Style)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mood Count",
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Total: $totalMoods",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: moodCount.entries.map((entry) {
                        final int mood = entry.key;
                        final int count = entry.value;
                        final String emoji = moodEmojis[mood] ?? '';

                        return Column(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 30)),
                            const SizedBox(height: 8),
                            Text(count.toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}