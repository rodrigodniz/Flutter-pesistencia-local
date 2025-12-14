import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 6, // <-- era 5
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        priority TEXT NOT NULL,
        completed INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        photoPath TEXT,
        imageUrl TEXT, -- <-- NOVO
        completedAt TEXT,
        completedBy TEXT,
        latitude REAL,
        longitude REAL,
        locationName TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Se veio de versões antigas
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE tasks ADD COLUMN updatedAt TEXT');
      await db.execute(
        'ALTER TABLE tasks ADD COLUMN isSynced INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'UPDATE tasks SET updatedAt = createdAt WHERE updatedAt IS NULL',
      );
    }

    // Nova coluna do S3
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE tasks ADD COLUMN imageUrl TEXT');
    }
  }

  // ------------------------------------------------------------
  // CRUD BÁSICO
  // ------------------------------------------------------------
  Future<Task> insertTask(Task task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> readAll() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'createdAt DESC');
    return result.map((e) => Task.fromMap(e)).toList();
  }

  // ------------------------------------------------------------
  // MARCAR COMO SINCRONIZADO
  // ------------------------------------------------------------
  Future<void> markSynced(int id) async {
    final db = await database;
    await db.update('tasks', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllSynced() async {
    final db = await database;
    await db.update('tasks', {'isSynced': 1});
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
