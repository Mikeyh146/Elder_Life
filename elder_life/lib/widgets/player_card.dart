import 'package:flutter/material.dart';
import '../models/player.dart';
import 'dart:async';
import '../models/commander.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int lifeTotal;
  // Life change callbacks
  final Function(int delta) onLifeChange;
  
  // K.O. & Rejoin callbacks
  final VoidCallback onKO;
  final VoidCallback onRejoin;
  // Counter callbacks
  final Function(int delta) onPoisonChange;
  final Function(int delta) onRadChange;
  final Function(int delta) onEnergyChange;
  final Function(int delta) onExpChange;
  // Toggle callbacks
  final Function(String) onDayNightCycle;
  final Function(bool) onMonarchToggle;
  final Function(bool) onInitiativeToggle;
  final Function(bool) onAscendToggle;
  // Flip callback
  final VoidCallback onFlip;
  // List of active commanders available in the game.
  final List<Commander> activeCommanders;
  //New: Timer value (in seconds) for this player.
  final int timerValue;

  const PlayerCard({
    super.key,
    required this.player,
    required this.lifeTotal,
    required this.onLifeChange,
    required this.onKO,
    required this.onRejoin,
    required this.onPoisonChange,
    required this.onRadChange,
    required this.onEnergyChange,
    required this.onExpChange,
    required this.onDayNightCycle,
    required this.onMonarchToggle,
    required this.onInitiativeToggle,
    required this.onAscendToggle,
    required this.onFlip,
    required this.activeCommanders,
    required this.timerValue,
  });

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  bool isFront = true; // true: showing front; false: showing back
 // New: Map to track damage by each commander (by their ID).
   int _deltaLife = 0;
   double _deltaOpacity = 0.0;
   Timer? _deltaTimer;

  final Map<String, int> _commanderDamageMap = {};
  bool _isDefeatDialogShown = false;

  void _flipCard() {
   
    setState(() {
      isFront = !isFront;
    });
    widget.onFlip();
  }
void _updateDeltaLife(int delta) {
  setState(() {
    _deltaLife += delta;
    _deltaOpacity = 1.0;
  });

  _deltaTimer?.cancel();
  _deltaTimer = Timer(const Duration(milliseconds: 1200), () {
    setState(() {
      _deltaOpacity = 0.0;
      _deltaLife = 0;  // Reset the ghost count after it fades away
    });
  });
}
  // Helper method to format seconds as MM:SS.
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

 // Add this new helper function to build the life buttons
Widget _buildLifeButton({
  required int change,
  required bool isSubtract, // Whether it's left (subtract) or right (add)
}) {
  return GestureDetector(
    onTap: () {
      widget.onLifeChange(change);
      _updateDeltaLife(change);
    },
    onLongPressStart: (_) {
      // Start long press by setting the delta to 10.
      _updateDeltaLife(isSubtract ? -10 : 10);
      // Update the life total right away on long press start
      widget.onLifeChange(isSubtract ? -10 : 10);
      // Start the timer for continuous long press effect.
      _startContinuousLongPress(isSubtract);
    },
    onLongPressEnd: (_) {
      // Stop the long press timer.
      _stopContinuousLongPress();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: isSubtract ? Colors.red : Colors.green, // Red for subtract, Green for add
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isSubtract ? Icons.remove : Icons.add,
        color: Colors.white,
        size: 30,
      ),
    ),
  );
}

// Timer for continuous life change
Timer? _longPressTimer;

void _startContinuousLongPress(bool isSubtract) {
  // Start a repeating timer that adds/subtracts life every 200ms
  _longPressTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
    widget.onLifeChange(isSubtract ? -10 : 10);  // Update the life total continuously
    _updateDeltaLife(isSubtract ? -10 : 10);  // Update the ghost count
  });
}

