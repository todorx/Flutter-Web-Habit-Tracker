import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_log.dart';
import '../repository/habit_repository.dart';
import 'stats_provider.dart';

final habitLogsProvider = FutureProvider.family<List<HabitLog>, int>((ref, habitId) async {
  return await habitRepository.getHabitLogs(habitId);
});

class LogsController {
  final Ref ref;
  LogsController(this.ref);

  Future<void> toggleLog(int habitId, String date, int currentStatus, String? note) async {
    int newStatus = currentStatus == 1 ? 0 : 1;
    await habitRepository.upsertHabitLog(habitId, date, newStatus, note);
    ref.invalidate(habitLogsProvider(habitId));
    ref.invalidate(statsProvider);
  }
}

final logsControllerProvider = Provider((ref) => LogsController(ref));
