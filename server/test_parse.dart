import 'dart:convert';
class Habit {
  final int id;
  Habit({required this.id});
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(id: json['id']);
}
void main() {
  final body = '[{"id": 1}]';
  final List data = jsonDecode(body);
  try {
    final list = data.map((json) => Habit.fromJson(json)).toList();
    print(list.length);
  } catch (e) {
    print("Error: $e");
  }
}
