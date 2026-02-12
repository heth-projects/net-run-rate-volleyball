
class Tournament {
  final int? id;
  final String name;
  final DateTime createdAt;
  final bool hasQuarterFinals;
  final String currentStage; // 'Group', 'QuarterFinal', 'SemiFinal', 'Final', 'Completed'
  final String status; // 'Draft', 'Ongoing', 'Completed'

  Tournament({
    this.id,
    required this.name,
    required this.createdAt,
    this.hasQuarterFinals = false,
    this.currentStage = 'Group',
    this.status = 'Draft',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'has_quarter_finals': hasQuarterFinals ? 1 : 0,
      'current_stage': currentStage,
      'status': status,
    };
  }

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      hasQuarterFinals: map['has_quarter_finals'] == 1,
      currentStage: map['current_stage'],
      status: map['status'],
    );
  }
}
