class StudioDocument {
  const StudioDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final String category;
  final String? projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory StudioDocument.fromMap(Map<String, Object?> map) => StudioDocument(
        id: map['id']! as String,
        title: map['title']! as String,
        content: map['content'] as String? ?? '',
        category: map['category'] as String? ?? 'General',
        projectId: map['project_id'] as String?,
        createdAt: DateTime.parse(map['created_at']! as String),
        updatedAt: DateTime.parse(map['updated_at']! as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category,
        'project_id': projectId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
