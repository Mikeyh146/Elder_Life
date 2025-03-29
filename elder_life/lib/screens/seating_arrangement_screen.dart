import 'package:flutter/material.dart';
import '../models/player.dart';
import 'game_screen.dart';

class SeatingArrangementScreen extends StatefulWidget {
  final List<Player> players;
  final int startingLife;
  final bool isCommanderGame; // New flag

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
  // For a maximum of 6 players, always show 6 seats.
  static const int fixedSeatCount = 6;
  late List<Player?> assignedSeats;

  @override
  void initState() {
    super.initState();
    assignedSeats = List<Player?>.filled(fixedSeatCount, null);
  }

  List<Player> get availablePlayers => widget.players.where((p) => !assignedSeats.contains(p)).toList();

  Future<void> _assignSeat(int seatIndex) async {
    List<Player> options = availablePlayers;
    if (assignedSeats[seatIndex] != null) {
      options = List<Player>.from(options)..add(assignedSeats[seatIndex]!);
    }
    options.sort((a, b) => a.name.compareTo(b.name));
    Player? selected = await showDialog<Player>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select a player for this seat"),
          content: SizedBox(
            height: 250,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final player = options[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: Text(
                      player.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
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
        );
      },
    );
    if (selected != null) {
      setState(() {
        assignedSeats[seatIndex] = selected;
      });
    }
  }

  bool get allSeatsAssigned {
    // Ensure the number of filled seats equals the number of selected players.
    return assignedSeats.where((s) => s != null).length == widget.players.length;
  }

  void _confirmSeating() {
    if (!allSeatsAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please assign seats for all players.")),
      );
      return;
    }
    List<Player> seatingOrder = assignedSeats.whereType<Player>().toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          players: seatingOrder,
          startingLife: widget.startingLife,
          isCommanderGame: widget.isCommanderGame, // Pass flag to game screen.
        ),
      ),
    );
  }

  Widget _buildSeatingLayout() {
    const double containerSize = 500;
    const double seatSize = 80;
    const double gap = 20;

    final double tableWidth = 200;
    final double tableHeight = 100;
    final double tableLeft = (containerSize - tableWidth) / 2;
    final double tableTop = (containerSize - tableHeight) / 2;
    final Rect tableRect = Rect.fromLTWH(tableLeft, tableTop, tableWidth, tableHeight);

    List<Widget> seatWidgets = [];
    // Define fixed positions for 6 seats.
    seatWidgets.add(Positioned(
      left: tableRect.left,
      top: tableRect.top - seatSize - gap,
      child: _buildSeatWidget(0),
    ));
    seatWidgets.add(Positioned(
      left: tableRect.right - seatSize,
      top: tableRect.top - seatSize - gap,
      child: _buildSeatWidget(1),
    ));
    seatWidgets.add(Positioned(
      left: tableRect.left - seatSize - gap,
      top: tableRect.top + tableHeight / 2 - seatSize / 2,
      child: _buildSeatWidget(2),
    ));
    seatWidgets.add(Positioned(
      left: tableRect.right + gap,
      top: tableRect.top + tableHeight / 2 - seatSize / 2,
      child: _buildSeatWidget(3),
    ));
    seatWidgets.add(Positioned(
      left: tableRect.left,
      top: tableRect.bottom + gap,
      child: _buildSeatWidget(4),
    ));
    seatWidgets.add(Positioned(
      left: tableRect.right - seatSize,
      top: tableRect.bottom + gap,
      child: _buildSeatWidget(5),
    ));

    Widget tableWidget = Positioned(
      left: tableRect.left,
      top: tableRect.top,
      child: Container(
        width: tableWidth,
        height: tableHeight,
        decoration: BoxDecoration(
          color: Colors.brown[400],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        children: [
          tableWidget,
          ...seatWidgets,
        ],
      ),
    );
  }

  Widget _buildSeatWidget(int index) {
    return GestureDetector(
      onTap: () => _assignSeat(index),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Center(
          child: assignedSeats[index] == null
              ? const Text(
                  "Tap to assign",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[800],
                      radius: 20,
                      child: Text(
                        assignedSeats[index]!.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      assignedSeats[index]!.name,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Seating Arrangement")),
      body: Center(child: _buildSeatingLayout()),
      floatingActionButton: FloatingActionButton(
        onPressed: _confirmSeating,
        child: const Icon(Icons.check),
      ),
    );
  }
}
