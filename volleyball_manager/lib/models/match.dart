
class TournamentMatch {
  final int? id;
  final int tournamentId;
  final int teamAId;
  final int teamBId;
  final int scoreA; // Sets won
  final int scoreB; // Sets won
  final int pointsA; // Total points
  final int pointsB; // Total points
  final DateTime matchDate;
  final String stage; // 'Group', 'QF', 'SF', 'Final'
  final int roundNumber;
  final String status; // 'Scheduled', 'Live', 'Completed'
  final String? groupName;

  TournamentMatch({
    this.id,
    required this.tournamentId,
    required this.teamAId,
    required this.teamBId,
    this.scoreA = 0,
    this.scoreB = 0,
    this.pointsA = 0,
    this.pointsB = 0,
    required this.matchDate,
    required this.stage,
    this.roundNumber = 1,
    this.status = 'Scheduled',
    this.groupName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'team_a_id': teamAId,
      'team_b_id': teamBId,
      'score_a': scoreA,
      'score_b': scoreB,
      'points_a': pointsA,
      'points_b': pointsB,
      'match_date': matchDate.toIso8601String(),
      'stage': stage,
      'round_number': roundNumber,
      'status': status,
      'group_name': groupName,
    };
  }

  factory TournamentMatch.fromMap(Map<String, dynamic> map) {
    return TournamentMatch(
      id: map['id'],
      tournamentId: map['tournament_id'],
      teamAId: map['team_a_id'],
      teamBId: map['team_b_id'],
      scoreA: map['score_a'],
      scoreB: map['score_b'],
      pointsA: map['points_a'],
      pointsB: map['points_b'],
      matchDate: DateTime.parse(map['match_date']),
      stage: map['stage'],
      roundNumber: map['round_number'],
      status: map['status'],
      groupName: map['group_name'],
    );
  }
}
