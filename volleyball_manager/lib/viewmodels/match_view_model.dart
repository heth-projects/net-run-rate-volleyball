import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../repositories/match_repository.dart';
import '../repositories/team_repository.dart';

class MatchViewModel extends ChangeNotifier {
  final MatchRepository _repository = MatchRepository();
  final TeamRepository _teamRepository = TeamRepository();
  List<TournamentMatch> _matches = [];
  Map<String, List<TeamStats>> _groupStandings = {};
  bool _isLoading = false;

  List<TournamentMatch> get matches => _matches;
  Map<String, List<TeamStats>> get groupStandings => _groupStandings;
  bool get isLoading => _isLoading;

  Future<void> loadMatches(int tournamentId, {String? stage}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (stage != null) {
        _matches = await _repository.getMatchesByStage(tournamentId, stage);
      } else {
        _matches = await _repository.getMatchesByTournamentId(tournamentId);
      }
      await _calculateStandings(tournamentId);
    } catch (e) {
      debugPrint("Error loading matches: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMatchScore(TournamentMatch match, int scoreA, int scoreB, int pointsA, int pointsB) async {
    // Determine winner based on sets (scoreA vs scoreB)
    // If scores are equal, it's a draw or pending? Volleyball matches cannot end in draw usually.
    // We assume input is valid.
    
    // Status update
    String status = 'Completed';
    // Logic to determine stage progression or strictly update score
    
    final updatedMatch = TournamentMatch(
      id: match.id,
      tournamentId: match.tournamentId,
      teamAId: match.teamAId,
      teamBId: match.teamBId,
      scoreA: scoreA,
      scoreB: scoreB,
      pointsA: pointsA,
      pointsB: pointsB,
      matchDate: match.matchDate,
      stage: match.stage,
      roundNumber: match.roundNumber,
      status: status,
      groupName: match.groupName,
    );

    await _repository.updateMatch(updatedMatch);
    await loadMatches(match.tournamentId, stage: match.stage);
  }

  Future<void> deleteMatch(int matchId, int tournamentId) async {
    await _repository.deleteMatch(matchId);
    await loadMatches(tournamentId);
  }

  Future<void> _calculateStandings(int tournamentId) async {
    // 1. Fetch all matches for the tournament (to ensure we have comprehensive data)
    final allMatches = await _repository.getMatchesByTournamentId(tournamentId);
    // 2. Fetch all teams
    final allTeams = await _teamRepository.getTeamsByTournamentId(tournamentId);
    
    // 3. Initialize stats
    Map<int, TeamStats> statsMap = {for (var t in allTeams) t.id!: TeamStats(teamId: t.id!, teamName: t.name, teamColor: t.color, groupName: t.groupName)};

    // 4. Process matches
    for (var match in allMatches) {
      if (match.status != 'Completed') continue;
      if (match.stage != 'Group') continue; // Standings usually for Group stage

      final statsA = statsMap[match.teamAId];
      final statsB = statsMap[match.teamBId];

      if (statsA != null && statsB != null) {
         // Stats A
         statsA.played++;
         statsA.setsWon += match.scoreA;
         statsA.setsLost += match.scoreB;
         statsA.pointsFor += match.pointsA;
         statsA.pointsAgainst += match.pointsB;
         
         // Stats B
         statsB.played++;
         statsB.setsWon += match.scoreB;
         statsB.setsLost += match.scoreA;
         statsB.pointsFor += match.pointsB;
         statsB.pointsAgainst += match.pointsA;

         // Points Logic (Simple: Win=2, Loss=0)
         if (match.scoreA > match.scoreB) {
           statsA.won++;
           statsA.points += 2;
           statsB.lost++;
         } else if (match.scoreB > match.scoreA) {
           statsB.won++;
           statsB.points += 2;
           statsA.lost++;
         } else {
           // Draw?
           statsA.draw++;
           statsB.draw++;
           statsA.points += 1;
           statsB.points += 1;
         }
      }
    }

    // 5. Group by groupName
    _groupStandings = {};
    for (var stats in statsMap.values) {
       // Check if team belongs to a group. If not, maybe 'Unknown' or skip
       if (stats.groupName != null && stats.groupName!.isNotEmpty) {
          if (!_groupStandings.containsKey(stats.groupName)) {
            _groupStandings[stats.groupName!] = [];
          }
          _groupStandings[stats.groupName]!.add(stats);
       }
    }

    // 6. Sort by Points, then NRR
    _groupStandings.forEach((group, teamStats) {
      teamStats.sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        return b.nrr.compareTo(a.nrr);
      });
    });
  }
}

class TeamStats {
  final int teamId;
  final String teamName;
  final int teamColor;
  final String? groupName;
  
  int played = 0;
  int won = 0;
  int lost = 0;
  int draw = 0;
  int points = 0;
  
  int setsWon = 0;
  int setsLost = 0;
  int pointsFor = 0;
  int pointsAgainst = 0;

  TeamStats({
    required this.teamId, 
    required this.teamName,
    required this.teamColor,
    this.groupName
  });

  double get nrr {
    // (Points For / Sets Played) - (Points Against / Sets Played)
    // Or strictly Points Ratio? User said: "(Total Points Scored / Total Sets Played) - (Total Points Conceded / Total Sets Played)"
    
    int totalSets = setsWon + setsLost; // This is sets played in MATCHES? Wait. setsWon is total sets won across all matches. 
    // Yes.
    
    if (totalSets == 0) return 0.0;
    
    double avgPointsFor = pointsFor / totalSets;
    double avgPointsAgainst = pointsAgainst / totalSets;
    
    return avgPointsFor - avgPointsAgainst;
  }
}
