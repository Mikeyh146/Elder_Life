import 'package:flutter/material.dart';
import 'package:elder_life/screens/new_game_start_screen.dart';
import 'package:elder_life/screens/manage_players_screen.dart';
import 'package:elder_life/screens/player_stats_screen.dart';
import 'package:elder_life/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Elder Life")),
      // Use LayoutBuilder to size the GridView to fill the screen in landscape.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // childAspectRatio determines each cell's width/height ratio.
          // For a 2×2 grid on a 1024×768 screen, you can try ~1.33 (width/height).
          // Adjust if you prefer bigger or smaller cells.
          final double aspectRatio = constraints.maxWidth / constraints.maxHeight;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,        // 2 columns
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              // Use the computed aspect ratio so each cell fits the screen without scrolling.
              childAspectRatio: aspectRatio,
              children: [
                _buildOptionCard(
                  context: context,
                  title: "New Game",
                  icon: Icons.play_arrow,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewGameStartScreen()),
                    );
                  },
                ),
                _buildOptionCard(
                  context: context,
                  title: "Manage Players",
                  icon: Icons.people,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManagePlayersScreen()),
                    );
                  },
                ),
                _buildOptionCard(
                  context: context,
                  title: "Player Stats",
                  icon: Icons.bar_chart,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PlayerStatsScreen()),
                    );
                  },
                ),
                _buildOptionCard(
                  context: context,
                  title: "Settings",
                  icon: Icons.settings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
