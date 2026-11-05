import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final supportDirectory = await getApplicationSupportDirectory();
    final databaseDirectory = Directory(p.join(supportDirectory.path, 'ChinaziumStudio'));
    if (!await databaseDirectory.exists()) {
      await databaseDirectory.create(recursive: true);
    }
    final path = p.join(databaseDirectory.path, 'chinazium_studio.db');
    _database = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            genre TEXT NOT NULL DEFAULT '',
            engine TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'Planning',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_projects_updated_at ON projects(updated_at)');
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            project_id TEXT,
            milestone_id TEXT,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            status TEXT NOT NULL DEFAULT 'Todo',
            priority TEXT NOT NULL DEFAULT 'Medium',
            due_date TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE SET NULL
          )
        ''');
        await _createMilestones(db);
        await _createDocuments(db);
        await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
        await db.execute('CREATE INDEX idx_tasks_project_id ON tasks(project_id)');
        await db.execute('CREATE INDEX idx_tasks_milestone_id ON tasks(milestone_id)');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              project_id TEXT,
              title TEXT NOT NULL,
              description TEXT NOT NULL DEFAULT '',
              status TEXT NOT NULL DEFAULT 'Todo',
              priority TEXT NOT NULL DEFAULT 'Medium',
              due_date TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE SET NULL
            )
          ''');
          await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
          await db.execute('CREATE INDEX idx_tasks_project_id ON tasks(project_id)');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE tasks ADD COLUMN milestone_id TEXT');
          await _createMilestones(db);
          await db.execute('CREATE INDEX idx_tasks_milestone_id ON tasks(milestone_id)');
        }
        if (oldVersion < 4) {
          await _createDocuments(db);
        }
      },
    );
    return _database!;
  }

  static Future<void> _createMilestones(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE milestones (
        id TEXT PRIMARY KEY,
        project_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'Planning',
        target_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_milestones_project_id ON milestones(project_id)');
    await db.execute('CREATE INDEX idx_milestones_target_date ON milestones(target_date)');
  }

  static Future<void> _createDocuments(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'General',
        project_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_documents_project_id ON documents(project_id)');
    await db.execute('CREATE INDEX idx_documents_updated_at ON documents(updated_at)');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
