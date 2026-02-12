import 'package:flutter/material.dart';
import '../models/team.dart';
import '../repositories/team_repository.dart';

class TeamViewModel extends ChangeNotifier {
  final TeamRepository _repository = TeamRepository();
  List<Team> _teams = [];
  bool _isLoading = false;

  List<Team> get teams => _teams;
  bool get isLoading => _isLoading;

  Future<void> loadTeams(int tournamentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _teams = await _repository.getTeamsByTournamentId(tournamentId);
    } catch (e) {
      debugPrint("Error loading teams: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTeam(int tournamentId, String name, int color, {String? groupName}) async {
    final team = Team(
      tournamentId: tournamentId,
      name: name,
      color: color,
      groupName: groupName,
    );
    await _repository.createTeam(team);
    await loadTeams(tournamentId);
  }

  Future<void> deleteTeam(int id, int tournamentId) async {
    await _repository.deleteTeam(id);
    await loadTeams(tournamentId);
  }
  
  Future<void> updateTeamGroup(Team team, String groupName) async {
    final updated = Team(
      id: team.id,
      tournamentId: team.tournamentId,
      name: team.name,
      color: team.color,
      groupName: groupName
    );
    await _repository.updateTeam(updated);
    await loadTeams(team.tournamentId);
  }

  bool isColorTaken(int color) {
    return _teams.any((t) => t.color == color);
  }
}
