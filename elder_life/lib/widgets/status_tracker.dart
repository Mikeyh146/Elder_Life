import 'package:flutter/material.dart';
import 'package:elder_life/models/player.dart';

class StatusTracker extends StatelessWidget {
  final Player player;
  final Function(String, int) onStatusChange;

  const StatusTracker({super.key, required this.player, required this.onStatusChange});

  void increment(String type) => onStatusChange(type, 1);
  void decrement(String type) => onStatusChange(type, -1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatusCounter(
          label: "Poison",
          value: player.poisonCounters,
          color: Colors.green,
          onIncrement: () => increment("poison"),
          onDecrement: () => decrement("poison"),
        ),
        StatusCounter(
          label: "Energy",
          value: player.energyCounters,
          color: Colors.blue,
          onIncrement: () => increment("energy"),
          onDecrement: () => decrement("energy"),
        ),
        StatusCounter(
          label: "Monarch",
          value: player.isMonarch ? 1 : 0,
          color: Colors.yellow,
          onIncrement: () => increment("monarch"),
          onDecrement: () => decrement("monarch"),
        ),
      ],
    );
  }
}

class StatusCounter extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const StatusCounter({super.key, required this.label, required this.value, required this.color, required this.onIncrement, required this.onDecrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 16)),
        IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: onDecrement),
        Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 16)),
        IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: onIncrement),
      ],
    );
  }
}
