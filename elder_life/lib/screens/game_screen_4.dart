import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/player_card.dart';

class GameScreen4 extends StatefulWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame;

  const GameScreen4({
    super.key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  });

  @override
  _GameScreen4State createState() => _GameScreen4State();
}

class _GameScreen4State extends State<GameScreen4> with SingleTickerProviderStateMixin {
  late Map<String, int> lifeTotals;
  late List<Player> activePlayers;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    activePlayers = List.from(widget.players);
    lifeTotals = { for (var p in activePlayers) p.id: widget.startingLife };

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start the pre-game sequence after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGameSequence());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Pre-game sequence: ready? seating arrangement? first turn.
  Future<void> _startGameSequence() async {
    // 1. Ready to start?
    bool ready = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Ready to Start?"),
            content: const Text("Are you ready to start the game?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes")),
            ],
          ),
        ) ??
        false;
    if (!ready) return;

    // 2. Seating Arrangement: Ask the user to set the seating order.
    await _getSeatingArrangement();

    // 3. Determine first turn: randomly choose a player.
    int firstIndex = math.Random().nextInt(activePlayers.length);
    String firstPlayerName = activePlayers[firstIndex].name;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("First Turn"),
        content: Text("$firstPlayerName will go first."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  // Helper method to let the user reorder the seating order via a grid dialog.
  Future<void> _getSeatingArrangement() async {
    int seatCount = activePlayers.length;
    // Create a list to hold the seating assignments.
    List<Player?> seating = List.filled(seatCount, null);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Set Seating Arrangement"),
              content: SizedBox(
                width: 300,
                height: 300,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: List.generate(seatCount, (index) {
                    return GestureDetector(
                      onTap: () async {
                        // Show a dialog to pick one player.
                        Player? selected = await _selectPlayerForSeat(index);
                        if (selected != null) {
                          setStateDialog(() {
                            seating[index] = selected;
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            seating[index]?.name ?? "Seat ${index + 1}",
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (seating.contains(null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please assign all seats.")),
                      );
                    } else {
                      setState(() {
                        activePlayers = seating.cast<Player>();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper for seat selection dialog.
  Future<Player?> _selectPlayerForSeat(int seatIndex) async {
    return showDialog<Player>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select player for Seat ${seatIndex + 1}"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: activePlayers.map((player) {
                return ListTile(
                  title: Text(player.name),
                  onTap: () => Navigator.pop(context, player),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDefeatDialog(Player defeatedPlayer, String reason) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${defeatedPlayer.name} is defeated?"),
        content: Text("Reason: $reason. Confirm defeat?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (confirmed == true) {
      // Additional defeat logic here if needed.
    }
  }

  Future<void> _openInGameSettings() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              child: const Text("Close")),
        ],
      ),
    );
  }

  Future<void> _confirmEndGame() async {
    bool? isOver = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Game"),
        content: const Text("Is the game over?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes")),
        ],
      ),
    );
    if (isOver == true) {
      Navigator.pushReplacementNamed(context, '/end-game', arguments: activePlayers);
    }
  }

  Future<void> _abandonGame() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Abandon Game"),
        content: const Text("Are you sure you want to abandon the game? Stats will not be tracked."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Abandon")),
        ],
      ),
    );
    if (confirmed == true) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _flipCoin() {
    String result = math.Random().nextBool() ? "Heads" : "Tails";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Coin Flip"),
        content: Text("Result: $result"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _randomPlayer() async {
    if (activePlayers.isEmpty) return;
    Player randomPlayer = activePlayers[math.Random().nextInt(activePlayers.length)];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Random Player"),
        content: Text("Randomly selected: ${randomPlayer.name}"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _randomOpponent() async {
    // Ask the user to select themselves so they are not chosen.
    Player? currentUser = await showDialog<Player>(
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
                    child: const Text("OK")),
              ],
            );
          },
        );
      },
    );
    List<Player> opponents = activePlayers.where((p) => p.id != currentUser?.id).toList();

    if (opponents.isEmpty) return;
    Player randomOpponent = opponents[math.Random().nextInt(opponents.length)];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Random Opponent"),
        content: Text("Your opponent is: ${randomOpponent.name}"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Top row: Two player cards (rotated 180°).
    Widget topRow = Row(
      children: [
        Expanded(
          child: Transform.rotate(
            angle: math.pi,
            child: PlayerCard(
              player: activePlayers[0],
              lifeTotal: lifeTotals[activePlayers[0].id] ?? widget.startingLife,
              timerValue: 0, // Removed timer display
              onLifeChange: (delta) {
                setState(() {
                  lifeTotals[activePlayers[0].id] = (lifeTotals[activePlayers[0].id] ?? widget.startingLife) + delta;
                });
                if ((lifeTotals[activePlayers[0].id] ?? widget.startingLife) <= 0) {
                  _onDefeatDialog(activePlayers[0], "Life reached 0");
                }
              },
              onKO: () {},
              onRejoin: () {
                setState(() {
                  lifeTotals[activePlayers[0].id] = widget.startingLife;
                });
              },
              onPoisonChange: (delta) {
                setState(() {
                  activePlayers[0].poison += delta;
                  if (activePlayers[0].poison >= 10) {
                    _onDefeatDialog(activePlayers[0], "10 Poison");
                  }
                });
              },
              onRadChange: (delta) {
                setState(() {
                  activePlayers[0].rad += delta;
                });
              },
              onEnergyChange: (delta) {
                setState(() {
                  activePlayers[0].energy += delta;
                });
              },
              onExpChange: (delta) {
                setState(() {
                  activePlayers[0].exp += delta;
                });
              },
              onDayNightCycle: (value) {
                setState(() {
                  activePlayers[0].dayNight = value;
                });
              },
              onMonarchToggle: (isOn) {
                setState(() {
                  for (var p in activePlayers) { p.isMonarch = false; }
                  activePlayers[0].isMonarch = isOn;
                });
              },
              onInitiativeToggle: (isOn) {
                setState(() {
                  for (var p in activePlayers) { p.hasInitiative = false; }
                  activePlayers[0].hasInitiative = isOn;
                });
              },
              onAscendToggle: (isOn) {
                setState(() {
                  activePlayers[0].isAscended = isOn;
                });
              },
              onFlip: () {},
             activeCommanders: activePlayers
    .where((p) => p.id != activePlayers[0].id)
    .expand((p) => p.commanders)
    .toList(),

            ),
          ),
        ),
        Expanded(
          child: Transform.rotate(
            angle: math.pi,
            child: PlayerCard(
              player: activePlayers[1],
              lifeTotal: lifeTotals[activePlayers[1].id] ?? widget.startingLife,
              timerValue: 0, // Removed timer display
              onLifeChange: (delta) {
                setState(() {
                  lifeTotals[activePlayers[1].id] = (lifeTotals[activePlayers[1].id] ?? widget.startingLife) + delta;
                });
                if ((lifeTotals[activePlayers[1].id] ?? widget.startingLife) <= 0) {
                  _onDefeatDialog(activePlayers[1], "Life reached 0");
                }
              },
              onKO: () {},
              onRejoin: () {
                setState(() {
                  lifeTotals[activePlayers[1].id] = widget.startingLife;
                });
              },
              onPoisonChange: (delta) {
                setState(() {
                  activePlayers[1].poison += delta;
                  if (activePlayers[1].poison >= 10) {
                    _onDefeatDialog(activePlayers[1], "10 Poison");
                  }
                });
              },
              onRadChange: (delta) {
                setState(() {
                  activePlayers[1].rad += delta;
                });
              },
              onEnergyChange: (delta) {
                setState(() {
                  activePlayers[1].energy += delta;
                });
              },
              onExpChange: (delta) {
                setState(() {
                  activePlayers[1].exp += delta;
                });
              },
              onDayNightCycle: (value) {
                setState(() {
                  activePlayers[1].dayNight = value;
                });
              },
              onMonarchToggle: (isOn) {
                setState(() {
                  for (var p in activePlayers) { p.isMonarch = false; }
                  activePlayers[1].isMonarch = isOn;
                });
              },
              onInitiativeToggle: (isOn) {
                setState(() {
                  for (var p in activePlayers) { p.hasInitiative = false; }
                  activePlayers[1].hasInitiative = isOn;
                });
              },
              onAscendToggle: (isOn) {
                setState(() {
                  activePlayers[1].isAscended = isOn;
                });
              },
              onFlip: () {},
           activeCommanders: activePlayers
    .where((p) => p.id != activePlayers[0].id)
    .expand((p) => p.commanders)
    .toList(),

            ),
          ),
        ),
      ],
    );

    // Middle row: Three equally spaced sections: left timer placeholder, action icons, right timer placeholder.
    // (Since we are not showing live timers, these sections can display static/dummy text.)
    Widget middleRow = Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Timer",
              style: TextStyle(fontSize: 18, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.attach_money, size: 40, color: Colors.white),
                onPressed: _flipCoin,
              ),
              IconButton(
                icon: const Icon(Icons.casino, size: 40, color: Colors.white),
                onPressed: _rollDice,
              ),
              IconButton(
                icon: const Icon(Icons.person, size: 40, color: Colors.white),
                onPressed: _randomPlayer,
              ),
              IconButton(
                icon: const Icon(Icons.sports_mma, size: 40, color: Colors.white),
                onPressed: _randomOpponent,
              ),
              // Removed skip/next turn button (timer swapping) as requested.
              IconButton(
                icon: const Icon(Icons.settings, size: 40, color: Colors.deepOrange),
                onPressed: _openInGameSettings,
              ),
            ],
          ),
        ),
        Expanded(
          child: Transform.rotate(
            angle: math.pi,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Timer",
                style: TextStyle(fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );

    // Bottom row: Two player cards (normal orientation).
    Widget bottomRow = Row(
      children: [
        Expanded(
          child: PlayerCard(
            player: activePlayers[2],
            lifeTotal: lifeTotals[activePlayers[2].id] ?? widget.startingLife,
            timerValue: 0,
            onLifeChange: (delta) {
              setState(() {
                lifeTotals[activePlayers[2].id] = (lifeTotals[activePlayers[2].id] ?? widget.startingLife) + delta;
              });
              if ((lifeTotals[activePlayers[2].id] ?? widget.startingLife) <= 0) {
                _onDefeatDialog(activePlayers[2], "Life reached 0");
              }
            },
            onKO: () {},
            onRejoin: () {
              setState(() {
                lifeTotals[activePlayers[2].id] = widget.startingLife;
              });
            },
            onPoisonChange: (delta) {
              setState(() {
                activePlayers[2].poison += delta;
                if (activePlayers[2].poison >= 10) {
                  _onDefeatDialog(activePlayers[2], "10 Poison");
                }
              });
            },
            onRadChange: (delta) {
              setState(() {
                activePlayers[2].rad += delta;
              });
            },
            onEnergyChange: (delta) {
              setState(() {
                activePlayers[2].energy += delta;
              });
            },
            onExpChange: (delta) {
              setState(() {
                activePlayers[2].exp += delta;
              });
            },
            onDayNightCycle: (value) {
              setState(() {
                activePlayers[2].dayNight = value;
              });
            },
            onMonarchToggle: (isOn) {
              setState(() {
                for (var p in activePlayers) { p.isMonarch = false; }
                activePlayers[2].isMonarch = isOn;
              });
            },
            onInitiativeToggle: (isOn) {
              setState(() {
                for (var p in activePlayers) { p.hasInitiative = false; }
                activePlayers[2].hasInitiative = isOn;
              });
            },
            onAscendToggle: (isOn) {
              setState(() {
                activePlayers[2].isAscended = isOn;
              });
            },
            onFlip: () {},
            activeCommanders: activePlayers
    .where((p) => p.id != activePlayers[0].id)
    .expand((p) => p.commanders)
    .toList(),

          ),
        ),
        Expanded(
          child: PlayerCard(
            player: activePlayers[3],
            lifeTotal: lifeTotals[activePlayers[3].id] ?? widget.startingLife,
            timerValue: 0,
            onLifeChange: (delta) {
              setState(() {
                lifeTotals[activePlayers[3].id] = (lifeTotals[activePlayers[3].id] ?? widget.startingLife) + delta;
              });
              if ((lifeTotals[activePlayers[3].id] ?? widget.startingLife) <= 0) {
                _onDefeatDialog(activePlayers[3], "Life reached 0");
              }
            },
            onKO: () {},
            onRejoin: () {
              setState(() {
                lifeTotals[activePlayers[3].id] = widget.startingLife;
              });
            },
            onPoisonChange: (delta) {
              setState(() {
                activePlayers[3].poison += delta;
                if (activePlayers[3].poison >= 10) {
                  _onDefeatDialog(activePlayers[3], "10 Poison");
                }
              });
            },
            onRadChange: (delta) {
              setState(() {
                activePlayers[3].rad += delta;
              });
            },
            onEnergyChange: (delta) {
              setState(() {
                activePlayers[3].energy += delta;
              });
            },
            onExpChange: (delta) {
              setState(() {
                activePlayers[3].exp += delta;
              });
            },
            onDayNightCycle: (value) {
              setState(() {
                activePlayers[3].dayNight = value;
              });
            },
            onMonarchToggle: (isOn) {
              setState(() {
                for (var p in activePlayers) { p.isMonarch = false; }
                activePlayers[3].isMonarch = isOn;
              });
            },
            onInitiativeToggle: (isOn) {
              setState(() {
                for (var p in activePlayers) { p.hasInitiative = false; }
                activePlayers[3].hasInitiative = isOn;
              });
            },
            onAscendToggle: (isOn) {
              setState(() {
                activePlayers[3].isAscended = isOn;
              });
            },
            onFlip: () {},
            activeCommanders: activePlayers
    .where((p) => p.id != activePlayers[0].id)
    .expand((p) => p.commanders)
    .toList(),

          ),
        ),
      ],
    );

    // Game container with an invisible border.
    Widget gameContainer = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 1),
      ),
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(child: topRow),
            Container(padding: const EdgeInsets.symmetric(vertical: 8), child: middleRow),
            Expanded(child: bottomRow),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            gameContainer,
          ],
        ),
      ),
    );
  }
}
