import 'package:flutter_test/flutter_test.dart';
import 'package:chinazium_studio/modules/projects/project.dart';

void main() {
  test('Project data can be serialized and restored', () {
    final timestamp = DateTime.utc(2026, 11, 5);
    final original = Project(
      id: 'test-id',
      name: 'Sample game',
      description: 'A test project',
      genre: 'Metroidvania',
      engine: 'Unreal Engine',
      status: 'Planning',
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final restored = Project.fromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.name, original.name);
    expect(restored.description, original.description);
    expect(restored.genre, original.genre);
    expect(restored.engine, original.engine);
    expect(restored.status, original.status);
    expect(restored.createdAt, timestamp);
    expect(restored.updatedAt, timestamp);
  });
}
