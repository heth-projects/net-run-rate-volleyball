import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../viewmodels/team_view_model.dart';
import 'add_team_screen.dart';

class TeamsView extends StatefulWidget {
  final Tournament tournament;
  const TeamsView({Key? key, required this.tournament}) : super(key: key);

  @override
  State<TeamsView> createState() => _TeamsViewState();
}

class _TeamsViewState extends State<TeamsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamViewModel>().loadTeams(widget.tournament.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TeamViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.teams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No teams added yet'),
                  Text('Add teams to start scheduling'),
                ],
              ),
            );
          }
          
          // Group by Group Name for nicer display
          final grouped = <String, List>{};
          for (var team in viewModel.teams) {
             final key = team.groupName ?? 'Ungrouped';
             if (!grouped.containsKey(key)) grouped[key] = [];
             grouped[key]!.add(team);
          }

          return ListView.builder(
            itemCount: grouped.keys.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final groupName = grouped.keys.elementAt(index);
              final teams = grouped[groupName]!;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
                    child: Text(
                      groupName.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...teams.map((team) => Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(team.color),
                        child: Text(
                          team.name.substring(0, 1).toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
                        ),
                      ),
                      title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () {
                           showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Team?'),
                                content: const Text('This will remove the team from the tournament.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                  FilledButton(
                                    onPressed: () {
                                      viewModel.deleteTeam(team.id!, widget.tournament.id!);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                        },
                      ),
                    ),
                  )).toList(),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddTeamScreen(tournamentId: widget.tournament.id!)));
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
