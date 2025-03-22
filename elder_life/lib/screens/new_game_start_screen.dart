import 'package:flutter/material.dart';
import 'select_players_screen.dart';
import 'manage_players_screen.dart';

class NewGameStartScreen extends StatelessWidget {
  const NewGameStartScreen({super.key});

  // For Commander: ask for number of players then navigate.
  Future<void> _selectCommanderGame(BuildContext context) async {
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
            gameType: "commander",
            startingLife: 40,
          ),
        ),
      );
    }
  }

  // For Commander Brawl: fixed 2 players with 25 starting life.
  void _selectCommanderBrawl(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPlayersScreen(
          numberOfPlayers: 2,
          gameType: "commander-brawl",
          startingLife: 25,
        ),
      ),
    );
  }

  // For Standard: fixed 2 players with 20 starting life.
  void _selectStandard(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPlayersScreen(
          numberOfPlayers: 2,
          gameType: "standard",
          startingLife: 20,
        ),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine the available space.
    return Scaffold(
      appBar: AppBar(title: const Text("New Game")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define spacing between grid cells.
          const double spacing = 16.0;
          // Calculate cell width and height for a 2x2 grid:
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
                  title: "Commander",
                  icon: Icons.star,
                  onTap: () => _selectCommanderGame(context),
                ),
                _buildOptionCard(
                  context: context,
                  title: "Commander Brawl",
                  icon: Icons.sports_mma,
                  onTap: () => _selectCommanderBrawl(context),
                ),
                _buildOptionCard(
                  context: context,
                  title: "Standard",
                  icon: Icons.videogame_asset,
                  onTap: () => _selectStandard(context),
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
