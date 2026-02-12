import 'package:flutter/material.dart';
import '../models/tournament.dart';
import 'teams_view.dart';
import 'matches_view.dart';
import 'standings_view.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Standings', icon: Icon(Icons.table_chart)),
            Tab(text: 'Matches', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Manage Teams', icon: Icon(Icons.people)), 
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StandingsView(tournament: widget.tournament),
          MatchesView(tournament: widget.tournament),
          TeamsView(tournament: widget.tournament),
        ],
      ),
    );
  }
}
