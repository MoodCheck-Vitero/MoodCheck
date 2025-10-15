import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String selectedTab = 'Monthly';
  bool isLoading = true;

  final DatabaseService _db = DatabaseService();

  Map<int, int> moodCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  Map<String, double> averageMoodPerDay = {
    'Sun': 0,
    'Mon': 0,
    'Tue': 0,
    'Wed': 0,
    'Thu': 0,
    'Fri': 0,
    'Sat': 0,
  };

  final List<String> moodEmojis = ['😡', '😞', '😐', '🙂', '😄'];
  final List<Color> moodColors = [
    Colors.red.shade400,
    Colors.deepOrange.shade400,
    Colors.amber.shade300,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => isLoading = true);

    final entries = await _db.getEntriesForUser(user.id);
    final now = DateTime.now();

    List<Map<String, dynamic>> filtered = [];
    if (selectedTab == 'Monthly') {
      filtered = entries.where((e) {
        final date = DateTime.parse(e['entry_date']);
        return date.year == now.year && date.month == now.month;
      }).toList();
    } else if (selectedTab == 'Yearly') {
      filtered = entries.where((e) {
        final date = DateTime.parse(e['entry_date']);
        return date.year == now.year;
      }).toList();
    } else {
      filtered = entries;
    }

    moodCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    Map<String, List<int>> weekdayMoods = {
      'Sun': [],
      'Mon': [],
      'Tue': [],
      'Wed': [],
      'Thu': [],
      'Fri': [],
      'Sat': [],
    };

    for (var e in filtered) {
      final mood = e['mood'] ?? 0;
      if (mood >= 1 && mood <= 5) {
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;

        final date = DateTime.parse(e['entry_date']);
        final day = DateFormat('E').format(date);
        weekdayMoods[day]?.add(mood);
      }
    }

    averageMoodPerDay = weekdayMoods.map((day, moods) {
      if (moods.isEmpty) return MapEntry(day, 0.0);
      final avg = moods.reduce((a, b) => a + b) / moods.length;
      return MapEntry(day, avg);
    });

    setState(() => isLoading = false);
  }

  void _changeTab(String tab) {
    setState(() {
      selectedTab = tab;
    });
    _loadInsights();
  }

  @override
  Widget build(BuildContext context) {
    final totalMoods = moodCounts.values.fold<int>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff009d03),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: const Text(
          "Insights",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['Monthly', 'Yearly', 'Lifetime'].map((tab) {
                        final isSelected = selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? const Color(0xff009d03)
                                  : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                            onPressed: () => _changeTab(tab),
                            child: Text(tab),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    _buildCard(
                      title: 'Mood Count (Total: $totalMoods)',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          moodEmojis.length,
                          (i) => Column(
                            children: [
                              Text(moodEmojis[i],
                                  style: const TextStyle(fontSize: 30)),
                              const SizedBox(height: 6),
                              Text(
                                moodCounts[i + 1].toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildCard(
                      title: 'Average Daily Mood',
                      child: SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: averageMoodPerDay.entries.map((entry) {
                            final avgMood = entry.value;
                            final hasData = avgMood > 0;
                            final moodIndex = hasData
                                ? (avgMood - 1).clamp(0, 4).toInt()
                                : 0;
                            final emoji =
                                hasData ? moodEmojis[moodIndex] : '❌';
                            final color =
                                hasData ? moodColors[moodIndex] : Colors.grey.shade300;

                            final double minHeight = 25;
                            final double maxHeight = 140;
                            final heightFactor =
                                hasData ? ((avgMood / 5).clamp(0.1, 1.0)) : 0.1;
                            final barHeight =
                                (minHeight + (maxHeight - minHeight) * heightFactor)
                                    .clamp(minHeight, maxHeight);

                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          height: barHeight,
                                          width: 28,
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: barHeight + 6,
                                          child: Text(
                                            emoji,
                                            style:
                                                const TextStyle(fontSize: 22),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}