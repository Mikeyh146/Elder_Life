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
  final bool isCommanderGame;

  const PlayerDetailScreen({
    Key? key,
    required this.player,
    this.isCommanderGame = false,
  }) : super(key: key);

  @override
  _PlayerDetailScreenState createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
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
                                    return const Icon(Icons.image,
                                        size: 50, color: Colors.white);
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
            final imageUrl = card['image_uris']?['art_crop'] ??
                card['image_uris']?['small'] ??
                "";
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
              return const Icon(Icons.image, size: 100, color: Colors.white);
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

  /// Build the top content (player name, etc.) with no background color.
  /// If Commander game + at least one commander with a valid image => use that image
  /// Otherwise, let the parent's background show through (fully transparent).
  Widget _buildFrontContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row of status icons if needed, or remove entirely if you don't want them.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.player.isMonarch)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.emoji_events, size: 30, color: Colors.yellow),
              ),
            if (widget.player.hasInitiative)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.flash_on, size: 30, color: Colors.lightBlue),
              ),
            if (widget.player.isAscended)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.upgrade, size: 30, color: Colors.purple),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Player name row.
        Row(
          children: [
            Expanded(
              child: Text(
                widget.player.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editPlayerName,
            ),
          ],
        ),
      ],
    );
  }

  // Dialog for editing player's name
  Future<String?> _showEditPlayerNameDialog(String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Player Name"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new player name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _editPlayerName() async {
    if (currentPlayer == null) return;
    String? newName = await _showEditPlayerNameDialog(currentPlayer!.name);
    if (newName != null && newName.isNotEmpty && newName != currentPlayer!.name) {
      setState(() {
        currentPlayer!.name = newName;
      });
      await _updatePlayerInStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPlayer = currentPlayer ?? widget.player;

    // If it's a commander game and there's at least one commander with an image, show that image
    // otherwise we let the parent's background show.
    bool useCommanderBg = widget.isCommanderGame &&
        displayPlayer.commanders.isNotEmpty &&
        displayPlayer.commanders.first.imageUrl.isNotEmpty;

    return Scaffold(
      // No AppBar => full screen background
      body: Stack(
        children: [
          // The main background from your assets
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/player_detail_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.7)),

          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // If we want to show the commander image, do so here. If not, do nothing.
                if (useCommanderBg)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          displayPlayer.commanders.first.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey[900]);
                          },
                        ),
                        // Optional additional overlay if needed
                        Container(color: Colors.black.withOpacity(0.3)),
                        // Then the top content (player name, etc.)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildFrontContent(),
                        ),
                      ],
                    ),
                  )
                else
                  // If no commander image, just show the top content with no box background
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildFrontContent(),
                  ),

                const Divider(color: Colors.white70, thickness: 2),
                const SizedBox(height: 10),
                // Commanders header
                const Text(
                  "Commanders",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                // List of commanders
                displayPlayer.commanders.isEmpty
                    ? const Center(
                        child: Text(
                          "No commanders added",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : Column(
                        children: displayPlayer.commanders.map((commander) {
                          return ListTile(
                            leading: Image.network(
                              commander.imageUrl,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image, size: 50, color: Colors.white);
                              },
                            ),
                            title: Text(commander.name,
                                style: const TextStyle(fontSize: 18, color: Colors.white)),
                            onTap: () => _showCommanderImage(commander),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 20),

                // Add commander button
                Center(
                  child: ElevatedButton(
                    onPressed: _addCommander,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text("Add a Commander", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Floating back button at bottom left
          Positioned(
            bottom: 24,
            left: 24,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
