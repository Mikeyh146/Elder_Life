import 'dart:convert';
import 'dart:html' as html; // For download functionality on Web.
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/local_storage.dart';

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

  /// Download player stats as JSON (Web only).
  void _downloadStats() {
    final jsonData = jsonEncode(players.map((p) => p.toJson()).toList());
    final bytes = utf8.encode(jsonData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none'
      ..download = 'player_stats.json';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// Helper: Build an "indented" card using a matching background and border.
  Widget _buildIndentedCard({required Widget child}) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 2),
      ),
      child: child,
    );
  }

  /// Section 1: Players stats in a DataTable.
  Widget _buildPlayersSection() {
    if (players.isEmpty) {
      return _buildIndentedCard(
        child: const Center(
          child: Text("No player data available",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    }
    return _buildIndentedCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Players",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 12,
                  columns: const [
                    DataColumn(label: Text("Name", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("W", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("L", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("G", style: TextStyle(color: Colors.white))),
                    DataColumn(label: Text("Ratio", style: TextStyle(color: Colors.white))),
                  ],
                  rows: players.map((player) {
                    double ratio = player.losses > 0
                        ? player.wins / player.losses
                        : player.wins.toDouble();
                    return DataRow(cells: [
                      DataCell(Text(player.name, style: const TextStyle(color: Colors.white))),
                      DataCell(Text(player.wins.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(player.losses.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(player.gamesPlayed.toString(), style: const TextStyle(color: Colors.white))),
                      DataCell(Text(ratio.toStringAsFixed(2), style: const TextStyle(color: Colors.white))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 2: Commanders Leaderboard (aggregate wins).
  Widget _buildCommandersLeaderboardSection() {
    Map<String, int> commanderWins = {};
    for (var player in players) {
      player.winCommanders.forEach((commander, wins) {
        commanderWins[commander] = (commanderWins[commander] ?? 0) + wins;
      });
    }
    if (commanderWins.isEmpty) {
      return _buildIndentedCard(
        child: const Center(
          child: Text("No commander wins recorded",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    }
    List<MapEntry<String, int>> sortedList = commanderWins.entries.toList();
    sortedList.sort((a, b) => b.value.compareTo(a.value));
    return _buildIndentedCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Commanders Leaderboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              child: ListView.builder(
                itemCount: sortedList.length,
                itemBuilder: (context, index) {
                  var entry = sortedList[index];
                  return ListTile(
                    dense: true,
                    title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                    trailing: Text(entry.value.toString(), style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 3: Player Leaderboard (sorted by wins).
  Widget _buildPlayerLeaderboardSection() {
    if (players.isEmpty) {
      return _buildIndentedCard(
        child: const Center(
          child: Text("No player data available",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    }
    List<Player> sortedPlayers = List.from(players);
    sortedPlayers.sort((a, b) => b.wins.compareTo(a.wins));
    return _buildIndentedCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Player Leaderboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  Player player = sortedPlayers[index];
                  return ListTile(
                    dense: true,
                    title: Text(player.name, style: const TextStyle(color: Colors.white)),
                    trailing: Text(player.wins.toString(), style: const TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 4: Visual placeholder (graph/chart).
  Widget _buildVisualSection() {
    return _buildIndentedCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text("Graph Visual Placeholder",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Stats")),
      body: players.isEmpty
          ? const Center(child: Text("No player data available"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildPlayersSection(),
                      _buildCommandersLeaderboardSection(),
                      _buildPlayerLeaderboardSection(),
                      _buildVisualSection(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _downloadStats,
                    icon: const Icon(Icons.download),
                    label: const Text("Download Stats"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
