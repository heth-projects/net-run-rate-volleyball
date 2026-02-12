import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/match_view_model.dart';
import '../models/tournament.dart';

class StandingsView extends StatefulWidget {
  final Tournament tournament;
  const StandingsView({Key? key, required this.tournament}) : super(key: key);

  @override
  State<StandingsView> createState() => _StandingsViewState();
}

class _StandingsViewState extends State<StandingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchViewModel>().loadMatches(widget.tournament.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MatchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.groupStandings.isEmpty) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No standings available'),
                  Text('Schedule matches to see points table'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.groupStandings.keys.length,
            itemBuilder: (context, index) {
              final groupName = viewModel.groupStandings.keys.elementAt(index);
              final statsList = viewModel.groupStandings[groupName]!;

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
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)),
                        columnSpacing: 24,
                        horizontalMargin: 20,
                        headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                        columns: const [
                          DataColumn(label: Text('Team')),
                          DataColumn(label: Text('P'), tooltip: 'Played', numeric: true),
                          DataColumn(label: Text('W'), tooltip: 'Won', numeric: true),
                          DataColumn(label: Text('L'), tooltip: 'Lost', numeric: true),
                          DataColumn(label: Text('Pts'), tooltip: 'Points', numeric: true),
                          DataColumn(label: Text('NRR'), tooltip: 'Net Run Rate', numeric: true),
                        ],
                        rows: statsList.map((stats) {
                          return DataRow(cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(stats.teamColor),
                                    radius: 6,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(stats.teamName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              )
                            ),
                            DataCell(Text(stats.played.toString())),
                            DataCell(Text(stats.won.toString(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(Text(stats.lost.toString(), style: const TextStyle(color: Colors.red))),
                            DataCell(Text(stats.points.toString(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                            DataCell(Text(stats.nrr.toStringAsFixed(3))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
