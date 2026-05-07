import 'package:sqlite3/sqlite3.dart';
void main() {
  final db = sqlite3.open('habits.db');
  print('Opened db');
  try {
    db.execute('''
        INSERT INTO habits (name, description, color, icon, frequency, createdAt, archived)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        'Test',
        'test',
        12345,
        'abc',
        'daily',
        '2024-01-01',
        0,
      ]);
    print('Inserted');
  } catch (e) {
    print('Error: $e');
  }
}
