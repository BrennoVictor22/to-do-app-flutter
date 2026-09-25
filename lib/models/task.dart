class Task {
  final int? id;
  final String title;
  final String? description;
  final bool completed;
  final DateTime? dueDateTime;
  final DateTime createdAt;
  final int? categoryId;
  final int? notificationId;

  const Task({
    this.id,
    required this.title,
    this.description,
    required this.completed,
    this.dueDateTime,
    required this.createdAt,
    this.categoryId,
    this.notificationId,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      completed: (map['completed'] as int?) == 1,
      dueDateTime: map['dueDateTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDateTime'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      categoryId: map['categoryId'] as int?,
      notificationId: map['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'dueDateTime': dueDateTime?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'categoryId': categoryId,
      'notificationId': notificationId,
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    DateTime? dueDateTime,
    DateTime? createdAt,
    int? categoryId,
    int? notificationId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
