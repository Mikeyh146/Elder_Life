import 'package:flutter/material.dart';
import 'select_players_screen.dart';
import 'quick_game_screen_2.dart';
import 'quick_game_screen_4.dart';
import '../models/pod.dart';
import '../services/local_storage.dart';

class NewGameStartScreen extends StatelessWidget {
  const NewGameStartScreen({super.key});

  Future<void> _showQuickGameDialog(BuildContext context) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quick Game"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("2 Players"),
              onTap: () => Navigator.pop(context, 2),
            ),
            ListTile(
              title: const Text("4 Players"),
              onTap: () => Navigator.pop(context, 4),
            ),
          ],
        ),
      ),
    );

    if (selected == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickGameScreen2()));
    } else if (selected == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickGameScreen4()));
    }
  }

  Future<void> _showCommanderDialog(BuildContext context) async {
    final numPlayers = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Commander Game"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            int count = index + 2;
            return ListTile(
              title: Text("$count players"),
              onTap: () => Navigator.pop(context, count),
            );
          }),
        ),
      ),
    );

    if (numPlayers != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectPlayersScreen(
            numberOfPlayers: numPlayers,
            gameType: "commander",
            startingLife: 40,
          ),
        ),
      );
    }
  }

  Future<void> _showPodSelectionDialog(BuildContext context) async {
    final pods = await LocalStorage.getPods(); // Assumes you have this
    final selectedPod = await showDialog<Pod>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Pod"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pods.length,
            itemBuilder: (context, index) {
              final pod = pods[index];
              return ListTile(
                title: Text(pod.name),
                onTap: () => Navigator.pop(context, pod),
              );
            },
          ),
        ),
      ),
    );

    if (selectedPod != null) {
      // TODO: Navigate to Pod Game Setup screen (or reuse commander logic with pod players)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected pod: ${selectedPod.name}")),
      );
    }
  }

  void _showTournamentComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Tournament Mode"),
        content: Text("Coming soon!"),
      ),
    );
  }

  Widget _buildGameButton(String label, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Game")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 4, // Set to 4 columns
          crossAxisSpacing: 16, // Horizontal spacing between the buttons
          mainAxisSpacing: 16, // Vertical spacing between the buttons
          children: [
            _buildGameButton("Quick Game", Icons.flash_on, () => _showQuickGameDialog(context)),
            _buildGameButton("Commander Game", Icons.shield, () => _showCommanderDialog(context)),
            _buildGameButton("Pod Game", Icons.group, () => _showPodSelectionDialog(context)),
            _buildGameButton("Tournament Game", Icons.emoji_events, () => _showTournamentComingSoon(context)),
            // Add more buttons as needed, following the same pattern.
          ],
        ),
      ),
    );
  }
}
