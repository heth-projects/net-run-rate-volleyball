import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../repositories/match_repository.dart';
import '../repositories/team_repository.dart';

class ScheduleViewModel extends ChangeNotifier {
  final MatchRepository _matchRepository = MatchRepository();
  final TeamRepository _teamRepository = TeamRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> generateRoundRobinSchedule(int tournamentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch teams
      final teams = await _teamRepository.getTeamsByTournamentId(tournamentId);
      // Group teams by groupName
      Map<String, List<Team>> groups = {};
      for (var team in teams) {
        if (team.groupName != null && team.groupName!.isNotEmpty) {
          if (!groups.containsKey(team.groupName)) groups[team.groupName!] = [];
          groups[team.groupName]!.add(team);
        }
      }

      List<TournamentMatch> newMatches = [];
      
      // Generate matches for each group
      groups.forEach((groupName, groupTeams) {
        // Round Robin Algorithm
        // A, B, C, D
        // A-B, A-C, A-D, B-C, B-D, C-D
        for (int i = 0; i < groupTeams.length; i++) {
          for (int j = i + 1; j < groupTeams.length; j++) {
            newMatches.add(TournamentMatch(
              tournamentId: tournamentId,
              teamAId: groupTeams[i].id!,
              teamBId: groupTeams[j].id!,
              matchDate: DateTime.now(), // Default to now, user can edit
              stage: 'Group',
              status: 'Scheduled',
              groupName: groupName,
            ));
          }
        }
      });
      
      // Validate: Delete existing group matches? Or append? 
      // Usually user wants to generate fresh. We'll append for now or checking duplicate? 
      // For MVP, we bulk create.
      if (newMatches.isNotEmpty) {
         await _matchRepository.createMatchesBulk(newMatches);
      }
      
    } catch (e) {
      debugPrint("Error generating schedule: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateKnockoutFixtures(int tournamentId, String stage) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 1. Calculate Standings to find top teams
      // We need a way to get standings. For now, we will fetch all matches and teams.
      final teams = await _teamRepository.getTeamsByTournamentId(tournamentId);
      final matches = await _matchRepository.getMatchesByTournamentId(tournamentId);
      
      // Simple standings logic (duplicated for now to avoid circular deps or complex service refactoring)
      Map<int, int> pointsMap = {for (var t in teams) t.id!: 0};
      
      for (var match in matches) {
        if (match.status != 'Completed' || match.stage != 'Group') continue; // Only consider Group stage for QF qualification
        if (pointsMap.containsKey(match.teamAId) && pointsMap.containsKey(match.teamBId)) {
           if (match.scoreA > match.scoreB) pointsMap[match.teamAId] = pointsMap[match.teamAId]! + 2;
           else if (match.scoreB > match.scoreA) pointsMap[match.teamBId] = pointsMap[match.teamBId]! + 2;
           else { pointsMap[match.teamAId] = pointsMap[match.teamAId]! + 1; pointsMap[match.teamBId] = pointsMap[match.teamBId]! + 1; }
        }
      }
      
      // Sort teams by points
      teams.sort((a, b) => pointsMap[b.id]!.compareTo(pointsMap[a.id]!));
      
      // Take Top 8 for Quarter Finals? Or Top 4 for Semis?
      // User said "if quarter finals is enabled".
      // We assume Top 8 go to QF.
      int teamCount = stage == 'QF' ? 8 : (stage == 'SF' ? 4 : 2);
      
      if (teams.length < teamCount) {
         // Not enough teams
         debugPrint("Not enough teams for $stage");
         return; // Or throw error
      }
      
      List<Team> qualifiedTeams = teams.take(teamCount).toList();
      
      List<TournamentMatch> newMatches = [];
      // Pair 1 vs 8, 2 vs 7, etc. (Standard seeding)
      for (int i = 0; i < teamCount / 2; i++) {
         newMatches.add(TournamentMatch(
           tournamentId: tournamentId,
           teamAId: qualifiedTeams[i].id!,
           teamBId: qualifiedTeams[teamCount - 1 - i].id!,
           matchDate: DateTime.now().add(const Duration(days: 1)),
           stage: stage,
           status: 'Scheduled',
         ));
      }
      
      if (newMatches.isNotEmpty) {
        await _matchRepository.createMatchesBulk(newMatches);
      }
      
    } catch (e) {
      debugPrint("Error generating knockouts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
