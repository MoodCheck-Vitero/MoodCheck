import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  final _controller = TextEditingController();
  int? selectedMood;
  bool hasUnsavedChanges = false;
  bool isLoading = true;
  bool _isLoadingEntry = false;

  String? quoteText;
  String? quoteAuthor;

  final List<String> emojis = ['😡', '😞', '😐', '🙂', '😄'];
  final List<Color> moodColors = [
    Colors.red.shade400,
    Colors.deepOrange.shade400,
    Colors.amber.shade300,
    Colors.lightGreen,
    Colors.green,
  ];

  Future<void> loadTodayEntry() async {
    setState(() => _isLoadingEntry = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final entry = await _db.getTodayEntry(user.id);

    if (entry != null) {
      selectedMood = entry['mood'];
      _controller.text = entry['comment'] ?? '';
      quoteText = entry['motivational_content']['text'];
      quoteAuthor = entry['motivational_content']['author'];
    } else {
      quoteText =
          "How are you feeling today? Record your mood and a motivational quote will appear here!";
      quoteAuthor = null;
    }

    setState(() {
      isLoading = false;
      hasUnsavedChanges = false;
      _isLoadingEntry = false;
    });
  }

  Future<void> saveData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedMood == null) return;

    final result = await _db.insertOrUpdateMood(
      userId: user.id,
      mood: selectedMood!,
      comment: _controller.text.isEmpty ? null : _controller.text,
    );

    setState(() {
      quoteText = result?['motivational_content']['text'];
      quoteAuthor = result?['motivational_content']['author'];
      hasUnsavedChanges = false;
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Your mood entry has been saved!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadTodayEntry();

    _controller.addListener(() {
      if (!_isLoadingEntry) {
        setState(() => hasUnsavedChanges = true);
      }
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff009d03).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff009d03),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xff009d03), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quoteText ?? "",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          if (quoteAuthor != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                "- $quoteAuthor",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Text(
                      "How are you feeling today?",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(emojis.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMood = index + 1;
                              hasUnsavedChanges = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: selectedMood == index + 1
                                  ? moodColors[index].withOpacity(0.8)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: selectedMood == index + 1
                                  ? Border.all(
                                      color: const Color(0xff009d03),
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

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
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Enter your thoughts...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),

                    if (hasUnsavedChanges)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, right: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Unsaved changes",
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              hasUnsavedChanges && selectedMood != null ? saveData : null,
                          label: const Text(
                            "Save",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasUnsavedChanges
                                ? const Color(0xff009d03)
                                : Colors.grey,
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
