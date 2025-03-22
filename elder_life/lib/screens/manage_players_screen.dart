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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Players")),
      body: ListView.builder(
        itemCount: _players.length,
        itemBuilder: (context, index) {
          final player = _players[index];
          return ListTile(
            title: Text(player.name),
            subtitle: Text("Wins: ${player.wins} | Losses: ${player.losses}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlayerDetailScreen(player: player)),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Implement deletion if needed.
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
