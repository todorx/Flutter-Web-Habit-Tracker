import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../widgets/habit_card.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add habit'),
      ),
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return const Center(child: Text('No habits yet.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final todayStr = DateTime.now().toIso8601String().split('T')[0];
              final logsAsync = ref.watch(habitLogsProvider(habit.id));

              return logsAsync.when(
                data: (logs) {
                  final log = logs.where((l) => l.date == todayStr).firstOrNull;
                  final isCompleted = log?.completed == 1;
                  
                  return GestureDetector(
                    onTap: () => context.go('/habit/\${habit.id}'),
                    child: HabitCard(
                      habit: habit,
                      isCompleted: isCompleted,
                      onToggle: () {
                         ref.read(logsControllerProvider).toggleLog(
                           habit.id, todayStr, isCompleted ? 1 : 0, null
                         );
                      },
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'archive', child: Text('Archive')),
                        ],
                        onSelected: (value) {
                          if (value == 'archive') {
                            ref.read(habitsProvider.notifier).updateHabit(habit.id, {
                              ...habit.toJson(),
                              'archived': 1,
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: \$e'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: \$e')),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String icon = '🏃';
    int colorValue = Colors.deepPurple.value;
    bool isDaily = true;
    final Map<String, bool> weekDays = {
      'Mon': false, 'Tue': false, 'Wed': false, 'Thu': false, 'Fri': false, 'Sat': false, 'Sun': false
    };

    final colors = [Colors.deepPurple, Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.pink];
    final icons = ['🏃', '💧', '📚', '🧘', '🏋️', '🥗', '💻', '🎨'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Habit'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 16),
                    // Icon Picker
                    Wrap(
                      spacing: 8,
                      children: icons.map((i) => ChoiceChip(
                        label: Text(i, style: const TextStyle(fontSize: 20)),
                        selected: icon == i,
                        onSelected: (val) => setState(() => icon = i),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Color Picker
                    Wrap(
                      spacing: 8,
                      children: colors.map((c) => GestureDetector(
                        onTap: () => setState(() => colorValue = c.value),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: colorValue == c.value ? Border.all(color: Colors.white, width: 2) : null,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Frequency
                    Row(
                      children: [
                        const Text('Daily'),
                        Switch(value: isDaily, onChanged: (v) => setState(() => isDaily = v)),
                      ],
                    ),
                    if (!isDaily)
                      Wrap(
                        spacing: 8,
                        children: weekDays.keys.map((day) => FilterChip(
                          label: Text(day),
                          selected: weekDays[day]!,
                          onSelected: (val) => setState(() => weekDays[day] = val),
                        )).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    String freq = 'daily';
                    if (!isDaily) {
                      final selectedDays = weekDays.entries.where((e) => e.value).map((e) => e.key).toList();
                      if (selectedDays.isEmpty) return;
                      freq = selectedDays.join(',');
                    }
                    
                    ref.read(habitsProvider.notifier).addHabit({
                      'name': nameController.text,
                      'description': descController.text,
                      'color': colorValue,
                      'icon': icon,
                      'frequency': freq,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
