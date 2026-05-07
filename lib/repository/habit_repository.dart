import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitRepository {
  static const String baseUrl = 'http://localhost:8080/api';

  Future<List<Habit>> getHabits() async {
    final response = await http.get(Uri.parse('$baseUrl/habits'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Habit.fromJson(json)).toList();
    }
    throw Exception('Failed to load habits');
  }

  Future<Habit> createHabit(Map<String, dynamic> habitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habits'),
      body: jsonEncode(habitData),
    );
    if (response.statusCode == 200) {
      return Habit.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create habit');
  }

  Future<Habit> updateHabit(int id, Map<String, dynamic> habitData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/habits/$id'),
      body: jsonEncode(habitData),
    );
    if (response.statusCode == 200) {
      return Habit.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update habit');
  }

  Future<List<HabitLog>> getHabitLogs(int habitId, {String? from, String? to}) async {
    String url = '$baseUrl/habits/$habitId/logs';
    if (from != null && to != null) {
      url += '?from=$from&to=$to';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => HabitLog.fromJson(json)).toList();
    }
    throw Exception('Failed to load habit logs');
  }

  Future<HabitLog> upsertHabitLog(int habitId, String date, int completed, String? note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habits/$habitId/logs'),
      body: jsonEncode({
        'date': date,
        'completed': completed,
        'note': note,
      }),
    );
    if (response.statusCode == 200) {
      return HabitLog.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to upsert habit log');
  }

  Future<Map<String, dynamic>> getStatsSummary() async {
    final response = await http.get(Uri.parse('$baseUrl/stats/summary'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load stats summary');
  }
}

final habitRepository = HabitRepository();
