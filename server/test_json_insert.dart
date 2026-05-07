import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.open('habits.db');
  print('Opened db');
  final payload = '{"name":"Test","description":"test","color":12345,"icon":"abc","frequency":"daily"}';
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
  print('Inserted');
  final id = db.lastInsertRowId;
  print('Last id: $id');
  final habit = db.select('SELECT * FROM habits WHERE id = ?', [id]).first;
  print(jsonEncode(habit));
}
