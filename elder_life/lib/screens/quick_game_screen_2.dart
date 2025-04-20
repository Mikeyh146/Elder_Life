import 'package:flutter/material.dart';

class QuickGameScreen2 extends StatelessWidget {
  const QuickGameScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quick Game - 2 Players")),
      body: const Center(
        child: Text("This is the 2-player quick game screen."),
      ),
    );
  }
}
