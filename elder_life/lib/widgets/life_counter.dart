import 'package:flutter/material.dart';
import 'package:elder_life/models/player.dart';

class LifeCounter extends StatefulWidget {
  final Player player;
  final void Function(Player) onDefeated; // Ensure this expects a Player

  const LifeCounter({
    super.key,
    required this.player,
    required this.onDefeated,
  });

  @override
  _LifeCounterState createState() => _LifeCounterState();
}

class _LifeCounterState extends State<LifeCounter> {
  void _adjustLife(int amount) {
    setState(() {
      widget.player.lifeTotal += amount;

      // If life is 0 or below, trigger defeat confirmation
      if (widget.player.lifeTotal <= 0) {
        widget.onDefeated(widget.player);
      }
    });
  }

  void _adjustPoison(int amount) {
    setState(() {
      widget.player.poisonCounters = (widget.player.poisonCounters + amount).clamp(0, 10);
    });
  }

  void _adjustEnergy(int amount) {
    setState(() {
      widget.player.energyCounters = (widget.player.energyCounters + amount).clamp(0, 99);
    });
  }

  void _toggleMonarch() {
    setState(() {
      widget.player.isMonarch = !widget.player.isMonarch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Commander Image Background
          Stack(
            alignment: Alignment.center,
            children: [
              widget.player.commanderImage != null
                  ? Image.network(widget.player.commanderImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 100)
                  : Container(height: 100, color: Colors.black12),
              Text(
                widget.player.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ],
          ),

          // Life Total Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.red),
                onPressed: () => _adjustLife(-1),
              ),
              Text(
                '${widget.player.lifeTotal}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () => _adjustLife(1),
              ),
            ],
          ),

          // Status Controls (Poison, Energy, Monarch)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statusButton("Poison: ${widget.player.poisonCounters}", Colors.purple, () => _adjustPoison(1)),
              _statusButton("Energy: ${widget.player.energyCounters}", Colors.blue, () => _adjustEnergy(1)),
              _statusButton(widget.player.isMonarch ? "Monarch 👑" : "Not Monarch", Colors.orange, _toggleMonarch),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}
