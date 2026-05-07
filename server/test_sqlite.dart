import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final db = sqlite3.openInMemory();
  db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)');
  db.execute('INSERT INTO test (name) VALUES (?)', ['hello']);
  final row = db.select('SELECT * FROM test').first;
  print(jsonEncode(row));
}
