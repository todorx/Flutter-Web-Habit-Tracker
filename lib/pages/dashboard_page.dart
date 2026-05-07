import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:go_router/go_router.dart';

import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stats Cards
                  statsAsync.when(
                    data: (stats) => Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Done today',
                            value: '${stats["todayCompleted"]}',
                            subtitle: '/${stats["todayTotal"]}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Best streak',
                            value: '${stats["bestStreak"]}',
                            subtitle: 'd',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'This week',
                            value: '${stats["weeklyRate"]}',
                            subtitle: '%',
                          ),
                        ),
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Error: $e'),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Today\'s Habits',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Habits List
                  Expanded(
                    child: habitsAsync.when(
                      data: (habits) {
                        final todayHabits = _getTodayHabits(habits);

                        if (todayHabits.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text('No habits scheduled for today.'),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () => context.go('/habits'),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Habit'),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: todayHabits.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final habit = todayHabits[index];
                            final todayStr = DateTime.now()
                                .toIso8601String()
                                .split('T')[0];

                            final logsAsync = ref.watch(
                              habitLogsProvider(habit.id),
                            );

                            return logsAsync.when(
                              data: (logs) {
                                final log = logs
                                    .where((l) => l.date == todayStr)
                                    .firstOrNull;
                                final isCompleted = log?.completed == 1;

                                return GestureDetector(
                                  onTap: () => context.go('/habit/${habit.id}'),
                                  child: HabitCard(
                                    habit: habit,
                                    isCompleted: isCompleted,
                                    onToggle: () async {
                                      await ref
                                          .read(logsControllerProvider)
                                          .toggleLog(
                                            habit.id,
                                            todayStr,
                                            isCompleted ? 1 : 0,
                                            null,
                                          );

                                      // Check if all today's habits are completed to show confetti
                                      _checkAllCompletedAndShowConfetti(
                                        todayHabits,
                                        todayStr,
                                      );
                                    },
                                  ),
                                );
                              },
                              loading: () =>
                                  const ListTile(title: Text('Loading...')),
                              error: (e, s) => Text('Error: $e'),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkAllCompletedAndShowConfetti(List habits, String todayStr) async {
    bool allCompleted = true;
    for (var habit in habits) {
      final logs = ref.read(habitLogsProvider(habit.id)).value;
      if (logs == null) {
        allCompleted = false;
        break;
      }
      final log = logs.where((l) => l.date == todayStr).firstOrNull;
      if (log == null || log.completed == 0) {
        allCompleted = false;
        break;
      }
    }
    if (allCompleted && habits.isNotEmpty) {
      _confettiController.play();
    }
  }

  List _getTodayHabits(List habits) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayDayName = weekDays[now.weekday - 1];

    return habits.where((habit) {
      if (habit.frequency == 'daily') return true;
      final days = habit.frequency.split(',');
      return days.contains(todayDayName);
    }).toList();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekDays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}
