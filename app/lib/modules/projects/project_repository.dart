import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import 'project.dart';

class ProjectRepository {
  ProjectRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<List<Project>> getAll() async {
    final db = await _database.database;
    final rows = await db.query('projects', orderBy: 'updated_at DESC');
    return rows.map(Project.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM projects');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Project> create({
    required String name,
    String description = '',
    String genre = '',
    String engine = '',
    String status = 'Planning',
  }) async {
    final now = DateTime.now();
    final project = Project(
      id: _uuid.v4(),
      name: name.trim(),
      description: description.trim(),
      genre: genre.trim(),
      engine: engine.trim(),
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _database.database;
    await db.insert('projects', project.toMap());
    return project;
  }

  Future<void> update(Project project) async {
    final updated = Project(
      id: project.id,
      name: project.name.trim(),
      description: project.description.trim(),
      genre: project.genre.trim(),
      engine: project.engine.trim(),
      status: project.status,
      createdAt: project.createdAt,
      updatedAt: DateTime.now(),
    );
    final db = await _database.database;
    await db.update(
      'projects',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }
}
