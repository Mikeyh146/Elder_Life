import 'package:flutter/material.dart';
import 'select_players_screen.dart';

class NewGameStartScreen extends StatelessWidget {
  const NewGameStartScreen({Key? key}) : super(key: key);

  Future<int?> _askNumberOfPlayers(BuildContext context) async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("How many players?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            int count = index + 2;
            return ListTile(
              title: Text("$count players"),
              onTap: () => Navigator.pop(context, count),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Game")),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Big red color
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Circular shape
            ),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            elevation: 10,
          ),
          onPressed: () async {
            int? numPlayers = await _askNumberOfPlayers(context);
            if (numPlayers != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectPlayersScreen(
                    numberOfPlayers: numPlayers,
                    gameType: "commander", // or "standard"
                    startingLife: 40, // default starting life
                  ),
                ),
              );
            }
          },
          child: const Text("START NEW GAME"),
        ),
      ),
    );
  }
}
