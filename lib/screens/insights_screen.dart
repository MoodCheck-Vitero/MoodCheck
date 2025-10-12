import 'package:flutter/material.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  String selectedTab = 'Monthly';

  // Sample frontend data (initially zero for backend integration later)
  final List<String> moodEmojis = ['😡', '😞', '😐', '🙂', '😄'];
  final List<int> moodCounts = [2, 3, 5, 6, 7]; // sample counts
  final Map<String, int> averageMoodPerDay = {
    'Sun': 0,
    'Mon': 1,
    'Tue': 2,
    'Wed': 3,
    'Thu': 1,
    'Fri': 4,
    'Sat': 2,
  };

  final Map<int, String> moodLevelEmojis = {0: '😡', 1: '😞', 2: '😐', 3: '🙂', 4: '😄'};
  final Map<int, Color> moodColors = {
    0: Colors.red,
    1: Colors.deepOrange,
    2: Colors.orange,
    3: Colors.lightGreen,
    4: Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xff009d03),
        centerTitle: true,
        title: const Text(
          'Insights',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        bottom: const PreferredSize(preferredSize: Size.fromHeight(18), child: SizedBox()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tab Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ['Monthly', 'Yearly', 'Lifetime'].map((tab) {
                  final isSelected = selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xff009d03) : Colors.grey[300],
                        foregroundColor: isSelected ? Colors.white : Colors.black,
                      ),
                      onPressed: () => setState(() => selectedTab = tab),
                      child: Text(tab),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Mood Count Card
              _buildCard(
                title: 'Mood Count',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    moodEmojis.length,
                    (i) => Column(
                      children: [
                        Text(moodEmojis[i], style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 8),
                        Text(moodCounts[i].toString(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Average Daily Mood Card
              _buildCard(
                title: 'Average Daily Mood',
                child: SizedBox(
                  height: 220,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: averageMoodPerDay.entries.map((entry) {
                      // Determine the mood level based on value (for frontend demo)
                      final int moodLevel = entry.value.clamp(0, 4);
                      final double barFactor = ((moodLevel + 1) / 5.0 * 0.78).clamp(0.05, 1.0);
                      final Color barColor = moodColors[moodLevel]!;
                      final String emoji = moodLevelEmojis[moodLevel]!;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double barHeight = constraints.maxHeight * barFactor;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Container(
                                            height: barHeight,
                                            width: 28,
                                            decoration: BoxDecoration(
                                              color: barColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: barHeight + 6,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(fontSize: 25),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}