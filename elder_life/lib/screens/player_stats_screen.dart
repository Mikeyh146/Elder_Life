import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../models/player.dart';


class PlayerStatsScreen extends StatefulWidget {
  const PlayerStatsScreen({super.key});

  @override
  _PlayerStatsScreenState createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayerStats();
  }

  Future<void> _loadPlayerStats() async {
    players = await LocalStorage.getPlayers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Stats")),
      body: players.isEmpty
          ? const Center(child: Text("No player data available"))
          : ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text("Wins: ${player.wins} | Losses: ${player.losses} | Games: ${player.gamesPlayed}"),
                  ),
                );
              },
            ),
    );
  }
}
