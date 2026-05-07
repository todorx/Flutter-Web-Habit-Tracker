class HabitLog {
  final int id;
  final int habitId;
  final String date; // YYYY-MM-DD
  final int completed; // 0 or 1
  final String? note;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.note,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'],
      habitId: json['habitId'],
      date: json['date'],
      completed: json['completed'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date,
      'completed': completed,
      'note': note,
    };
  }
}
