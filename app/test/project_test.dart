import 'package:flutter_test/flutter_test.dart';
import 'package:chinazium_studio/modules/projects/project.dart';

void main() {
  test('Project serializes to and from the SQLite map format', () {
    final createdAt = DateTime.utc(2026, 11, 5, 10);
    final project = Project(
      id: 'project-1',
      name: 'Chinazium',
      description: 'A metroidvania game',
      genre: 'Metroidvania',
      engine: 'Unreal Engine',
      status: 'In development',
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final restored = Project.fromMap(project.toMap());

    expect(restored.id, project.id);
    expect(restored.name, project.name);
    expect(restored.description, project.description);
    expect(restored.genre, project.genre);
    expect(restored.engine, project.engine);
    expect(restored.status, project.status);
    expect(restored.createdAt, createdAt);
    expect(restored.updatedAt, createdAt);
  });
}
