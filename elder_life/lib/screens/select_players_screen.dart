import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/commander.dart';
import '../services/local_storage.dart';
import 'seating_arrangement_screen.dart'; // Navigates to seating arrangement

class SelectPlayersScreen extends StatefulWidget {
  final int numberOfPlayers;
  final String gameType; // "commander", "commander-brawl", or "standard"
  final int startingLife;

  const SelectPlayersScreen({
    Key? key,
    required this.numberOfPlayers,
    required this.gameType,
    required this.startingLife,
  }) : super(key: key);

  @override
  _SelectPlayersScreenState createState() => _SelectPlayersScreenState();
}

class _SelectPlayersScreenState extends State<SelectPlayersScreen> {
  List<Player> _allPlayers = [];
  final List<Player> _selectedPlayers = [];
  // For display purposes (stores the chosen commander's name for each player)
  final Map<String, String> _selectedCommanders = {};

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  void _loadPlayers() async {
    List<Player> players = await LocalStorage.getPlayers();
    setState(() {
      _allPlayers = players;
    });
  }

  /// Toggle selection of a player.
  void _toggleSelection(Player player) {
    setState(() {
      if (_selectedPlayers.contains(player)) {
        _selectedPlayers.remove(player);
        _selectedCommanders.remove(player.id);
      } else {
        if (_selectedPlayers.length < widget.numberOfPlayers) {
          _selectedPlayers.add(player);
        }
      }
    });
  }

  /// Ask if this is a Commander game.
  Future<bool?> _askIfCommanderGame() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Type"),
          content: const Text("Is this a Commander game?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  /// Prompt for starting life total.
  Future<int?> _selectLifeTotal() async {
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Starting Life Total"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("20"),
                onTap: () => Navigator.pop(context, 20),
              ),
              ListTile(
                title: const Text("25"),
                onTap: () => Navigator.pop(context, 25),
              ),
              ListTile(
                title: const Text("30"),
                onTap: () => Navigator.pop(context, 30),
              ),
              ListTile(
                title: const Text("40"),
                onTap: () => Navigator.pop(context, 40),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Prompt for a saved commander for a player.
  Future<Commander?> _selectSavedCommanderForPlayer(Player player) async {
    if (player.commanders.isEmpty) {
      return showDialog<Commander>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("No Commanders for ${player.name}"),
            content: const Text("Please add a commander in the Player Detail screen first."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
    return showDialog<Commander>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Commander for ${player.name}"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: player.commanders.length,
              itemBuilder: (context, index) {
                final commander = player.commanders[index];
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
                  title: Text(commander.name),
                  onTap: () => Navigator.pop(context, commander),
                );
              },
            ),
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
  }

  /// Proceed: ask commander game, prompt for commander selection if true, then prompt for life, and navigate.
  void _proceed() async {
    if (_selectedPlayers.length != widget.numberOfPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Select exactly ${widget.numberOfPlayers} players.")),
      );
      return;
    }

    bool? isCommanderGame = await _askIfCommanderGame();
    bool commanderGame = isCommanderGame == true;

    if (commanderGame) {
      for (var player in _selectedPlayers) {
        Commander? selected = await _selectSavedCommanderForPlayer(player);
        if (selected == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Player ${player.name} requires a commander.")),
          );
          return;
        } else {
          player.commanders.clear();
          player.commanders.add(selected);
          _selectedCommanders[player.id] = selected.name;
        }
      }
    }
    int? startingLife = await _selectLifeTotal();
    if (startingLife != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatingArrangementScreen(
            players: _selectedPlayers,
            startingLife: startingLife,
            isCommanderGame: commanderGame, // Pass flag along
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Players")),
      body: ListView.builder(
        itemCount: _allPlayers.length,
        itemBuilder: (context, index) {
          final player = _allPlayers[index];
          final isSelected = _selectedPlayers.contains(player);
          return ListTile(
            title: Text(player.name),
            subtitle: isSelected
                ? Text("Commander: ${_selectedCommanders[player.id] ?? 'None'}")
                : null,
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () => _toggleSelection(player),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _proceed,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
