import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tournament.dart';
import '../viewmodels/match_view_model.dart';
import 'bulk_schedule_screen.dart';
import 'match_scorer_screen.dart';
import 'create_match_screen.dart';
import '../repositories/team_repository.dart';
import '../models/team.dart';

class MatchesView extends StatefulWidget {
  final Tournament tournament;
  const MatchesView({Key? key, required this.tournament}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> {
  // Cache teams for display names
  Map<int, Team> _teamCache = {};
  bool _loadingTeams = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchViewModel>().loadMatches(widget.tournament.id!);
    });
  }

  Future<void> _loadTeams() async {
     final repo = TeamRepository();
     final teams = await repo.getTeamsByTournamentId(widget.tournament.id!);
     if (mounted) {
       setState(() {
         _teamCache = {for (var t in teams) t.id!: t};
         _loadingTeams = false;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(), // Empty title, we rely on parent title or use this for actions
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
             onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BulkScheduleScreen(tournamentId: widget.tournament.id!)));
             },
             icon: const Icon(Icons.auto_awesome),
             label: const Text('Auto Schedule'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<MatchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading || _loadingTeams) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_esports_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No matches scheduled'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => BulkScheduleScreen(tournamentId: widget.tournament.id!)));
                    }, 
                    child: const Text('Generate Schedule')
                  ),
                ],
              ),
            );
          }

          // Group matches by Stage
          final grouped = <String, List>{};
          for (var match in viewModel.matches) {
            final key = match.stage;
            if (!grouped.containsKey(key)) grouped[key] = [];
            grouped[key]!.add(match);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: grouped.length + 1, // +1 for extra padding or fab space
            itemBuilder: (context, index) {
              if (index == grouped.length) return const SizedBox(height: 80); // padding for FAB

              final stage = grouped.keys.elementAt(index);
              final matches = grouped[stage]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(stage, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  ...matches.map((match) {
                    final teamA = _teamCache[match.teamAId];
                    final teamB = _teamCache[match.teamBId];
                    if (teamA == null || teamB == null) return const SizedBox.shrink();

                    return Dismissible(
                      key: Key('match_${match.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Match?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await viewModel.deleteMatch(match.id!, widget.tournament.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match deleted')),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScorerScreen(match: match)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: _buildTeamRow(teamA, match.scoreA, true)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'VS', 
                                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey.shade600, fontSize: 12)
                                      ),
                                    ),
                                    Expanded(child: _buildTeamRow(teamB, match.scoreB, false)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('EEE, MMM d • HH:mm').format(match.matchDate),
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    if (match.groupName != null) ...[
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.blue.shade100),
                                        ),
                                        child: Text(match.groupName!, style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateMatchScreen(tournamentId: widget.tournament.id!)));
        },
        label: const Text('Add Match'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTeamRow(Team team, int score, bool isLeft) {
    return Row(
      mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isLeft 
        ? [
            Flexible(
              child: Text(
                team.name, 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), 
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 12),
            _buildScoreBadge(score, team.color),
          ]
        : [
            _buildScoreBadge(score, team.color),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                team.name, 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16), 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
    );
  }
  
  Widget _buildScoreBadge(int score, int colorValue) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color(colorValue).withOpacity(0.1),
        border: Border.all(color: Color(colorValue), width: 2),
        shape: BoxShape.circle,
      ),
      child: Text(
        score.toString(), 
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(colorValue))
      ),
    );
  }
}
