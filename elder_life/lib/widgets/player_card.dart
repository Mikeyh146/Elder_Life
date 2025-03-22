import 'package:flutter/material.dart';
import '../models/player.dart';
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
  });

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  bool isFront = true; // true: showing front; false: showing back

  void _flipCard() {
    setState(() {
      isFront = !isFront;
    });
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    // Fade out if player is KO.
    final bool koStatus = widget.lifeTotal <= 0;

    return AnimatedOpacity(
      opacity: koStatus ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: AspectRatio(
          aspectRatio: 1, // Keep card square.
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.grey[900],
            child: Stack(
              children: [
                // Content container: both front and back fill the available space.
                Container(
                  padding: const EdgeInsets.only(bottom: 48.0), // space for the flip button
                  child: isFront ? _buildFront() : _buildBack(),
                ),
                // Flip button at bottom center.
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.flip, color: Colors.white, size: 30),
                      onPressed: _flipCard,
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

  /// Build the front side: life total, status icons, plus/minus buttons.
  Widget _buildFront() {
    final bool koStatus = widget.lifeTotal <= 0;

    return Container(
      // Fill the available space.
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Status icons row at the top.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.player.isMonarch)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.emoji_events, size: 30, color: Colors.yellow),
                ),
              if (widget.player.hasInitiative)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.flash_on, size: 30, color: Colors.lightBlue),
                ),
              if (widget.player.isAscended)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(Icons.upgrade, size: 30, color: Colors.purple),
                ),
            ],
          ),
          // Spacer to push life total to center.
          const Spacer(),
          // Life total row.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus button.
              GestureDetector(
                onTap: () => widget.onLifeChange(-1),
                onLongPress: () => widget.onLifeChange(-10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(Icons.remove, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              // Life total display.
              Text(
                "${widget.lifeTotal}",
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 16),
              // Plus button.
              GestureDetector(
                onTap: () => widget.onLifeChange(1),
                onLongPress: () => widget.onLifeChange(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
          const Spacer(),
          // If player is KO, optionally display "Rejoin" button.
          if (koStatus)
            ElevatedButton(
              onPressed: widget.onRejoin,
              child: const Text("Rejoin"),
            ),
        ],
      ),
    );
  }

 Widget _buildBack() {
  // Build your grid cells.
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

  // Ensure we have exactly 12 cells.
  while (cells.length < 12) {
    cells.add(Container());
  }

  // Wrap the GridView in a Container with a fixed height.
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 210, // Adjust this fixed height as needed
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 4, // 4 columns x 3 rows = 12 cells
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: cells,
      ),
    ),
  );
}



  /// Build a toggle square widget.
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
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a counter square with plus and minus buttons.
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

  /// Build an action square.
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

  /// New widget for Commander Damage square.
  Widget _buildCommanderDamageSquare() {
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
              Text("${widget.player.commanderDamage}", style: const TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens a dialog to adjust Commander Damage.
  /// The dialog now lists available commanders from the activeCommanders list.
  void _onCommanderDamagePressed() {
    List<Commander> availableCommanders = widget.activeCommanders.isNotEmpty
        ? widget.activeCommanders
        : widget.player.commanders;

    showDialog(
      context: context,
      builder: (context) {
        int localCommandDamage = widget.player.commanderDamage;
        Commander? selectedCommander;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Commander Damage"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // List available commanders for selection.
                  Container(
                    height: 150,
                    child: availableCommanders.isEmpty
                        ? const Text("No available commanders")
                        : ListView.builder(
                            itemCount: availableCommanders.length,
                            itemBuilder: (context, index) {
                              final cmdr = availableCommanders[index];
                              return ListTile(
                                leading: Image.network(
                                  cmdr.imageUrl,
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image, size: 50);
                                  },
                                ),
                                title: Text(cmdr.name),
                                selected: selectedCommander == cmdr,
                                onTap: () {
                                  setStateDialog(() {
                                    selectedCommander = cmdr;
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  Text("Commander Damage: $localCommandDamage"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setStateDialog(() {
                            if (localCommandDamage > 0) localCommandDamage--;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setStateDialog(() {
                            localCommandDamage++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedCommander == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select a commander.")),
                      );
                      return;
                    }
                    int delta = localCommandDamage - widget.player.commanderDamage;
                    // Optionally subtract this delta from the life total.
                    widget.onLifeChange(-delta);
                    setState(() {
                      widget.player.commanderDamage = localCommandDamage;
                    });
                    Navigator.pop(context);
                    // Trigger defeat if commander damage reaches 21.
                    if (widget.player.commanderDamage >= 21) {
                      widget.onKO();
                    }
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
