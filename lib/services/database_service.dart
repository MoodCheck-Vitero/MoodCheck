import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getEntryByDate(String userId, String date) async {
    final response = await _client
        .from('mood_entries')
        .select('*, motivational_content(text, author)')
        .eq('user_id', userId)
        .eq('entry_date', date)
        .maybeSingle();

    return response;
  }

  Future<Map<String, dynamic>?> getTodayEntry(String userId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getEntryByDate(userId, today);
  }

  Future<List<Map<String, dynamic>>> getEntriesForMonth(
    String userId,
    int year,
    int month,
  ) async {
    final start = DateFormat('yyyy-MM-dd').format(DateTime(year, month, 1));
    final end = DateFormat('yyyy-MM-dd')
        .format(DateTime(year, month + 1, 1).subtract(const Duration(days: 1)));

    final response = await _client
        .from('mood_entries')
        .select('entry_date, mood, comment, content_id, motivational_content(text, author)')
        .eq('user_id', userId)
        .gte('entry_date', start)
        .lte('entry_date', end)
        .order('entry_date', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> insertOrUpdateMood({
    required String userId,
    required int mood,
    String? comment,
    String? entryDate,
  }) async {
    final date = entryDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

    final seenResponse = await _client
        .from('user_content_checklist')
        .select('content_id')
        .eq('user_id', userId)
        .eq('seen', true);

    final seenIds = (seenResponse as List)
        .where((r) => r['content_id'] != null)
        .map<int>((r) => r['content_id'] as int)
        .toList();

    final unseen = seenIds.isEmpty
        ? await _client.from('motivational_content').select('id')
        : await _client
            .from('motivational_content')
            .select('id')
            .not('id', 'in', '(${seenIds.join(",")})');

    int? contentId;

    if (unseen.isNotEmpty) {
      unseen.shuffle(Random());
      contentId = unseen.first['id'] as int;
    } else {
      await _client
          .from('user_content_checklist')
          .update({'seen': false})
          .eq('user_id', userId);

      final all = await _client.from('motivational_content').select('id');
      if (all.isNotEmpty) {
        all.shuffle(Random());
        contentId = all.first['id'] as int;
      }
    }

    if (contentId != null) {
      await _client.from('user_content_checklist').upsert({
        'user_id': userId,
        'content_id': contentId,
        'seen': true,
      }, onConflict: 'user_id,content_id');
    }

    final response = await _client
        .from('mood_entries')
        .upsert({
          'user_id': userId,
          'mood': mood,
          'comment': comment,
          'entry_date': date,
          'content_id': contentId,
        }, onConflict: 'user_id,entry_date')
        .select('*, motivational_content(text, author)')
        .single();

    return response;
  }

  Future<void> deleteMoodEntry({
    required String userId,
    required String entryDate,
  }) async {
    await _client
        .from('mood_entries')
        .delete()
        .eq('user_id', userId)
        .eq('entry_date', entryDate);
  }
}