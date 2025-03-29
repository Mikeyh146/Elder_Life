import 'package:flutter/material.dart';
import '../models/player.dart';

class LinkedGameScreen extends StatefulWidget {
  final Player host;
  const LinkedGameScreen({super.key, required this.host});

  @override
  _LinkedGameScreenState createState() => _LinkedGameScreenState();
}

class _LinkedGameScreenState extends State<LinkedGameScreen> {
  // Lobby players list (initially only the host).
  late List<Player> lobbyPlayers;

  @override
  void initState() {
    super.initState();
    lobbyPlayers = [widget.host];
    // In a real implementation, you'll connect to a lobby service here.
  }

  /// Simulate a player joining the lobby.
  /// In practice, you'll receive these events from your lobby service.
  void _simulateJoin(Player player) {
    setState(() {
      if (!lobbyPlayers.contains(player)) {
        lobbyPlayers.add(player);
      }
    });
  }

  /// Simulate a player leaving the lobby.
  void _simulateLeave(Player player) {
    setState(() {
      lobbyPlayers.remove(player);
    });
  }

  /// Called by the host to start the game.
  /// This should navigate to the game screen with the current lobby players.
  void _startGame() {
    // Replace this with your navigation to the GameScreen, passing lobbyPlayers.
    Navigator.pushReplacementNamed(context, '/game', arguments: lobbyPlayers);
  }

  @override
  Widget build(BuildContext context) {
    // For simplicity, we assume the host is always lobbyPlayers.first.
    bool isHost = lobbyPlayers.first.id == widget.host.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Linked Game Lobby"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the host.
            Text(
              "Host: ${widget.host.name}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display the list of lobby players.
            Expanded(
              child: ListView.builder(
                itemCount: lobbyPlayers.length,
                itemBuilder: (context, index) {
                  final player = lobbyPlayers[index];
                  return ListTile(
                    title: Text(player.name),
                    trailing: (player.id == widget.host.id)
                        ? const Text("Host", style: TextStyle(fontWeight: FontWeight.bold))
                        : IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            onPressed: () => _simulateLeave(player),
                          ),
                  );
                },
              ),
            ),
            // Only the host sees the Start Game button.
            if (isHost)
              ElevatedButton(
                onPressed: lobbyPlayers.length >= 2 ? _startGame : null,
                child: const Text("Start Game"),
              ),
            const SizedBox(height: 20),
            // For testing: a button to simulate a join.
            // In your real app, new players would join via a network event.
            ElevatedButton(
              onPressed: () {
                // Simulate a new player joining (for testing purposes).
                // In a real lobby, you would receive this data from the server.
                Player newPlayer = Player(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: "Player ${lobbyPlayers.length + 1}",
                );
                _simulateJoin(newPlayer);
              },
              child: const Text("Simulate Player Join"),
            ),
          ],
        ),
      ),
    );
  }
}
