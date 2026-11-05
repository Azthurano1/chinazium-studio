class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.genre,
    required this.engine,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String genre;
  final String engine;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Project.fromMap(Map<String, Object?> map) {
    return Project(
      id: map['id']! as String,
      name: map['name']! as String,
      description: map['description'] as String? ?? '',
      genre: map['genre'] as String? ?? '',
      engine: map['engine'] as String? ?? '',
      status: map['status'] as String? ?? 'Planning',
      createdAt: DateTime.parse(map['created_at']! as String),
      updatedAt: DateTime.parse(map['updated_at']! as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'genre': genre,
        'engine': engine,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
