import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../viewmodels/match_view_model.dart';
import '../models/team.dart';
import '../repositories/team_repository.dart';

class MatchScorerScreen extends StatefulWidget {
  final TournamentMatch match;
  const MatchScorerScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<MatchScorerScreen> createState() => _MatchScorerScreenState();
}

class _MatchScorerScreenState extends State<MatchScorerScreen> {
  late int _scoreA;
  late int _scoreB;
  
  final TextEditingController _pointsAController = TextEditingController();
  final TextEditingController _pointsBController = TextEditingController();
  
  Team? _teamA;
  Team? _teamB;
  bool _isLoadingTeams = true;

  @override
  void initState() {
    super.initState();
    _scoreA = widget.match.scoreA;
    _scoreB = widget.match.scoreB;
    _pointsAController.text = widget.match.pointsA.toString();
    _pointsBController.text = widget.match.pointsB.toString();
    _loadTeams();
  }
  
  @override
  void dispose() {
    _pointsAController.dispose();
    _pointsBController.dispose();
    super.dispose();
  }
  
  void _loadTeams() async {
     final repo = TeamRepository();
     _teamA = await repo.getTeamById(widget.match.teamAId);
     _teamB = await repo.getTeamById(widget.match.teamBId);
     setState(() => _isLoadingTeams = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingTeams) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Score'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Scoreboard Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildTeamHeader(_teamA!)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text('VS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.grey)),
                        ),
                        Expanded(child: _buildTeamHeader(_teamB!)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text('SETS WON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScoreDisplay(_scoreA, (val) => setState(() => _scoreA = val)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text('-', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w300)),
                        ),
                        _buildScoreDisplay(_scoreB, (val) => setState(() => _scoreB = val)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Points Section
            const Text('TOTAL POINTS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text('Crucial for Tie-Breakers (NRR)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPointsInput(_teamA!, _pointsAController),
                const SizedBox(width: 24),
                _buildPointsInput(_teamB!, _pointsBController),
              ],
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _saveScore,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Save Result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTeamHeader(Team team) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Color(team.color),
          radius: 36,
          child: Text(
            team.name.substring(0, 1).toUpperCase(), 
            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 12),
        Text(
          team.name, 
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildScoreDisplay(int value, Function(int) onChanged) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, size: 32),
          onPressed: () => onChanged(value + 1),
          visualDensity: VisualDensity.compact,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.toString(), 
            style: TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => onChanged(value > 0 ? value - 1 : 0),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
  
  Widget _buildPointsInput(Team team, TextEditingController controller) {
      return Expanded(
        child: Column(
          children: [
            Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                ]
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                   IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                       int val = int.tryParse(controller.text) ?? 0;
                       if (val > 0) val--;
                       controller.text = val.toString();
                    },
                   ),
                   Expanded(
                     child: TextFormField(
                       controller: controller,
                       textAlign: TextAlign.center,
                       style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                       keyboardType: TextInputType.number,
                       decoration: const InputDecoration(
                         border: InputBorder.none,
                         hintText: '0',
                         hintStyle: TextStyle(color: Colors.grey),
                         isDense: true,
                       ),
                     ),
                   ),
                   IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: () {
                       int val = int.tryParse(controller.text) ?? 0;
                       val++;
                       controller.text = val.toString();
                    },
                   ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  void _saveScore() async {
    final viewModel = context.read<MatchViewModel>();
    int pointsA = int.tryParse(_pointsAController.text) ?? 0;
    int pointsB = int.tryParse(_pointsBController.text) ?? 0;
    
    await viewModel.updateMatchScore(widget.match, _scoreA, _scoreB, pointsA, pointsB);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Score updated successfully!')),
      );
    }
  }
}
