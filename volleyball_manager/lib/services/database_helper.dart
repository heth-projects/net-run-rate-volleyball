import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'volleyball_tournament.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tournaments Table
    await db.execute('''
      CREATE TABLE tournaments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        created_at TEXT,
        has_quarter_finals INTEGER DEFAULT 0,
        current_stage TEXT DEFAULT 'Group',
        status TEXT
      )
    ''');

    // Teams Table
    await db.execute('''
      CREATE TABLE teams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER,
        name TEXT,
        color INTEGER,
        group_name TEXT,
        FOREIGN KEY(tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE
      )
    ''');

    // Matches Table
    await db.execute('''
      CREATE TABLE matches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER,
        team_a_id INTEGER,
        team_b_id INTEGER,
        score_a INTEGER DEFAULT 0,
        score_b INTEGER DEFAULT 0,
        points_a INTEGER DEFAULT 0,
        points_b INTEGER DEFAULT 0,
        match_date TEXT,
        stage TEXT,
        round_number INTEGER DEFAULT 1,
        status TEXT,
        group_name TEXT,
        FOREIGN KEY(tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE,
        FOREIGN KEY(team_a_id) REFERENCES teams(id) ON DELETE CASCADE,
        FOREIGN KEY(team_b_id) REFERENCES teams(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migration logic here if needed
  }
}
