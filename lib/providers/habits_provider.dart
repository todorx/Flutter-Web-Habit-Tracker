import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../repository/habit_repository.dart';

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<Habit>>(() {
  return HabitsNotifier();
});

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() async {
    return _fetchHabits();
  }

  Future<List<Habit>> _fetchHabits() async {
    return await habitRepository.getHabits();
  }

  Future<void> addHabit(Map<String, dynamic> data) async {
    await habitRepository.createHabit(data);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabits());
  }

  Future<void> updateHabit(int id, Map<String, dynamic> data) async {
    await habitRepository.updateHabit(id, data);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchHabits());
  }
}
