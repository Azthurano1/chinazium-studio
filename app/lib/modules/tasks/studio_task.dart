class StudioTask {
  const StudioTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? projectId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StudioTask.fromMap(Map<String, Object?> map) => StudioTask(
        id: map['id']! as String,
        title: map['title']! as String,
        description: map['description'] as String? ?? '',
        status: map['status'] as String? ?? 'Todo',
        priority: map['priority'] as String? ?? 'Medium',
        projectId: map['project_id'] as String?,
        dueDate: map['due_date'] == null
            ? null
            : DateTime.tryParse(map['due_date']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'project_id': projectId,
        'due_date': dueDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
