import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../models/match.dart';

class MatchRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createMatch(TournamentMatch match) async {
    final db = await _dbHelper.database;
    return await db.insert('matches', match.toMap());
  }
  
  Future<void> createMatchesBulk(List<TournamentMatch> matches) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (var match in matches) {
      batch.insert('matches', match.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<TournamentMatch>> getMatchesByTournamentId(int tournamentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'match_date ASC',
    );
    return List.generate(maps.length, (i) => TournamentMatch.fromMap(maps[i]));
  }

  Future<List<TournamentMatch>> getMatchesByStage(int tournamentId, String stage) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: 'tournament_id = ? AND stage = ?',
      whereArgs: [tournamentId, stage],
      orderBy: 'match_date ASC',
    );
    return List.generate(maps.length, (i) => TournamentMatch.fromMap(maps[i]));
  }

  Future<int> updateMatch(TournamentMatch match) async {
    final db = await _dbHelper.database;
    return await db.update(
      'matches',
      match.toMap(),
      where: 'id = ?',
      whereArgs: [match.id],
    );
  }

  Future<int> deleteMatch(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'matches',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<int> deleteAllMatchesForTournament(int tournamentId) async {
     final db = await _dbHelper.database;
     return await db.delete(
       'matches',
       where: 'tournament_id = ?',
       whereArgs: [tournamentId],
     );
  }
}
