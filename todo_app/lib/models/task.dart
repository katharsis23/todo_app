class Task {
  final String id_;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? appointedAt;

  Task({
    required this.id_,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    this.appointedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id_: json['id_'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      appointedAt: json['appointedAt'] != null
          ? DateTime.parse(json['appointedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_': id_,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'appointedAt': appointedAt?.toIso8601String(),
    };
  }
}
