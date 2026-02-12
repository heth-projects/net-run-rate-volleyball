import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../viewmodels/match_view_model.dart';
import '../viewmodels/team_view_model.dart';
import '../repositories/match_repository.dart';

class CreateMatchScreen extends StatefulWidget {
  final int tournamentId;
  const CreateMatchScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Team? _selectedTeamA;
  Team? _selectedTeamB;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedStage = 'Group';
  
  final List<String> _stages = ['Group', 'QF', 'SF', 'Final'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamViewModel>().loadTeams(widget.tournamentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Match'), centerTitle: true),
      body: Consumer<TeamViewModel>(
        builder: (context, teamViewModel, child) {
          if (teamViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final teams = teamViewModel.teams;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Match Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<Team>(
                        decoration: InputDecoration(
                          labelText: 'Team A',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.shield_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: _selectedTeamA,
                        items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                        onChanged: (val) => setState(() => _selectedTeamA = val),
                        validator: (val) => val == null ? 'Please select Team A' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<Team>(
                        decoration: InputDecoration(
                          labelText: 'Team B',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.shield),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: _selectedTeamB,
                        items: teams.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                        onChanged: (val) => setState(() => _selectedTeamB = val),
                        validator: (val) => val == null || val == _selectedTeamA ? 'Please select a different Team B' : null,
                      ),
                      const SizedBox(height: 24),
                      InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(12),
                         child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.blue),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Date & Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    DateFormat('EEE, MMM d, yyyy • HH:mm').format(
                                      DateTime(
                                        _selectedDate.year, 
                                        _selectedDate.month, 
                                        _selectedDate.day, 
                                        _selectedTime.hour, 
                                        _selectedTime.minute
                                      )
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Stage',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.flag_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        value: _selectedStage,
                        items: _stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) => setState(() => _selectedStage = val!),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _saveMatch,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Schedule Match', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  void _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      final matchDate = DateTime(
        _selectedDate.year, 
        _selectedDate.month, 
        _selectedDate.day, 
        _selectedTime.hour, 
        _selectedTime.minute
      );
      
      final match = TournamentMatch(
        tournamentId: widget.tournamentId,
        teamAId: _selectedTeamA!.id!,
        teamBId: _selectedTeamB!.id!,
        matchDate: matchDate,
        stage: _selectedStage,
        status: 'Scheduled',
        groupName: _selectedStage == 'Group' ? _selectedTeamA!.groupName : null, // Inherit group if group stage
      );
      
      final repo = MatchRepository();
      await repo.createMatch(match);
      
      // Refresh
      if (mounted) {
         context.read<MatchViewModel>().loadMatches(widget.tournamentId);
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Match scheduled manually!')),
         );
      }
    }
  }
}
