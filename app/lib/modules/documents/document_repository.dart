import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import 'studio_document.dart';

class DocumentRepository {
  DocumentRepository({AppDatabase? database})
      : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  static const _uuid = Uuid();

  Future<List<StudioDocument>> getAll({String? projectId, String? query}) async {
    final db = await _database.database;
    final where = <String>[];
    final args = <Object?>[];
    if (projectId != null) {
      where.add('project_id = ?');
      args.add(projectId);
    }
    if (query != null && query.trim().isNotEmpty) {
      where.add('(title LIKE ? OR content LIKE ?)');
      args.addAll(['%${query.trim()}%', '%${query.trim()}%']);
    }
    final rows = await db.query(
      'documents',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'updated_at DESC',
    );
    return rows.map(StudioDocument.fromMap).toList();
  }

  Future<StudioDocument> create({
    required String title,
    required String content,
    required String category,
    String? projectId,
  }) async {
    final now = DateTime.now();
    final document = StudioDocument(
      id: _uuid.v4(),
      title: title.trim(),
      content: content,
      category: category,
      projectId: projectId,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _database.database;
    await db.insert('documents', document.toMap());
    return document;
  }

  Future<void> update(StudioDocument document) async {
    final db = await _database.database;
    await db.update('documents', {
      ...document.toMap(),
      'title': document.title.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [document.id]);
  }

  Future<void> delete(String id) async {
    final db = await _database.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _database.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM documents');
    return (result.first['total'] as num).toInt();
  }
}
