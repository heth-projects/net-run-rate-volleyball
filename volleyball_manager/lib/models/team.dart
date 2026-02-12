
class Team {
  final int? id;
  final int tournamentId;
  final String name;
  final int color; // ARGB int
  final String? groupName;

  Team({
    this.id,
    required this.tournamentId,
    required this.name,
    required this.color,
    this.groupName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'name': name,
      'color': color,
      'group_name': groupName,
    };
  }

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      tournamentId: map['tournament_id'],
      name: map['name'],
      color: map['color'],
      groupName: map['group_name'],
    );
  }
}
