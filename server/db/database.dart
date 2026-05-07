import 'package:sqlite3/sqlite3.dart';

late final Database db;

void initDatabase() {
  db = sqlite3.open('habits.db');

  db.execute('''
    CREATE TABLE IF NOT EXISTS habits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      color INTEGER NOT NULL,
      icon TEXT NOT NULL,
      frequency TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      archived INTEGER NOT NULL DEFAULT 0
    );
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS habit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habitId INTEGER NOT NULL,
      date TEXT NOT NULL,
      completed INTEGER NOT NULL DEFAULT 0,
      note TEXT,
      FOREIGN KEY(habitId) REFERENCES habits(id)
    );
  ''');

  db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS habit_logs_unique_date 
    ON habit_logs(habitId, date);
  ''');
}
