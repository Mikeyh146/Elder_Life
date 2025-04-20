import 'package:flutter/material.dart';
import '../models/player.dart';

class GameScreen5 extends StatelessWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame;

  const GameScreen5({
    super.key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("5 Player Game")),
      body: Center(
        child: Text("Game Screen for 5 players\nPlayers: ${players.map((p) => p.name).join(', ')}"),
      ),
    );
  }
}
