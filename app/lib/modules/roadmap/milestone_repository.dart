import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import 'milestone.dart';

class MilestoneRepository {
  MilestoneRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<List<Milestone>> getAll({String? projectId}) async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT m.*,
        COUNT(t.id) AS total_tasks,
        SUM(CASE WHEN t.status = 'Done' THEN 1 ELSE 0 END) AS completed_tasks
      FROM milestones m
      LEFT JOIN tasks t ON t.milestone_id = m.id
      WHERE (? IS NULL OR m.project_id = ?)
      GROUP BY m.id
      ORDER BY
        CASE m.status WHEN 'In progress' THEN 0 WHEN 'Planning' THEN 1
          WHEN 'On hold' THEN 2 ELSE 3 END,
        CASE WHEN m.target_date IS NULL THEN 1 ELSE 0 END,
        m.target_date ASC,
        m.updated_at DESC
    ''', [projectId, projectId]);
    return rows.map(Milestone.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _database.database;
    final rows = await db.rawQuery('SELECT COUNT(*) AS total FROM milestones');
    return (rows.first['total'] as num).toInt();
  }

  Future<Milestone> create({
    String? projectId,
    required String title,
    String description = '',
    String status = 'Planning',
    DateTime? targetDate,
  }) async {
    final now = DateTime.now();
    final item = Milestone(
      id: _uuid.v4(),
      projectId: projectId,
      title: title.trim(),
      description: description.trim(),
      status: status,
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _database.database;
    await db.insert('milestones', item.toMap());
    return item;
  }

  Future<void> update(Milestone item) async {
    final db = await _database.database;
    await db.update('milestones', {
      ...item.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.update('tasks', {'milestone_id': null},
          where: 'milestone_id = ?', whereArgs: [id]);
      await txn.delete('milestones', where: 'id = ?', whereArgs: [id]);
    });
  }
}
