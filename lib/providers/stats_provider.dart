import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/habit_repository.dart';

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await habitRepository.getStatsSummary();
});
