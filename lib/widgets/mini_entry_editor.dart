import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

class MiniEntryEditor extends StatefulWidget {
  final Map<String, dynamic>? initialEntry;
  final DateTime entryDate;
  final VoidCallback onSaved;
  final VoidCallback onCancelled;

  const MiniEntryEditor({
    Key? key,
    required this.initialEntry,
    required this.entryDate,
    required this.onSaved,
    required this.onCancelled,
  }) : super(key: key);

  @override
  State<MiniEntryEditor> createState() => _MiniEntryEditorState();
}

class _MiniEntryEditorState extends State<MiniEntryEditor> {
  final DatabaseService _db = DatabaseService();
  final _controller = TextEditingController();
  int? selectedMood;
  bool hasUnsaved = false;
  String? quoteText;
  String? quoteAuthor;
  bool isSaving = false;

  final List<String> emojis = ['😡', '😞', '😐', '🙂', '😄'];
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
    final e = widget.initialEntry;
    if (e != null) {
      selectedMood = e['mood'];
      _controller.text = e['comment'] ?? '';
      final content = e['motivational_content'];
      if (content != null) {
        quoteText = content['text'];
        quoteAuthor = content['author'];
      }
    } else {
      quoteText = "Record your mood to receive a motivational quote.";
    }

    _controller.addListener(() {
      setState(() => hasUnsaved = true);
    });
  }

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || selectedMood == null) return;

    setState(() => isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.entryDate);

    final result = await _db.insertOrUpdateMood(
      userId: user.id,
      mood: selectedMood!,
      comment: _controller.text.isEmpty ? null : _controller.text,
      entryDate: dateStr,
    );

    setState(() {
      quoteText = result?['motivational_content']?['text'] ?? quoteText;
      quoteAuthor = result?['motivational_content']?['author'] ?? quoteAuthor;
      hasUnsaved = false;
      isSaving = false;
    });

    widget.onSaved();
  }

  Future<void> _deleteEntry() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Entry"),
        content: const Text("Are you sure you want to delete this mood entry?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xff009d03)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isSaving = true);

    await _db.deleteMoodEntry(
      userId: user.id,
      entryDate: DateFormat('yyyy-MM-dd').format(widget.entryDate),
    );

    setState(() {
      selectedMood = null;
      _controller.clear();
      quoteText = "Record your mood to receive a motivational quote.";
      quoteAuthor = null;
      hasUnsaved = false;
      isSaving = false;
    });

    widget.onSaved();

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d, y').format(widget.entryDate);
    final bool canSave = selectedMood != null && hasUnsaved;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.55,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f8ff),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xff009d03).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quoteText ?? '',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                        if (quoteAuthor != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '- $quoteAuthor',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(emojis.length, (index) {
                      final moodValue = index + 1;
                      final isSelected = selectedMood == moodValue;
                      final color = moodColors[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = moodValue;
                            hasUnsaved = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.25)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: color, width: 2)
                                : null,
                          ),
                          child: Text(
                            emojis[index],
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write a quick note...",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  if (hasUnsaved)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Unsaved changes',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!hasUnsaved && selectedMood != null)
                        TextButton(
                          onPressed: isSaving ? null : _deleteEntry,
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      if (!hasUnsaved && selectedMood != null)
                        const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: canSave ? _save : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSave
                              ? const Color(0xff009d03)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}