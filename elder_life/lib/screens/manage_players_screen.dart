import 'package:flutter/material.dart';
import '../models/player.dart';
import '../services/local_storage.dart';
import 'player_detail_screen.dart';

class ManagePlayersScreen extends StatefulWidget {
  const ManagePlayersScreen({super.key});

  @override
  _ManagePlayersScreenState createState() => _ManagePlayersScreenState();
}

class _ManagePlayersScreenState extends State<ManagePlayersScreen> {
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() async {
    List<Player> players = await LocalStorage.getPlayers();
    setState(() {
      _players = players;
    });
  }

  void _addPlayer() async {
    String? playerName = await _showAddPlayerDialog();
    if (playerName != null && playerName.isNotEmpty) {
      final newPlayer = Player(
        id: DateTime.now().toString(),
        name: playerName,
      );
      setState(() {
        _players.add(newPlayer);
      });
      await LocalStorage.addPlayer(newPlayer);
    }
  }

  Future<String?> _showAddPlayerDialog() {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Player"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter player name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<String?> _showEditPlayerDialog(String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Player Name"),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: "Enter new player name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editPlayer(int index) async {
    final player = _players[index];
    String? newName = await _showEditPlayerDialog(player.name);
    if (newName != null && newName.isNotEmpty && newName != player.name) {
      setState(() {
        // This line requires that the "name" field in Player is mutable (not final).
        player.name = newName;
      });
      await LocalStorage.updatePlayer(player);
    }
  }

  void _deletePlayer(int index) async {
    final player = _players[index];
    setState(() {
      _players.removeAt(index);
    });
    // If you haven't implemented this method yet, you can comment it out or implement it in your LocalStorage service.
    await LocalStorage.deletePlayer(player);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the AppBar and use custom header/back button.
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/players_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          // Header: Screen title at the top center
          Positioned(
            top: 40,
            left: 24,
            right: 24,
            child: Center(
              child: Text(
                "Manage Players",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
          // Main content: List of players
          Positioned.fill(
            top: 100,
            bottom: 80,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 16, left: 24, right: 24, bottom: 16),
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return ListTile(
                  title: Text(
                    player.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "Wins: ${player.wins} | Losses: ${player.losses}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PlayerDetailScreen(player: player),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _editPlayer(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: () => _deletePlayer(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Floating Action Button for adding players (bottom right)
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: _addPlayer,
              child: const Icon(Icons.add),
            ),
          ),
          // Back button (bottom left)
          Positioned(
            bottom: 24,
            left: 24,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
