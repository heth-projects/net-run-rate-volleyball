import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/schedule_view_model.dart';
import '../viewmodels/match_view_model.dart';

class BulkScheduleScreen extends StatefulWidget {
  final int tournamentId;
  const BulkScheduleScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  State<BulkScheduleScreen> createState() => _BulkScheduleScreenState();
}

class _BulkScheduleScreenState extends State<BulkScheduleScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Schedule'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
             Card(
               elevation: 2,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               child: Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Column(
                   children: [
                     const Icon(Icons.calendar_month_outlined, size: 64, color: Colors.blue),
                     const SizedBox(height: 16),
                     Text(
                       'Group Stage',
                       style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 8),
                     const Text(
                       'Generate Round Robin matches for all groups.',
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.grey),
                     ),
                     const SizedBox(height: 24),
                     if (_isGenerating)
                        const CircularProgressIndicator()
                     else
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _generate,
                            label: const Text('Generate Group Matches'),
                            icon: const Icon(Icons.auto_awesome),
                          ),
                        ),
                   ],
                 ),
               ),
             ),
             const SizedBox(height: 24),
             if (!_isGenerating) ...[
               const Row(
                 children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("KNOCKOUT STAGES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                 ],
               ),
               const SizedBox(height: 24),
               _buildKnockoutCard(
                 context, 
                 'Quarter Finals', 
                 'Generate QF fixtures from Top 2 of each group.', 
                 Icons.looks_one, 
                 () => _generateKnockouts('QF'),
                 Colors.orange
               ),
               const SizedBox(height: 16),
               _buildKnockoutCard(
                 context, 
                 'Semi Finals', 
                 'Generate SF from QF winners.', 
                 Icons.looks_two, 
                 () => _generateKnockouts('SF'),
                 Colors.purple
               ),
               const SizedBox(height: 16),
               _buildKnockoutCard(
                 context, 
                 'Final', 
                 'Generate Final match.', 
                 Icons.emoji_events, 
                 () => _generateKnockouts('Final'),
                 Colors.amber
               ),
             ],
          ],
        ),
      ),
    );
  }

  Widget _buildKnockoutCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: color.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Icon(icon, color: color),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                   ],
                 ),
               ),
               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _generate() async {
    await _runGeneration((vm) => vm.generateRoundRobinSchedule(widget.tournamentId));
  }

  void _generateKnockouts(String stage) async {
     await _runGeneration((vm) => vm.generateKnockoutFixtures(widget.tournamentId, stage));
  }

  Future<void> _runGeneration(Future Function(ScheduleViewModel) action) async {
    setState(() => _isGenerating = true);
    
    final scheduleViewModel = context.read<ScheduleViewModel>();
    final matchViewModel = context.read<MatchViewModel>();
    
    await action(scheduleViewModel);
    
    // Refresh matches in the background view model
    await matchViewModel.loadMatches(widget.tournamentId);

    if (mounted) {
      setState(() => _isGenerating = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule generated successfully!')),
      );
    }
  }
}
