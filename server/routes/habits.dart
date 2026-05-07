import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';

class HabitsApi {
  Router get router {
    final router = Router();

    // GET /api/habits
    router.get('/', (Request request) {
      final resultSet = db.select('SELECT * FROM habits WHERE archived = 0');
      final habits = resultSet.map((row) => row).toList();
      return Response.ok(jsonEncode(habits), headers: {'Content-Type': 'application/json'});
    });

    // POST /api/habits
    router.post('/', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      db.execute('''
        INSERT INTO habits (name, description, color, icon, frequency, createdAt, archived)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        data['name'],
        data['description'] ?? '',
        data['color'],
        data['icon'],
        data['frequency'],
        data['createdAt'] ?? DateTime.now().toIso8601String(),
        data['archived'] ?? 0,
      ]);
      
      final id = db.lastInsertRowId;
      final habit = db.select('SELECT * FROM habits WHERE id = ?', [id]).first;

      return Response.ok(jsonEncode(habit), headers: {'Content-Type': 'application/json'});
    });

    // PUT /api/habits/<id>
    router.put('/<id>', (Request request, String id) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);

      db.execute('''
        UPDATE habits 
        SET name = ?, description = ?, color = ?, icon = ?, frequency = ?, archived = ?
        WHERE id = ?
      ''', [
        data['name'],
        data['description'] ?? '',
        data['color'],
        data['icon'],
        data['frequency'],
        data['archived'] ?? 0,
        id,
      ]);

      final habit = db.select('SELECT * FROM habits WHERE id = ?', [id]).first;
      return Response.ok(jsonEncode(habit), headers: {'Content-Type': 'application/json'});
    });

    return router;
  }
}
