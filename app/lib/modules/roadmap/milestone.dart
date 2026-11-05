class Milestone {
  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });

  final String id;
  final String? projectId;
  final String title;
  final String description;
  final String status;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalTasks;
  final int completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  factory Milestone.fromMap(Map<String, Object?> map) => Milestone(
        id: map['id']! as String,
        projectId: map['project_id'] as String?,
        title: map['title']! as String,
        description: map['description'] as String? ?? '',
        status: map['status'] as String? ?? 'Planning',
        targetDate: map['target_date'] == null
            ? null
            : DateTime.tryParse(map['target_date']! as String),
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
        totalTasks: (map['total_tasks'] as num?)?.toInt() ?? 0,
        completedTasks: (map['completed_tasks'] as num?)?.toInt() ?? 0,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'project_id': projectId,
        'title': title,
        'description': description,
        'status': status,
        'target_date': targetDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
