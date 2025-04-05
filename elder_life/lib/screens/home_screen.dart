import 'package:flutter/material.dart';
import 'select_players_screen.dart';
import 'online_game_screen.dart';
import 'player_stats_screen.dart';
import 'manage_players_screen.dart';
import 'player_profile_screen.dart';
import 'settings_screen.dart';
import 'package:elder_life/widgets/custom_circle_icon_text_button.dart';
import 'package:elder_life/screens/new_game_start_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image (if you want to keep it) or a color.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay (increased opacity to 0.7).
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          // Left column: Offline Game, Online Game, Player Management, and Player Stats
          Positioned(
            top: 150,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCircleIconTextButton(
                  // Use stock icon for offline game.
                  iconData: Icons.videogame_asset,
                  label: 'Offline Game',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewGameStartScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomCircleIconTextButton(
                  // Use stock icon for online game.
                  iconData: Icons.wifi,
                  label: 'Online Game',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnlineGameScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomCircleIconTextButton(
                  // Use stock icon for player management.
                  iconData: Icons.people,
                  label: 'Player Management',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagePlayersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomCircleIconTextButton(
                  // Use stock icon for player stats.
                  iconData: Icons.insert_chart,
                  label: 'Player Stats',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerStatsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Top right: Player Profile button (no text)
          Positioned(
            top: 24,
            right: 24,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 32, color: Colors.black),
                ),
              ),
            ),
          ),
          // Bottom right: Settings button with a cog icon (no text)
          Positioned(
            bottom: 24,
            right: 24,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.settings, color: Colors.black, size: 32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
