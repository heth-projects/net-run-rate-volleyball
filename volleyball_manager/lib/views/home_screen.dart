import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/tournament_view_model.dart';
import '../models/tournament.dart';
import 'create_tournament_screen.dart';
import 'tournament_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentViewModel>().loadTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volleyball Tournaments'),
      ),
      body: Consumer<TournamentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (viewModel.tournaments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.sports_volleyball, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tournaments found'),
                  Text('Tap + to create one'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.tournaments.length,
            itemBuilder: (context, index) {
              final tournament = viewModel.tournaments[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TournamentDetailScreen(tournament: tournament)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                tournament.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'delete', child: Text('Delete Tournament')),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Tournament?'),
                                      content: const Text('This will delete all teams and matches within it.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                        FilledButton(
                                          onPressed: () {
                                            viewModel.deleteTournament(tournament.id!);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildStatusChip(context, tournament.status, Colors.blue),
                            _buildStatusChip(context, tournament.currentStage, Colors.orange),
                            if (tournament.hasQuarterFinals)
                               _buildStatusChip(context, "Knockouts Enabled", Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              "Created: ${tournament.createdAt.toString().split(' ').first}", 
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward, color: Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create screen
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTournamentScreen()));
        },
        label: const Text('New Tournament'),
        icon: const Icon(Icons.add),
      ),
    );
  }
  Widget _buildStatusChip(BuildContext context, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(color: color.shade800, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
