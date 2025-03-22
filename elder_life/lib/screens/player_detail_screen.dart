import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/player.dart';
import '../models/commander.dart';
import '../services/local_storage.dart';


/// Model to store search results from Scryfall.
class CommanderSearchResult {
  final String name;
  final String imageUrl;

  CommanderSearchResult({required this.name, required this.imageUrl});
}

class PlayerDetailScreen extends StatefulWidget {
  final Player player;
  const PlayerDetailScreen({super.key, required this.player});

  @override
  _PlayerDetailScreenState createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  // We'll keep a local copy of the player data so we can refresh it.
  Player? currentPlayer;

  @override
  void initState() {
    super.initState();
    _reloadPlayer();
  }

  Future<void> _reloadPlayer() async {
    List<Player> players = await LocalStorage.getPlayers();
    final updatedPlayer = players.firstWhere(
      (p) => p.id == widget.player.id,
      orElse: () => widget.player,
    );
    setState(() {
      currentPlayer = updatedPlayer;
    });
    print("Reloaded player: ${currentPlayer?.toJson()}");
  }

  Future<void> _updatePlayerInStorage() async {
    await LocalStorage.updatePlayer(currentPlayer!);
    print("Updated player saved: ${currentPlayer?.toJson()}");
    await _reloadPlayer();
  }

  Future<void> _addCommander() async {
    if (currentPlayer!.commanders.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum of 6 commanders reached.")),
      );
      return;
    }

    CommanderSearchResult? selectedCommander =
        await showDialog<CommanderSearchResult>(
      context: context,
      builder: (context) {
        String searchText = "";
        List<CommanderSearchResult> results = [];
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Search for a Commander"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: (value) async {
                      searchText = value;
                      if (searchText.isNotEmpty) {
                        List<CommanderSearchResult> searchResults =
                            await _searchCommanders(searchText);
                        setState(() {
                          results = searchResults;
                        });
                      } else {
                        setState(() {
                          results = [];
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter commander name",
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    width: double.maxFinite,
                    child: results.isEmpty
                        ? const Center(child: Text("No results"))
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final result = results[index];
                              return ListTile(
                                leading: Image.network(
                                  result.imageUrl,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 50);
                                  },
                                ),
                                title: Text(result.name),
                                onTap: () => Navigator.pop(context, result),
                              );
                            },
                          ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedCommander != null && selectedCommander.name.isNotEmpty) {
      setState(() {
        currentPlayer!.commanders.add(
          Commander(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: selectedCommander.name,
            imageUrl: selectedCommander.imageUrl,
          ),
        );
      });
      print("Commander added: ${selectedCommander.name}");
      await _updatePlayerInStorage();
    }
  }

  Future<List<CommanderSearchResult>> _searchCommanders(String query) async {
    final searchQuery = "is:commander $query";
    final url = Uri.parse("https://api.scryfall.com/cards/search?q=$searchQuery");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('data')) {
          final List<dynamic> cards = data['data'];
          return cards.map((card) {
            final imageUrl = card['image_uris']?['small'] ?? "";
            return CommanderSearchResult(
              name: card['name'] as String,
              imageUrl: imageUrl,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Error searching commanders: $e");
    }
    return [];
  }

  void _showCommanderImage(Commander commander) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(commander.name),
          content: Image.network(
            commander.imageUrl,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, size: 100);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayPlayer = currentPlayer ?? widget.player;
    return Scaffold(
      appBar: AppBar(title: Text(displayPlayer.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Section
            const Text("Player Stats",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Wins: ${displayPlayer.wins}",
                style: const TextStyle(fontSize: 18)),
            Text("Losses: ${displayPlayer.losses}",
                style: const TextStyle(fontSize: 18)),
            Text("Games Played: ${displayPlayer.gamesPlayed}",
                style: const TextStyle(fontSize: 18)),
            const Divider(height: 30, thickness: 2),
            // Commanders Section
            const Text("Commanders",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            displayPlayer.commanders.isEmpty
                ? const Text("No commanders added.",
                    style: TextStyle(fontSize: 18))
                : Column(
                    children: displayPlayer.commanders.map((commander) {
                      return ListTile(
                        leading: Image.network(
                          commander.imageUrl,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 50);
                          },
                        ),
                        title: Text(commander.name,
                            style: const TextStyle(fontSize: 18)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            setState(() {
                              displayPlayer.commanders.remove(commander);
                            });
                            await _updatePlayerInStorage();
                          },
                        ),
                        onTap: () => _showCommanderImage(commander),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _addCommander,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                ),
                child: const Text("Add a Commander",
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
