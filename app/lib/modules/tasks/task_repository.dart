import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import 'studio_task.dart';

class TaskRepository {
  TaskRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<List<StudioTask>> getAll({String? status}) async {
    final db = await _database.database;
    final rows = await db.query(
      'tasks',
      where: status == null ? null : 'status = ?',
      whereArgs: status == null ? null : [status],
      orderBy: "CASE priority WHEN 'High' THEN 0 WHEN 'Medium' THEN 1 ELSE 2 END, updated_at DESC",
    );
    return rows.map(StudioTask.fromMap).toList();
  }

  Future<int> countOpen() async {
    final db = await _database.database;
    final rows = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM tasks WHERE status != 'Done'",
    );
    final total = rows.first['total'];
    return total is num ? total.toInt() : 0;
  }

  Future<StudioTask> create({
    required String title,
    String description = '',
    String status = 'Todo',
    String priority = 'Medium',
    String? projectId,
    DateTime? dueDate,
    String? milestoneId,
  }) async {
    final now = DateTime.now();
    final task = StudioTask(
      id: _uuid.v4(),
      title: title.trim(),
      description: description.trim(),
      status: status,
      priority: priority,
      projectId: projectId,
      milestoneId: milestoneId,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _database.database;
    await db.insert('tasks', task.toMap());
    return task;
  }

  Future<void> update(StudioTask task) async {
    final updated = StudioTask(
      id: task.id,
      title: task.title.trim(),
      description: task.description.trim(),
      status: task.status,
      priority: task.priority,
      projectId: task.projectId,
      milestoneId: task.milestoneId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );
    final db = await _database.database;
    await db.update('tasks', updated.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
