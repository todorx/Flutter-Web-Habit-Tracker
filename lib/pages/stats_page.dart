import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';
import '../providers/habits_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: statsAsync.when(
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Overall Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Best Streak (across all habits)'),
                trailing: Text(
                  '${stats["bestStreak"]} days',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('This Week Completion Rate'),
                trailing: Text(
                  '${stats["weeklyRate"]}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Active Habits',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              habitsAsync.when(
                data: (habits) => Column(
                  children: habits
                      .map(
                        (h) => ListTile(
                          leading: Text(
                            h.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(h.name),
                          subtitle: Text(h.frequency),
                        ),
                      )
                      .toList(),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: \$e'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: \$e')),
      ),
    );
  }
}
