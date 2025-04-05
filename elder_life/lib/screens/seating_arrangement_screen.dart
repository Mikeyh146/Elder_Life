import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_screen.dart'; // Your game screen that accepts a seating order

class SeatingArrangementScreen extends StatefulWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame;

  const SeatingArrangementScreen({
    Key? key,
    required this.players,
    required this.startingLife,
    required this.isCommanderGame,
  }) : super(key: key);

  @override
  _SeatingArrangementScreenState createState() => _SeatingArrangementScreenState();
}

class _SeatingArrangementScreenState extends State<SeatingArrangementScreen> {
  // We'll allow up to 6 seats.
  // For players less than 6, only that many seats will be active.
  late Map<int, Player?> seatAssignments;

  @override
  void initState() {
    super.initState();
    // Pre-fill seats in order with null if not enough players.
    int count = widget.players.length;
    seatAssignments = Map.fromIterable(
      List.generate(6, (index) => index),
      key: (item) => item as int,
      value: (item) => item < count ? widget.players[item as int] : null,
    );
  }

  /// Opens a dialog to assign a player to the tapped seat.
  void _assignPlayerToSeat(int seatIndex) async {
    // Build a list of players not already assigned.
    List<Player> available = widget.players
        .where((p) => !seatAssignments.values.contains(p))
        .toList();
    // Also include the player already assigned at this seat, if any.
    if (seatAssignments[seatIndex] != null) {
      available.insert(0, seatAssignments[seatIndex]!);
    }
    if (available.isEmpty) return;
    Player? selected = await showDialog<Player>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Player to Seat"),
        content: SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: available.length,
            itemBuilder: (context, index) {
              final player = available[index];
              return ListTile(
                title: Text(player.name),
                onTap: () => Navigator.pop(context, player),
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
      ),
    );
    if (selected != null) {
      setState(() {
        seatAssignments[seatIndex] = selected;
      });
    }
  }

  /// Build a seat widget with a circular background.
  Widget _buildSeatWidget(int seatIndex) {
    final assigned = seatAssignments[seatIndex];
    return GestureDetector(
      onTap: () => _assignPlayerToSeat(seatIndex),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: assigned != null ? Colors.green : Colors.grey[600],
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Center(
          child: Text(
            assigned != null
                ? assigned.name.substring(0, math.min(assigned.name.length, 3))
                : "Seat",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  /// Build a table layout with seats placed around a rectangle.
  Widget _buildTableLayout() {
    // Here we position 6 seat placeholders around a centered table.
    return Stack(
      children: [
        // The table (centered rectangle).
        Center(
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.brown[700],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Top-left seat.
        Positioned(
          top: 40,
          left: 40,
          child: _buildSeatWidget(0),
        ),
        // Top-right seat.
        Positioned(
          top: 40,
          right: 40,
          child: _buildSeatWidget(1),
        ),
        // Bottom-left seat.
        Positioned(
          bottom: 40,
          left: 40,
          child: _buildSeatWidget(2),
        ),
        // Bottom-right seat.
        Positioned(
          bottom: 40,
          right: 40,
          child: _buildSeatWidget(3),
        ),
        // Left-middle seat.
        Positioned(
          left: 0,
          top: 100,
          child: _buildSeatWidget(4),
        ),
        // Right-middle seat.
        Positioned(
          right: 0,
          top: 100,
          child: _buildSeatWidget(5),
        ),
      ],
    );
  }

  void _startGame() {
    // Build a list of assigned players in seat order,
    // then filter out any nulls.
    List<Player> seatedPlayers =
        seatAssignments.values.whereType<Player>().toList();
    // For debugging:
    print("Seated Players: ${seatedPlayers.map((p) => p.name).toList()}");
    // Navigate to the game screen with the seating order.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          players: seatedPlayers,
          startingLife: widget.startingLife,
          isCommanderGame: widget.isCommanderGame,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seating Arrangement")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _buildTableLayout(),
            ),
          ),
          ElevatedButton(
            onPressed: _startGame,
            child: const Text("Start Game"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
