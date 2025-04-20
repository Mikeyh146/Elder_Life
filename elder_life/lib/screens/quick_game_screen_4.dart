import 'package:flutter/material.dart';

class QuickGameScreen4 extends StatelessWidget {
  const QuickGameScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quick Game - 4 Players")),
      body: const Center(
        child: Text("This is the 4-player quick game screen."),
      ),
    );
  }
}
