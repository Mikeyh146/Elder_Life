import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/player_card.dart';

class GameScreen2 extends StatefulWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame;

  const GameScreen2({
    super.key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  });

  @override
  _GameScreen2State createState() => _GameScreen2State();
}

class _GameScreen2State extends State<GameScreen2> with SingleTickerProviderStateMixin {
  late Map<String, int> lifeTotals;
  late List<Player> activePlayers;
  late AnimationController _controller;
  late Animation<double> _animation;

  // Chess clock variables.
  late Map<String, int> playerTimers; // player.id -> remaining time in seconds
  late int turnTimeInSeconds; // turn duration in seconds
  int currentTurnIndex = 0;
  Timer? turnTimer;
  bool timerEnabled = false;

  @override
  void initState() {
    super.initState();
    activePlayers = List.from(widget.players);
    lifeTotals = { for (var p in activePlayers) p.id: widget.startingLife };

    // Default turn time: 60 seconds (1 minute)
    turnTimeInSeconds = 60;
    playerTimers = { for (var p in activePlayers) p.id: turnTimeInSeconds };

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start pre-game sequence.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGameSequence());
  }

  @override
  void dispose() {
    _controller.dispose();
    turnTimer?.cancel();
    super.dispose();
  }

  // Pre-game sequence: ready? timer? first turn.
  Future<void> _startGameSequence() async {
    // 1. Ready to start?
    bool ready = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Ready to Start?"),
            content: const Text("Are you ready to start the game?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
            ],
          ),
        ) ?? false;
    if (!ready) return;

    // 2. Ask if a turn timer is required.
    bool requireTimer = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Turn Timer"),
            content: const Text("Do you require a turn timer?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
            ],
          ),
        ) ?? false;
    timerEnabled = requireTimer;

    // 3. If timer is needed, prompt for time in minutes.
    if (timerEnabled) {
      String? timeInput = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          TextEditingController controller = TextEditingController();
          return AlertDialog(
            title: const Text("Set Turn Time"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter time in minutes"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text("OK")),
            ],
          );
        },
      );
      if (timeInput?.isNotEmpty ?? false) {
  int? minutes = int.tryParse(timeInput ?? ''); // Handle null by using an empty string fallback
  if (minutes != null && minutes > 0) {
    turnTimeInSeconds = minutes * 60;
    playerTimers = { for (var p in activePlayers) p.id: turnTimeInSeconds };
  }
}

    }

    // 4. Determine first turn: randomly choose a player.
    currentTurnIndex = math.Random().nextInt(activePlayers.length);
    String firstPlayerName = activePlayers[currentTurnIndex].name;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("First Turn"),
        content: Text("$firstPlayerName will go first."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );

    if (timerEnabled) {
      _startTurnTimer();
    }
  }

  // Format seconds as MM:SS.
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  void _startTurnTimer() {
    turnTimer?.cancel();
    turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      String activeId = activePlayers[currentTurnIndex].id;
      if (playerTimers[activeId]! > 0) {
        setState(() {
          playerTimers[activeId] = playerTimers[activeId]! - 1;
        });
      } else {
        _passTurn();
      }
    });
  }

  void _passTurn() {
    turnTimer?.cancel();
    setState(() {
      currentTurnIndex = (currentTurnIndex + 1) % activePlayers.length;
    });
    if (timerEnabled) {
      _startTurnTimer();
    }
  }

  Future<void> _confirmEndGame() async {
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

  Future<void> _abandonGame() async {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
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

  Future<void> _randomPlayer() async {
    if (activePlayers.isEmpty) return;
    Player randomPlayer = activePlayers[math.Random().nextInt(activePlayers.length)];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Random Player"),
        content: Text("Randomly selected: ${randomPlayer.name}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  Future<void> _randomOpponent() async {
    // Prompt user to select themselves so they are excluded.
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
                TextButton(onPressed: () => Navigator.pop(context, selected), child: const Text("OK")),
              ],
            );
          },
        );
      },
    );
    if (currentUser == null || activePlayers.isEmpty) return;

List<Player> opponents = activePlayers
    .where((p) => p.id != currentUser!.id)
    .toList();

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
        child: const Text("OK"),
      ),
    ],
  ),
);


  }

  // Helper: Show defeat dialog.
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
      // Add defeat logic here if needed.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build left and right player cards with rotations.
    Widget leftCard = Transform.rotate(
      angle: math.pi / 2,
      child: PlayerCard(
        player: activePlayers[0],
        lifeTotal: lifeTotals[activePlayers[0].id] ?? widget.startingLife,
        timerValue: playerTimers[activePlayers[0].id] ?? turnTimeInSeconds,
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
            for (var p in activePlayers) {
              p.isMonarch = false;
            }
            activePlayers[0].isMonarch = isOn;
          });
        },
        onInitiativeToggle: (isOn) {
          setState(() {
            for (var p in activePlayers) {
              p.hasInitiative = false;
            }
            activePlayers[0].hasInitiative = isOn;
          });
        },
        onAscendToggle: (isOn) {
          setState(() {
            activePlayers[0].isAscended = isOn;
          });
        },
        onFlip: () {},
        activeCommanders: [],
      ),
    );

    Widget rightCard = Transform.rotate(
      angle: -math.pi / 2,
      child: PlayerCard(
        player: activePlayers[1],
        lifeTotal: lifeTotals[activePlayers[1].id] ?? widget.startingLife,
        timerValue: playerTimers[activePlayers[1].id] ?? turnTimeInSeconds,
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
            for (var p in activePlayers) {
              p.isMonarch = false;
            }
            activePlayers[1].isMonarch = isOn;
          });
        },
        onInitiativeToggle: (isOn) {
          setState(() {
            for (var p in activePlayers) {
              p.hasInitiative = false;
            }
            activePlayers[1].hasInitiative = isOn;
          });
        },
        onAscendToggle: (isOn) {
          setState(() {
            activePlayers[1].isAscended = isOn;
          });
        },
        onFlip: () {},
        activeCommanders: [],
      ),
    );

    Widget middleColumn = Column(
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
        IconButton(
          icon: const Icon(Icons.skip_next, size: 40, color: Colors.white),
          onPressed: _passTurn,
        ),
        IconButton(
          icon: const Icon(Icons.settings, size: 40, color: Colors.deepOrange),
          onPressed: _openInGameSettings,
        ),
      ],
    );

    Widget gameContainer = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent, width: 1),
      ),
      child: Container(
        color: Colors.black,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: leftCard),
              middleColumn,
              Expanded(child: rightCard),
            ],
          ),
        ),
      ),
    );

    Widget timerOverlay = timerEnabled
        ? Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Turn: ${activePlayers[currentTurnIndex].name} | Time left: ${_formatTime(playerTimers[activePlayers[currentTurnIndex].id] ?? turnTimeInSeconds)}",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            gameContainer,
            timerOverlay,
          ],
        ),
      ),
    );
  }
}
