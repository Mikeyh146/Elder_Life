import 'package:flutter/material.dart';
import 'select_players_screen.dart';
import 'manage_players_screen.dart';
import 'linked_game_screen.dart';
import '../models/player.dart';

class NewGameStartScreen extends StatelessWidget {
  const NewGameStartScreen({super.key});

  // For New Game: Ask for number of players then navigate.
  Future<void> _selectNewGame(BuildContext context) async {
    final numPlayers = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How many players? (2-6)"),
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
          builder: (context) => SelectPlayersScreen(
            numberOfPlayers: numPlayers,
            gameType: "commander", // assuming New Game is a commander type
            startingLife: 40,
          ),
        ),
      );
    }
  }

  // For Tournament Game: Placeholder.
  void _selectTournamentGame(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tournament Game coming soon!")),
    );
  }

  // For Linked Game: Navigate to the LinkedGameScreen.
  void _selectLinkedGame(BuildContext context) {
    // Create a dummy host for now. Replace this with your real host player later.
    Player dummyHost = Player(id: 'host1', name: 'Host Player');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LinkedGameScreen(host: dummyHost),
      ),
    );
  }

  // For managing players.
  void _goToManagePlayers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManagePlayersScreen(),
      ),
    );
  }

  // Build an option card widget.
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to create a 2x2 grid that adapts to the available space.
    return Scaffold(
      appBar: AppBar(title: const Text("New Game")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define spacing between grid cells.
          const double spacing = 16.0;
          // Calculate cell width and height for a 2x2 grid.
          final cellWidth = (constraints.maxWidth - spacing * 3) / 2;
          final cellHeight = (constraints.maxHeight - spacing * 3) / 2;
          final aspectRatio = cellWidth / cellHeight;

          return Padding(
            padding: const EdgeInsets.all(spacing),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
              children: [
                _buildOptionCard(
                  context: context,
                  title: "New Game",
                  icon: Icons.play_arrow,
                  onTap: () => _selectNewGame(context),
                ),
                _buildOptionCard(
                  context: context,
                  title: "Tournament Game",
                  icon: Icons.emoji_events,
                  onTap: () => _selectTournamentGame(context),
                ),
                _buildOptionCard(
                  context: context,
                  title: "Linked Game",
                  icon: Icons.link,
                  onTap: () => _selectLinkedGame(context),
                ),
                _buildOptionCard(
                  context: context,
                  title: "Manage Players",
                  icon: Icons.people,
                  onTap: () => _goToManagePlayers(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
