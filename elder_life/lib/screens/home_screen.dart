import 'package:flutter/material.dart';
import 'new_game_start_screen.dart';
import 'online_game_screen.dart';
import 'player_or_pod_screen.dart';
import 'player_stats_screen.dart';
import 'settings_screen.dart';
import 'player_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Top row: Sign In and Settings
                Positioned(
                  top: 20,
                  right: 20,
                  child: Row(
                    children: [
                      _circleButton(
                        icon: Icons.person,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlayerProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _circleButton(
                        icon: Icons.settings,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Centered 2x2 button grid
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: isLandscape ? constraints.maxWidth * 0.9 : constraints.maxWidth * 0.95,
                    height: isLandscape ? constraints.maxHeight * 0.7 : constraints.maxHeight * 0.5,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 32,
                      mainAxisSpacing: 32,
                      padding: const EdgeInsets.all(16),
                      childAspectRatio: 2, // Makes each button half the height of its width
                      children: [
                        _glowGridButton(
                          icon: Icons.videogame_asset,
                          label: 'New Game',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewGameStartScreen(),
                              ),
                            );
                          },
                        ),
                        _glowGridButton(
                          icon: Icons.wifi,
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
                        _glowGridButton(
                          icon: Icons.people,
                          label: 'Players/Pods',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlayerOrPodScreen(),
                              ),
                            );
                          },
                        ),
                        _glowGridButton(
                          icon: Icons.insert_chart,
                          label: 'Game Statistics',
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _glowGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            const BoxShadow(
              color: Colors.white10,
              blurRadius: 10,
              offset: Offset(-4, -4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 10,
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(offset: Offset(0, 1), color: Colors.black54, blurRadius: 2),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 26, color: Colors.white),
      ),
    );
  }
}
