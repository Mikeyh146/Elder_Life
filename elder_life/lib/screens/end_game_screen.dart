import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/local_storage.dart';

class EndGameScreen extends StatefulWidget {
  final List<Player> players;
  const EndGameScreen({super.key, required this.players});

  @override
  _EndGameScreenState createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  Player? winner;
  // Map of losing player's ID to the name of the defeater.
  final Map<String, String> defeatDetails = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("End Game")),
      body: Center(
        child: winner == null ? _buildWinnerSelection() : _buildSummary(),
      ),
    );
  }

  Widget _buildWinnerSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Who won the game?", style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        ...widget.players.map((player) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    winner = player;
                  });
                  await _collectDefeatDetails();
                },
                child: Text(player.name, style: const TextStyle(fontSize: 18)),
              ),
            )),
      ],
    );
  }

  Future<void> _collectDefeatDetails() async {
    // For every player who is not the winner, ask who defeated them.
    for (var player in widget.players) {
      if (player.id != winner!.id) {
        String? defeater = await _showDefeatDialog(player);
        if (defeater != null) {
          defeatDetails[player.id] = defeater;
        }
      }
    }
    // Once defeat details are collected, update stats.
    _updatePlayerStats();
    setState(() {}); // refresh UI to show summary
  }

  Future<String?> _showDefeatDialog(Player loser) async {
    // Allow selection of any other player as the defeater.
    List<Player> possibleDefeaters =
        widget.players.where((p) => p.id != loser.id).toList();

    Player? selected;
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // Force selection.
      builder: (context) {
        return AlertDialog(
          title: Text("Who defeated ${loser.name}?"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<Player>(
                isExpanded: true,
                hint: const Text("Select a player"),
                value: selected,
                onChanged: (Player? value) {
                  setState(() {
                    selected = value;
                  });
                },
                items: possibleDefeaters.map((Player p) {
                  return DropdownMenuItem<Player>(
                    value: p,
                    child: Text(p.name),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selected != null) {
                  Navigator.pop(context, selected!.name);
                }
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Game Over",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("Winner: ${winner!.name}",
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          const Text("Defeat Details:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...widget.players.where((p) => p.id != winner!.id).map((p) {
            String defeater = defeatDetails[p.id] ?? "Unknown";
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text("${p.name} was defeated by $defeater",
                  style: const TextStyle(fontSize: 18)),
            );
          }),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate back home and persist updated stats.
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text("Finish Game", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

 void _updatePlayerStats() async {
  // Update games played and wins/losses
  for (var player in widget.players) {
    player.gamesPlayed++;
    if (player.id == winner!.id) {
      player.wins++;
    } else {
      player.losses++;
    }
  }

  // Update playersDefeated for each defeat detail.
  for (var loserId in defeatDetails.keys) {
    String defeaterName = defeatDetails[loserId]!;
    try {
      Player defeater = widget.players.firstWhere((p) => p.name == defeaterName);
      defeater.playersDefeated++;
    } catch (_) {
      // If no matching defeater is found, ignore.
    }
  }

  // Persist updated stats for all players at once.
  await LocalStorage.updateAllStats(widget.players);
}
}
