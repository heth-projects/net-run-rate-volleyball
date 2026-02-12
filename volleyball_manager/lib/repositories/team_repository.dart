import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../models/team.dart';

class TeamRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> createTeam(Team team) async {
    final db = await _dbHelper.database;
    return await db.insert('teams', team.toMap());
  }

  Future<List<Team>> getTeamsByTournamentId(int tournamentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teams',
      where: 'tournament_id = ?',
      whereArgs: [tournamentId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<List<Team>> getTeamsByGroup(int tournamentId, String groupName) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teams',
      where: 'tournament_id = ? AND group_name = ?',
      whereArgs: [tournamentId, groupName],
    );
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<int> updateTeam(Team team) async {
    final db = await _dbHelper.database;
    return await db.update(
      'teams',
      team.toMap(),
      where: 'id = ?',
      whereArgs: [team.id],
    );
  }

  Future<int> deleteTeam(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<Team?> getTeamById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Team.fromMap(maps.first);
    }
    return null;
  }
}
