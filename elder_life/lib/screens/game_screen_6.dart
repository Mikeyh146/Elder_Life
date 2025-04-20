import 'package:flutter/material.dart';
import '../models/player.dart';

class GameScreen6 extends StatelessWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame;

  const GameScreen6({
    super.key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("6 Player Game")),
      body: Center(
        child: Text("Game Screen for 6 players\nPlayers: ${players.map((p) => p.name).join(', ')}"),
      ),
    );
  }
}
