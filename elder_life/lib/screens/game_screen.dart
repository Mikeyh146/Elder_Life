import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/commander.dart';
import '../widgets/player_card.dart';

class GameScreen extends StatefulWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame; // New flag

  const GameScreen({
    Key? key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  }) : super(key: key);

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
    lifeTotals = { for (var p in widget.players) p.id: widget.startingLife };

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Commander> _getActiveCommanders() {
    List<Commander> activeCommanders = [];
    for (var p in activePlayers) {
      activeCommanders.addAll(p.commanders);
    }
    var uniqueCommanders = { for (var c in activeCommanders) c.id: c };
    return uniqueCommanders.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Commander> activeCommanders = _getActiveCommanders();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridWidth = constraints.maxWidth;
            final gridHeight = constraints.maxHeight;

            int playerCount = activePlayers.length;
            int crossAxisCount;
            if (playerCount == 2) {
              crossAxisCount = 2;
            } else if (playerCount == 4) {
              crossAxisCount = 2;
            } else if (playerCount == 5 || playerCount == 6) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = math.min(playerCount, 3);
            }

            int rowCount = (playerCount / crossAxisCount).ceil();
            const double spacing = 16.0;
            final cellWidth = (gridWidth - (crossAxisCount + 1) * spacing) / crossAxisCount;
            final cellHeight = (gridHeight - (rowCount + 1) * spacing) / rowCount;
            final childAspectRatio = cellWidth / cellHeight;

            return Stack(
              children: [
                Container(
                  width: gridWidth,
                  height: gridHeight,
                  padding: const EdgeInsets.all(spacing),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    children: activePlayers.asMap().entries.map((entry) {
                      int index = entry.key;
                      Player player = entry.value;
                      final int life = lifeTotals[player.id] ?? widget.startingLife;
                      // Create the PlayerCard widget.
                      Widget card = PlayerCard(
                        player: player,
                        lifeTotal: life,
                        onLifeChange: (delta) {
                          setState(() {
                            if (life <= 0 && delta > 0) {
                              lifeTotals[player.id] = delta;
                            } else {
                              lifeTotals[player.id] = (lifeTotals[player.id] ?? widget.startingLife) + delta;
                            }
                          });
                          if ((lifeTotals[player.id] ?? widget.startingLife) <= 0) {
                            _onDefeatDialog(player, "Life reached 0");
                          }
                        },
                        onKO: () {
                          setState(() {
                            lifeTotals[player.id] = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${player.name} is knocked out.")),
                          );
                        },
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
                      // Flip the card if it's in the top row.
                      if (index < crossAxisCount) {
                        card = Transform.rotate(
                          angle: math.pi,
                          child: card,
                        );
                      }
                      // Return the card as is (no onTap navigation).
                      return card;
                    }).toList(),
                  ),
                ),
                Positioned(
                  left: gridWidth / 2 - 27,
                  top: gridHeight / 2 - 27,
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
      builder: (context) => AlertDialog(
        title: Text("${defeatedPlayer.name} is defeated?"),
        content: Text("Reason: $reason. Confirm defeat?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );
    if (confirmed == true) {
      // Handle defeat logic if needed.
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
                    Navigator.pop(context);
                    _confirmEndGame();
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
    String result = math.Random().nextBool() ? "Heads" : "Tails";
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
    int result = math.Random().nextInt(6) + 1;
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
                TextButton(onPressed: () => Navigator.pop(context, selected), child: const Text("OK")),
              ],
            );
          },
        );
      },
    );
    List<Player> opponents = activePlayers.where((p) => p.id != currentPlayer!.id).toList();
    Player randomOpponent = opponents[math.Random().nextInt(opponents.length)];
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
    Player randomPlayer = activePlayers[math.Random().nextInt(activePlayers.length)];
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Abandon")),
        ],
      ),
    );
    if (confirmed == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
}
