import 'package:sqlite3/sqlite3.dart';
void main() {
  final db = sqlite3.open('habits.db');
  final result = db.select("PRAGMA table_info(habits)");
  for (var row in result) {
    print(row['name']);
  }
}
