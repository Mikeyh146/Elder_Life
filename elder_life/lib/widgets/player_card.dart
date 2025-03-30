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
    final bool koStatus = widget.lifeTotal <= 0;

    return AnimatedOpacity(
      opacity: koStatus ? 0.4 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: AspectRatio(
          aspectRatio: 350 / 320, // similar to your HTML dimensions
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFF1E1E1E), // matches HTML card-face bg
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

  /// Builds the front of the card.
  Widget _buildFront() {
  final bool koStatus = widget.lifeTotal <= 0;
  // Use the first commander's image if available.
  String? commanderImage = widget.player.commanders.isNotEmpty
      ? widget.player.commanders.first.imageUrl
      : null;
  
  return Stack(
    fit: StackFit.expand,
    children: [
      // Background: commander art if available.
      if (commanderImage != null)
        Image.network(
          commanderImage,
          fit: BoxFit.cover,
        ),
      // Dark overlay for readability.
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
            // Player name (styled like an input).
            TextField(
              controller: TextEditingController(text: widget.player.name),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.white),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const Spacer(),
            // Life total row centered.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLifeButton(
                  icon: Icons.remove,
                  btnColor: const Color(0xFF333333),
                  onTap: () => widget.onLifeChange(-1),
                  onLongPress: () => widget.onLifeChange(-10),
                ),
                const SizedBox(width: 16),
                Text(
                  "${widget.lifeTotal}",
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                _buildLifeButton(
                  icon: Icons.add,
                  btnColor: const Color(0xFF333333),
                  onTap: () => widget.onLifeChange(1),
                  onLongPress: () => widget.onLifeChange(10),
                ),
              ],
            ),
            const Spacer(),
            if (koStatus)
              ElevatedButton(
                onPressed: widget.onRejoin,
                child: const Text("Rejoin"),
              ),
          ],
        ),
      ),
    ],
  );
}


  /// Builds a life change button with a similar style to HTML.
  Widget _buildLifeButton({
    required IconData icon,
    required Color btnColor,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: btnColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  /// Builds the back of the card.
  Widget _buildBack() {
    // Build grid cells for toggles, counters, and actions.
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

    // Fill remaining cells to reach a 6x3 grid.
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
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

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
                  SizedBox(
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
                                    return const Icon(Icons.image, size: 50, color: Colors.white);
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
                    widget.onLifeChange(-delta);
                    setState(() {
                      widget.player.commanderDamage = localCommandDamage;
                    });
                    Navigator.pop(context);
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
