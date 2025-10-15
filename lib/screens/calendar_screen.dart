import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';
import '../widgets/mini_entry_editor.dart';

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

  final DatabaseService _db = DatabaseService();
  Map<String, Map<String, dynamic>> entriesByDate = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthEntries();
  }

  Future<void> _loadMonthEntries() async {
    setState(() {
      isLoading = true;
      entriesByDate.clear();
      moodCount.updateAll((key, value) => 0);
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final month = _focusedMonth.month;
    final year = _focusedMonth.year;

    final entries = await _db.getEntriesForMonth(user.id, year, month);

    for (var e in entries) {
      final dateStr = e['entry_date'];
      entriesByDate[dateStr] = e;

      final int mood = e['mood'] ?? 0;
      if (mood >= 1 && mood <= 5) {
        moodCount[mood] = (moodCount[mood] ?? 0) + 1;
      }
    }

    final prevEntries = await _db.getEntriesForMonth(
      user.id,
      _focusedMonth.year,
      _focusedMonth.month - 1,
    );
    final nextEntries = await _db.getEntriesForMonth(
      user.id,
      _focusedMonth.year,
      _focusedMonth.month + 1,
    );

    for (var e in prevEntries) {
      entriesByDate[e['entry_date']] = e;
    }
    for (var e in nextEntries) {
      entriesByDate[e['entry_date']] = e;
    }

    setState(() => isLoading = false);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadMonthEntries();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadMonthEntries();
  }

  Future<void> _openDayEditor(BuildContext context, DateTime date) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existing = await _db.getEntryByDate(user.id, dateStr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MiniEntryEditor(
        entryDate: date,
        initialEntry: existing,
        onSaved: _loadMonthEntries,
        onCancelled: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedMonth = DateFormat('MMMM yyyy').format(_focusedMonth);
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final int startWeekday = firstDayOfMonth.weekday % 7;
    final int totalDays = lastDayOfMonth.day;

    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    final prevMonthLastDay =
        DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_left,
                                color: Colors.black),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            formattedMonth,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_right,
                                color: Colors.black),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          GridView.count(
                            crossAxisCount: 7,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: weekDays
                                .map((d) => Center(
                                      child: Text(
                                        d,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                          GridView.builder(
                            itemCount: days.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                            ),
                            itemBuilder: (context, index) {
                              final entry = days[index];
                              final int dayNumber = entry['day'];
                              final bool isCurrent = entry['current'];

                              final date = DateTime(
                                _focusedMonth.year,
                                isCurrent
                                    ? _focusedMonth.month
                                    : (dayNumber > 20
                                        ? _focusedMonth.month - 1
                                        : _focusedMonth.month + 1),
                                dayNumber,
                              );
                              final dateStr =
                                  DateFormat('yyyy-MM-dd').format(date);
                              final entryData = entriesByDate[dateStr];
                              final bool hasEntry = entryData != null;

                              final mood = hasEntry
                                  ? entryData['mood'] as int
                                  : 0;
                              final baseColor = hasEntry
                                  ? _colorForMood(mood)
                                      .withOpacity(isCurrent ? 0.25 : 0.12)
                                  : Colors.white;

                              return GestureDetector(
                                onTap: () => _openDayEditor(context, date),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: baseColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey[300]!),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Stack(
                                    children: [
                                      if (hasEntry)
                                        Positioned(
                                          bottom: 2,
                                          right: 3,
                                          child: Opacity(
                                            opacity: 0.8,
                                            child: Text(
                                              moodEmojis[mood] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),

                                      Positioned(
                                        top: 2,
                                        left: 4,
                                        child: Text(
                                          '$dayNumber',
                                          style: TextStyle(
                                            color: isCurrent
                                                ? Colors.black87
                                                : Colors.grey[400],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Mood Count",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text("Total: $totalMoods",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: moodCount.entries.map((entry) {
                              final mood = entry.key;
                              final count = entry.value;
                              final emoji = moodEmojis[mood] ?? '';

                              return Column(
                                children: [
                                  Text(emoji,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 6),
                                  Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
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

  Color _colorForMood(int mood) {
    switch (mood) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.deepOrange.shade400;
      case 3:
        return Colors.amber.shade400;
      case 4:
        return Colors.lightGreen.shade400;
      case 5:
        return Colors.green.shade400;
      default:
        return Colors.grey;
    }
  }
}