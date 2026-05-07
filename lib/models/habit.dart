class Habit {
  final int id;
  final String name;
  final String description;
  final int color; // stored as ARGB
  final String icon;
  final String frequency; // "daily" or "Mon,Wed,Fri"
  final String createdAt;
  final int archived;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.frequency,
    required this.createdAt,
    required this.archived,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      frequency: json['frequency'],
      createdAt: json['createdAt'],
      archived: json['archived'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'frequency': frequency,
      'createdAt': createdAt,
      'archived': archived,
    };
  }
}