void _stopContinuousLongPress() {
  // Stop the repeating timer when the long press ends
  _longPressTimer?.cancel();
  _longPressTimer = null;
}




  @override
  Widget build(BuildContext context) {
    final bool isKO = widget.lifeTotal <= 0;

    return AnimatedOpacity(
      opacity: isKO ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: AspectRatio(
          aspectRatio: 350 / 320,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFF1E1E1E),
            child: Column(
              children: [
                // Expanded area for front/back content.
                Expanded(
                  child: isFront ? _buildFront() : _buildBack(),
                ),
                // Flip button row.
                Container(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: Text(
                      "↻ Flip",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //builds the front of the card
 Widget _buildFront() {
  return Stack(
    fit: StackFit.expand,
    children: [
      // Solid dark background instead of commander image.
      Container(color: Colors.grey[900]),

      // Optional dark overlay for consistent contrast.
      Container(color: Colors.black.withOpacity(0.5)),

      // Main content.
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status icons row.
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

            // Player name.
            Text(
              widget.player.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const Spacer(),

            // Life total row with buttons.
            Stack(
              alignment: Alignment.center,
              children: [
                // Life total text
                Text(
                  '${widget.lifeTotal}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Row for the + and - buttons horizontally (keep them centered)
                Row(
                  children: [
                    // Left side to subtract life, positioned towards the left side
                    Expanded(
                      flex: 1,  // Controls the proportion of space for the left side
                      child: Align(
                        alignment: Alignment.centerRight,  // Position the button towards the right of its space
                        child: _buildLifeButton(change: -1, isSubtract: true),
                      ),
                    ),

                    // Middle space (you can adjust this space as needed)
                    Expanded(
                      flex: 1,
                      child: Container(),  // Empty space to push buttons towards the left and right
                    ),

                    // Right side to add life, positioned towards the right side
                    Expanded(
                      flex: 1,  // Controls the proportion of space for the right side
                      child: Align(
                        alignment: Alignment.centerLeft,  // Position the button towards the left of its space
                        child: _buildLifeButton(change: 1, isSubtract: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Button to Rejoin
            if (widget.lifeTotal <= 0)
              ElevatedButton(
                onPressed: widget.onRejoin,
                child: const Text("Rejoin"),
              ),
          ],
        ),
      ),

      // Ghost delta life number, positioned at the bottom of the card
      if (_deltaLife != 0)
        Positioned(
          bottom: 16,  // Positioned towards the bottom of the card
          left: 0,
          right: 0,  // Ensure it spans the full width of the card
          child: AnimatedOpacity(
            opacity: _deltaOpacity,
            duration: const Duration(milliseconds: 300),
            child: Text(
              _deltaLife > 0 ? '+$_deltaLife' : '$_deltaLife',
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(
                fontSize: 28,
                color: _deltaLife > 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
          ),
        ),
    ],
  );
}



  /// Builds the back side of the card.
  Widget _buildBack() {
    List<Widget> cells = [
      _buildToggleSquare(
        label: "Monarch",
        isActive: widget.player.isMonarch,
        onTap: () => widget.onMonarchToggle(!widget.player.isMonarch),
      ),
      _buildToggleSquare(
        label: "Initiative",
        isActive: widget.player.hasInitiative,
        onTap: () => widget.onInitiativeToggle(!widget.player.hasInitiative),
      ),
      _buildToggleSquare(
        label: "Ascend",
        isActive: widget.player.isAscended,
        onTap: () => widget.onAscendToggle(!widget.player.isAscended),
      ),
      _buildToggleSquare(
        label: "Day/Night",
        isActive: widget.player.dayNight != "off",
        info: widget.player.dayNight,
        onTap: () {
          if (widget.player.dayNight == "off") {
            widget.onDayNightCycle("day");
          } else if (widget.player.dayNight == "day") {
            widget.onDayNightCycle("night");
          } else {
            widget.onDayNightCycle("off");
          }
        },
      ),
      _buildCounterSquare(
        label: "Energy",
        value: widget.player.energy,
        onChange: widget.onEnergyChange,
      ),
      _buildCounterSquare(
        label: "EXP",
        value: widget.player.exp,
        onChange: widget.onExpChange,
      ),
      _buildCounterSquare(
        label: "Poison",
        value: widget.player.poison,
        onChange: widget.onPoisonChange,
      ),
      _buildCounterSquare(
        label: "Rad",
        value: widget.player.rad,
        onChange: widget.onRadChange,
      ),
      _buildActionSquare(
        label: "K.O.",
        onTap: widget.onKO,
      ),
      _buildCommanderDamageSquare(),
    ];

    // Fill remaining cells to complete a 6x3 grid.
    while (cells.length < 18) {
      cells.add(Container());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 8.0;
        final double availableWidth = constraints.maxWidth;
        final double availableHeight = constraints.maxHeight;
        final double cellWidth = (availableWidth - (6 - 1) * spacing) / 6;
        final double cellHeight = (availableHeight - (3 - 1) * spacing) / 3;
        final double ratio = cellWidth / cellHeight;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 6,
            childAspectRatio: ratio,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            children: cells,
          ),
        );
      },
    );
  }

  Widget _buildToggleSquare({
    required String label,
    required bool isActive,
    String? info,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.green[700] : Colors.grey[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info ?? (isActive ? "On" : "Off"),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterSquare({
    required String label,
    required int value,
    required Function(int delta) onChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("$value", style: const TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.white,
                onPressed: () => onChange(-1),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.white,
                onPressed: () => onChange(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionSquare({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
/// Builds the Commander Damage square (button) shown on the back of the card.
/// Builds the Commander Damage square (button) shown on the back of the card.
Widget _buildCommanderDamageSquare() {
  // Sum up the damage from all opponent commanders.
  int totalDamage = 0;
  for (var cmdr in widget.activeCommanders) {
    totalDamage += _commanderDamageMap[cmdr.id] ?? 0;
  }
  return GestureDetector(
    onTap: _onCommanderDamagePressed,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.pink[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("C-DAM", style: TextStyle(fontSize: 14, color: Colors.white)),
            const SizedBox(height: 4),
            Text("$totalDamage", style: const TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}

/// Opens a dialog showing opponent commanders with their images and -/+ buttons.
void _onCommanderDamagePressed() {
  // Use the opponent commanders list provided in activeCommanders.
  List<Commander> opponents = widget.activeCommanders;
  if (opponents.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No opponent commanders available.")),
    );
    return;
  }
  // Create a local copy of damage values.
  Map<String, int> localDamage = {};
  for (var cmdr in opponents) {
    localDamage[cmdr.id] = _commanderDamageMap[cmdr.id] ?? 0;
  }
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Adjust Opponent Commander Damage"),
            content: SizedBox(
              width: 220, // Fixed width for a smaller dialog
              height: 220, // Fixed height for a smaller dialog
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                shrinkWrap: true,
                children: opponents.map((cmdr) {
                  int damage = localDamage[cmdr.id] ?? 0;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display the commander's card image.
                      Image.network(
                        cmdr.imageUrl,
                        height: 60,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image, size: 40, color: Colors.white);
                        },
                      ),
                      const SizedBox(height: 2),
                      Text("Damage: $damage",
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            iconSize: 20,
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              setStateDialog(() {
                                if (damage > 0) localDamage[cmdr.id] = damage - 1;
                              });
                            },
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            iconSize: 20,
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              setStateDialog(() {
                                localDamage[cmdr.id] = damage + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  // Sum up the total damage from opponent commanders.
                  int totalDamage = localDamage.values.fold(0, (sum, val) => sum + val);
                  // Calculate the difference from the player's current stored commander damage.
                  int damageDelta = totalDamage - widget.player.commanderDamage;
                  // Subtract the additional damage from the player's life total.
                  widget.onLifeChange(-damageDelta);
                  // Update the player's stored commander damage.
                  widget.player.commanderDamage = totalDamage;
                  // Save the new damage values in the map and trigger KO if any damage is 21 or more.
                  for (var cmdr in opponents) {
                    _commanderDamageMap[cmdr.id] = localDamage[cmdr.id] ?? 0;
                    if ((_commanderDamageMap[cmdr.id] ?? 0) >= 21) {
                      widget.onKO();
                      break;
                    }
                  }
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}
}