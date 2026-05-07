import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';

class LogsApi {
  Router get router {
    final router = Router();

    // GET /api/habits/<id>/logs
    router.get('/<id>/logs', (Request request, String id) {
      final queryParams = request.url.queryParameters;
      final fromDate = queryParams['from'];
      final toDate = queryParams['to'];

      List<Map<String, Object?>> logs;

      if (fromDate != null && toDate != null) {
        logs = db.select('''
          SELECT * FROM habit_logs 
          WHERE habitId = ? AND date >= ? AND date <= ?
          ORDER BY date DESC
        ''', [id, fromDate, toDate]).map((row) => row).toList();
      } else {
        logs = db.select('''
          SELECT * FROM habit_logs 
          WHERE habitId = ?
          ORDER BY date DESC
        ''', [id]).map((row) => row).toList();
      }

      return Response.ok(jsonEncode(logs), headers: {'Content-Type': 'application/json'});
    });

    // POST /api/habits/<id>/logs
    router.post('/<id>/logs', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      
      final date = data['date'];
      final completed = data['completed'] ?? 0;
      final note = data['note'];

      db.execute('''
        INSERT INTO habit_logs (habitId, date, completed, note)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(habitId, date) DO UPDATE SET
          completed = excluded.completed,
          note = excluded.note
      ''', [id, date, completed, note]);

      final log = db.select('''
        SELECT * FROM habit_logs WHERE habitId = ? AND date = ?
      ''', [id, date]).first;

      return Response.ok(jsonEncode(log), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}
