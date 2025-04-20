import 'package:flutter/material.dart';
import 'manage_players_screen.dart';
import 'pod_screen.dart';
import 'home_screen.dart';

class PlayerOrPodScreen extends StatelessWidget {
  const PlayerOrPodScreen({super.key});

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
                // Bottom-left back button
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: _circleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    ),
                  ),
                ),

                // Centered vertical 1x2 button layout
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: isLandscape ? constraints.maxWidth * 0.5 : constraints.maxWidth * 0.8,
                    height: isLandscape ? constraints.maxHeight * 0.6 : constraints.maxHeight * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _glowButton(
                          icon: Icons.people,
                          label: 'Manage Players',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManagePlayersScreen(),
                              ),
                            );
                          },
                        ),
                        _glowButton(
                          icon: Icons.folder_shared,
                          label: 'Pods',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PodScreen(),
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

  Widget _glowButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        width: double.infinity,
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
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
