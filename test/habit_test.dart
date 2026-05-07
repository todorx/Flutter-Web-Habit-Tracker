import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/repository/habit_repository.dart';

void main() {
  test('test fetch habits', () async {
    final repo = HabitRepository();
    final habits = await repo.getHabits();
    print("Fetched \${habits.length} habits");
  });
}
