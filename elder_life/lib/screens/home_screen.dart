import 'package:flutter/material.dart';
import 'package:elder_life/widgets/custom_circle_icon_text_button.dart'; // Updated import

// Import destination screens
import 'online_game_screen.dart';
import 'new_game_start_screen.dart';       // Offline game
import 'player_stats_screen.dart';
import 'manage_players_screen.dart';       // For player management
import 'player_profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay (opacity increased to 0.7)
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
                  imagePath: 'assets/Offline_Game_Icon.PNG',
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
                  imagePath: 'assets/Online_Game_Icon.PNG',
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
                // Player Management now navigates to ManagePlayersScreen
                CustomCircleIconTextButton(
                  imagePath: 'assets/Player_Icon.PNG',
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
                // New button for Player Stats using an icon from Flutter's icon set
                CustomCircleIconTextButton(
                  iconData: Icons.insert_chart_outlined,
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
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('assets/Profile_Icon.png', fit: BoxFit.contain),
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
