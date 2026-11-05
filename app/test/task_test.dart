import 'package:flutter_test/flutter_test.dart';
import 'package:chinazium_studio/modules/tasks/studio_task.dart';

void main() {
  test('StudioTask serializes and restores optional fields', () {
    final created = DateTime.utc(2026, 11, 5, 12);
    final due = DateTime.utc(2026, 12, 1);
    final task = StudioTask(
      id: 'task-1',
      title: 'Create combat prototype',
      description: 'Implement basic attack and dodge',
      status: 'In progress',
      priority: 'High',
      projectId: 'project-1',
      dueDate: due,
      createdAt: created,
      updatedAt: created,
    );

    final restored = StudioTask.fromMap(task.toMap());

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.description, task.description);
    expect(restored.status, task.status);
    expect(restored.priority, task.priority);
    expect(restored.projectId, task.projectId);
    expect(restored.dueDate, due);
    expect(restored.createdAt, created);
  });

  test('StudioTask supports a task without project or due date', () {
    final timestamp = DateTime.utc(2026, 11, 5);
    final task = StudioTask(
      id: 'task-2',
      title: 'Write design notes',
      description: '',
      status: 'Todo',
      priority: 'Medium',
      projectId: null,
      dueDate: null,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    final restored = StudioTask.fromMap(task.toMap());

    expect(restored.projectId, isNull);
    expect(restored.dueDate, isNull);
  });
}
