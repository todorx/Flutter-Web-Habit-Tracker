import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';

class StatsApi {
  Router get router {
    final router = Router();

    router.get('/summary', (Request request) {
      final now = DateTime.now();
      final todayStr = now.toIso8601String().split('T')[0];
      
      final activeHabits = db.select('SELECT * FROM habits WHERE archived = 0');
      
      int todayTotal = 0;
      int todayCompleted = 0;
      
      final todayLogs = db.select('''
        SELECT habitId, completed FROM habit_logs 
        WHERE date = ?
      ''', [todayStr]);
      
      final todayLogMap = {for (var row in todayLogs) row['habitId']: row['completed'] == 1};

      final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final todayDayName = weekDays[now.weekday - 1];

      for (var habit in activeHabits) {
        final frequency = habit['frequency'] as String;
        bool scheduledToday = false;
        if (frequency == 'daily') {
          scheduledToday = true;
        } else {
          final days = frequency.split(',');
          if (days.contains(todayDayName)) {
            scheduledToday = true;
          }
        }
        
        if (scheduledToday) {
          todayTotal++;
          if (todayLogMap[habit['id']] == true) {
            todayCompleted++;
          }
        }
      }

      int weeklyTotal = 0;
      int weeklyCompleted = 0;
      for (int i = 0; i < 7; i++) {
        final d = now.subtract(Duration(days: i));
        final dStr = d.toIso8601String().split('T')[0];
        final dayName = weekDays[d.weekday - 1];
        
        final logs = db.select('''
          SELECT habitId, completed FROM habit_logs 
          WHERE date = ?
        ''', [dStr]);
        final logMap = {for (var row in logs) row['habitId']: row['completed'] == 1};

        for (var habit in activeHabits) {
          final frequency = habit['frequency'] as String;
          bool scheduled = false;
          if (frequency == 'daily') {
            scheduled = true;
          } else {
            final days = frequency.split(',');
            if (days.contains(dayName)) {
              scheduled = true;
            }
          }
          if (scheduled) {
            weeklyTotal++;
            if (logMap[habit['id']] == true) {
              weeklyCompleted++;
            }
          }
        }
      }
      
      double weeklyRate = 0.0;
      if (weeklyTotal > 0) {
        weeklyRate = (weeklyCompleted / weeklyTotal) * 100;
      }

      int bestStreak = 0;
      for (var habit in activeHabits) {
        int streak = _calculateCurrentStreak(habit['id'] as int, habit['frequency'] as String, now, weekDays);
        if (streak > bestStreak) {
          bestStreak = streak;
        }
      }

      return Response.ok(jsonEncode({
        'todayTotal': todayTotal,
        'todayCompleted': todayCompleted,
        'weeklyRate': weeklyRate.round(),
        'bestStreak': bestStreak,
      }), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }

  int _calculateCurrentStreak(int habitId, String frequency, DateTime now, List<String> weekDays) {
    final logs = db.select('''
      SELECT date, completed FROM habit_logs 
      WHERE habitId = ? AND completed = 1
      ORDER BY date DESC
    ''', [habitId]);
    
    final completedDates = logs.map((row) => row['date'] as String).toSet();
    
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final dStr = d.toIso8601String().split('T')[0];
      final dayName = weekDays[d.weekday - 1];
      
      bool scheduled = false;
      if (frequency == 'daily') {
        scheduled = true;
      } else {
        final days = frequency.split(',');
        if (days.contains(dayName)) {
          scheduled = true;
        }
      }

      if (scheduled) {
        if (completedDates.contains(dStr)) {
          streak++;
        } else {
          if (i > 0) {
             break;
          }
        }
      }
    }
    return streak;
  }
}
