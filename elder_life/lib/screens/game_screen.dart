import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/commander.dart';
import '../widgets/player_card.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final int startingLife;

  const GameScreen({
    super.key,
    required this.players,
    required this.startingLife,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late Map<String, int> lifeTotals;
  late List<Player> activePlayers;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    activePlayers = List.from(widget.players);
    lifeTotals = {for (var p in widget.players) p.id: widget.startingLife};

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute unique active commanders from all players.
    List<Commander> activeCommanders = [];
    for (var p in activePlayers) {
      activeCommanders.addAll(p.commanders);
    }
    var uniqueCommanders = {for (var c in activeCommanders) c.id: c};
    activeCommanders = uniqueCommanders.values.toList();

    return Scaffold(
      // Remove the AppBar so there's no back arrow or title.
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridWidth = constraints.maxWidth;
            final gridHeight = constraints.maxHeight;
            // For a 2x2 grid:
            final cellWidth = gridWidth / 2;
            final cellHeight = gridHeight / 2;
            final childAspectRatio = cellWidth / cellHeight;

            return Stack(
              children: [
                // Grid container that fills available space.
                Container(
                  width: gridWidth,
                  height: gridHeight,
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: activePlayers.length <= 2 ? 1 : 2,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: activePlayers.map((player) {
                      final int life = lifeTotals[player.id] ?? widget.startingLife;
                      return PlayerCard(
                        player: player,
                        lifeTotal: life,
                        onLifeChange: (delta) {
                          setState(() {
                            if (life <= 0 && delta > 0) {
                              lifeTotals[player.id] = delta;
                            } else {
                              lifeTotals[player.id] =
                                  (lifeTotals[player.id] ?? widget.startingLife) + delta;
                            }
                          });
                          if ((lifeTotals[player.id] ?? widget.startingLife) <= 0) {
                            _onDefeatDialog(player, "Life reached 0");
                          }
                        },
                        onKO: () => _onDefeatDialog(player, "KO Button"),
                        onRejoin: () {
                          setState(() {
                            lifeTotals[player.id] = widget.startingLife;
                          });
                        },
                        onPoisonChange: (delta) {
                          setState(() {
                            player.poison += delta;
                            if (player.poison >= 10) {
                              _onDefeatDialog(player, "10 Poison");
                            }
                          });
                        },
                        onRadChange: (delta) {
                          setState(() {
                            player.rad += delta;
                          });
                        },
                        onEnergyChange: (delta) {
                          setState(() {
                            player.energy += delta;
                          });
                        },
                        onExpChange: (delta) {
                          setState(() {
                            player.exp += delta;
                          });
                        },
                        onDayNightCycle: (value) {
                          setState(() {
                            player.dayNight = value;
                          });
                        },
                        onMonarchToggle: (isOn) {
                          setState(() {
                            if (isOn) {
                              for (var p in activePlayers) {
                                p.isMonarch = false;
                              }
                            }
                            player.isMonarch = isOn;
                          });
                        },
                        onInitiativeToggle: (isOn) {
                          setState(() {
                            if (isOn) {
                              for (var p in activePlayers) {
                                p.hasInitiative = false;
                              }
                            }
                            player.hasInitiative = isOn;
                          });
                        },
                        onAscendToggle: (isOn) {
                          setState(() {
                            player.isAscended = isOn;
                          });
                        },
                        onFlip: () {
                          // Additional flip handling if needed.
                        },
                        activeCommanders: activeCommanders,
                      );
                    }).toList(),
                  ),
                ),
                // Center the cog icon at the intersection of the 4 grid cells.
                Positioned(
                  left: gridWidth / 2 - 27, // adjust as needed
                  top: gridHeight / 2 - 15,  // adjust as needed
                  child: IconButton(
                    icon: const Icon(Icons.settings, size: 40, color: Colors.deepOrange),
                    onPressed: _openInGameSettings,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _onDefeatDialog(Player defeatedPlayer, String reason) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${defeatedPlayer.name} is defeated?"),
          content: Text("Reason: $reason. Confirm defeat?"),
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
    if (confirmed == true) {
      // Handle defeat logic here.
    }
  }

  Future<void> _openInGameSettings() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("In-Game Settings"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text("End Game"),
                  onPressed: () {
                    Navigator.pop(context); // Close settings
                    _confirmEndGame(); // Ask if game is over, then proceed.
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.monetization_on),
                  label: const Text("Flip a Coin"),
                  onPressed: _flipCoin,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.casino),
                  label: const Text("Roll a Dice"),
                  onPressed: _rollDice,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_search),
                  label: const Text("Random Opponent"),
                  onPressed: _randomOpponent,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Random Player"),
                  onPressed: _randomPlayer,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text("Abandon Game"),
                  onPressed: _abandonGame,
                ),
              ],
            ),
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

  void _flipCoin() {
    String result = Random().nextBool() ? "Heads" : "Tails";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Coin Flip"),
        content: Text("Result: $result"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _rollDice() {
    int result = Random().nextInt(6) + 1;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Dice Roll"),
        content: Text("Result: $result"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _randomOpponent() async {
    if (activePlayers.length < 3) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Not Enough Players"),
          content: const Text("Random opponent selection requires at least 3 players."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        ),
      );
      return;
    }
    Player? currentPlayer = await showDialog<Player>(
      context: context,
      builder: (context) {
        Player? selected;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Who are you?"),
              content: DropdownButton<Player>(
                isExpanded: true,
                value: selected,
                hint: const Text("Select your name"),
                onChanged: (Player? value) {
                  setStateDialog(() {
                    selected = value;
                  });
                },
                items: activePlayers.map((p) {
                  return DropdownMenuItem<Player>(
                    value: p,
                    child: Text(p.name),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
    if (currentPlayer == null) return;
    List<Player> opponents = activePlayers.where((p) => p.id != currentPlayer.id).toList();
    Player randomOpponent = opponents[Random().nextInt(opponents.length)];
    _controller.forward(from: 0.0);
    showDialog(
      context: context,
      builder: (_) => ScaleTransition(
        scale: _animation,
        child: AlertDialog(
          title: const Text("Random Opponent"),
          content: Text("Your opponent is: ${randomOpponent.name}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.reset();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  void _randomPlayer() {
    if (activePlayers.isEmpty) return;
    Player randomPlayer = activePlayers[Random().nextInt(activePlayers.length)];
    _controller.forward(from: 0.0);
    showDialog(
      context: context,
      builder: (_) => ScaleTransition(
        scale: _animation,
        child: AlertDialog(
          title: const Text("Random Player"),
          content: Text("Randomly selected: ${randomPlayer.name}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _controller.reset();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEndGame() async {
  bool? isOver = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("End Game"),
      content: const Text("Is the game over?"),
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
    ),
  );
  if (isOver == true) {
    Navigator.pushReplacementNamed(context, '/end-game', arguments: activePlayers);
  }
}


  void _abandonGame() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Abandon Game"),
        content: const Text("Are you sure you want to abandon the game? Stats will not be tracked."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Abandon"),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Simply navigate back to HomeScreen.
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
}
