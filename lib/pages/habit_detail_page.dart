import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../providers/habits_provider.dart';
import '../providers/logs_provider.dart';
import '../widgets/heatmap_painter.dart';
import '../widgets/stat_card.dart';
import '../theme/app_theme.dart';

class HabitDetailPage extends ConsumerWidget {
  final int habitId;

  const HabitDetailPage({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      data: (habits) {
        final habit = habits.firstWhere(
          (h) => h.id == habitId,
          orElse: () => throw Exception('Habit not found'),
        );
        final habitColor = Color(habit.color);
        final brightness = Theme.of(context).brightness;

        return Theme(
          data: AppTheme.customSeedTheme(habitColor, brightness),
          child: Builder(
            builder: (themedContext) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/'),
                  ),
                  title: Row(
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(habit.name),
                    ],
                  ),
                  backgroundColor: habitColor.withOpacity(0.1),
                  elevation: 0,
                ),
                body: _HabitDetailBody(habitId: habitId, color: habitColor),
              );
            },
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: \$e'))),
    );
  }
}

class _HabitDetailBody extends ConsumerStatefulWidget {
  final int habitId;
  final Color color;

  const _HabitDetailBody({required this.habitId, required this.color});

  @override
  ConsumerState<_HabitDetailBody> createState() => _HabitDetailBodyState();
}

class _HabitDetailBodyState extends ConsumerState<_HabitDetailBody> {
  String? hoveredDate;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(habitLogsProvider(widget.habitId));

    return logsAsync.when(
      data: (logs) {
        final completedDates = logs
            .where((l) => l.completed == 1)
            .map((l) => l.date)
            .toSet();

        // Calculate stats
        int total = completedDates.length;
        // Total is not used directly in some cases, let's keep it to avoid lint if it is unused
        // Wait, it is used: StatCard(title: 'Total Completions', value: '$total')
        // Let's make sure it's '$total' not '\$total'

        // A simple week chart data
        List<BarChartGroupData> barGroups = [];
        for (int i = 0; i < 12; i++) {
          int count = 0;
          for (int j = 0; j < 7; j++) {
            final d = DateTime.now().subtract(Duration(days: i * 7 + j));
            final dStr = d.toIso8601String().split('T')[0];
            if (completedDates.contains(dStr)) count++;
          }
          barGroups.add(
            BarChartGroupData(
              x: 11 - i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: widget.color.withOpacity(0.8),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Completions',
                      value: '$total',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Last 365 days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Heatmap
              SizedBox(
                height: 120,
                width: double.infinity,
                child: GestureDetector(
                  onTapDown: (details) {
                    _handleTap(details.localPosition, context);
                  },
                  child: CustomPaint(
                    painter: HeatmapPainter(
                      completedDates: completedDates,
                      activeColor: widget.color,
                      inactiveColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Completions per week (last 12 weeks)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 7,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'W\${12 - value.toInt()}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: \$e'),
    );
  }

  void _handleTap(Offset position, BuildContext context) {
    final size = context.size!;
    final cellWidth = (size.width - (52 * 4)) / 53;
    final cellHeight = (120 - (6 * 4)) / 7;
    final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
    final padding = 4.0;

    // Reverse calculation to find which day was clicked
    int colIndex = (position.dx / (cellSize + padding)).floor();
    int rowIndex = (position.dy / (cellSize + padding)).floor();

    if (colIndex >= 0 && colIndex < 53 && rowIndex >= 0 && rowIndex < 7) {
      final now = DateTime.now();
      int currentWeekday = now.weekday - 1;

      int totalDaysFromEnd = (52 - colIndex) * 7 + (currentWeekday - rowIndex);
      if (totalDaysFromEnd >= 0 && totalDaysFromEnd < 365) {
        final d = now.subtract(Duration(days: totalDaysFromEnd));
        final dStr = d.toIso8601String().split('T')[0];

        _showNoteSheet(context, dStr);
      }
    }
  }

  void _showNoteSheet(BuildContext context, String date) async {
    final logs = ref.read(habitLogsProvider(widget.habitId)).value;
    if (logs == null) return;

    final log = logs.where((l) => l.date == date).firstOrNull;
    final isCompleted = log?.completed == 1;
    final noteController = TextEditingController(text: log?.note ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log for \$date',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Completed: '),
                  Switch(
                    value: isCompleted,
                    onChanged: (val) {
                      ref
                          .read(logsControllerProvider)
                          .toggleLog(
                            widget.habitId,
                            date,
                            val ? 0 : 1,
                            noteController.text.isNotEmpty
                                ? noteController.text
                                : null,
                          );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Optional Note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref
                        .read(logsControllerProvider)
                        .toggleLog(
                          widget.habitId,
                          date,
                          isCompleted
                              ? 0
                              : 1, // keeping same completion state but updating note
                          noteController.text.isNotEmpty
                              ? noteController.text
                              : null,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Save Note'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
