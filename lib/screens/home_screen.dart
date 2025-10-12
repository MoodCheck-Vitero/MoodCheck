import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedMood;
  final TextEditingController _controller = TextEditingController();

  final List<String> emojis = ['😡', '😞', '😐', '🙂', '😄'];
  final List<Color> moodColors = [
    Colors.red,
    Colors.deepOrange,
    Colors.amber,
    Colors.lightGreen,
    Colors.green,
  ];

  void saveData() {
    String mood = selectedMood != null ? emojis[selectedMood!] : 'None';
    String thoughts = _controller.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mood ($mood) saved!')),
    );
    print('Mood: $mood');
    print('Thoughts: $thoughts');

    setState(() {
      selectedMood = null;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),

      appBar: AppBar(
        backgroundColor: const Color(0xff009d03),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        title: const Text(
          "Home",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff009d03).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff009d03),
                    width: 1.5,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xff009d03), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff009d03),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "How are you feeling today?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // Mood Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(emojis.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMood = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedMood == index
                            ? moodColors[index].withOpacity(0.8)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: selectedMood == index
                            ? Border.all(
                                color: const Color(0xff009d03), width: 3)
                            : null,
                      ),
                      child: Text(
                        emojis[index],
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              const Text(
                "What’s on your mind?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: "Enter your thoughts...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: selectedMood != null ? saveData : null,
                    label: const Text(
                      "Save",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff009d03),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}