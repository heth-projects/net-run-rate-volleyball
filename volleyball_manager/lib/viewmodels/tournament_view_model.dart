import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../repositories/tournament_repository.dart';

class TournamentViewModel extends ChangeNotifier {
  final TournamentRepository _repository = TournamentRepository();
  List<Tournament> _tournaments = [];
  bool _isLoading = false;

  List<Tournament> get tournaments => _tournaments;
  bool get isLoading => _isLoading;

  Future<void> loadTournaments() async {
    _isLoading = true;
    notifyListeners();
    try {
      _tournaments = await _repository.getAllTournaments();
    } catch (e) {
      debugPrint("Error loading tournaments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTournament(String name, bool hasQuarterFinals) async {
    final tournament = Tournament(
      name: name,
      createdAt: DateTime.now(),
      hasQuarterFinals: hasQuarterFinals,
      currentStage: 'Group',
      status: 'Draft',
    );
    await _repository.createTournament(tournament);
    await loadTournaments();
  }

  Future<void> deleteTournament(int id) async {
    await _repository.deleteTournament(id);
    await loadTournaments();
  }
  
  Future<void> updateTournamentStage(Tournament tournament, String newStage) async {
     final updated = Tournament(
       id: tournament.id,
       name: tournament.name,
       createdAt: tournament.createdAt,
       hasQuarterFinals: tournament.hasQuarterFinals,
       currentStage: newStage,
       status: tournament.status // or update status if needed
     );
     await _repository.updateTournament(updated);
     await loadTournaments();
  }
}
