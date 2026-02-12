import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../models/tournament.dart';

class TournamentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> checkTable() async {
     final db = await _dbHelper.database;
     // simple query to ensure connection works
     return await db.query('tournaments').then((value) => value.length);
  }

  Future<int> createTournament(Tournament tournament) async {
    final db = await _dbHelper.database;
    return await db.insert('tournaments', tournament.toMap());
  }

  Future<List<Tournament>> getAllTournaments() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tournaments', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Tournament.fromMap(maps[i]));
  }

  Future<Tournament?> getTournamentById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Tournament.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTournament(Tournament tournament) async {
    final db = await _dbHelper.database;
    return await db.update(
      'tournaments',
      tournament.toMap(),
      where: 'id = ?',
      whereArgs: [tournament.id],
    );
  }

  Future<int> deleteTournament(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'tournaments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
