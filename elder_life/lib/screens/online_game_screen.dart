import 'package:flutter/material.dart';

class OnlineGameScreen extends StatelessWidget {
  const OnlineGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Online Game")),
      body: const Center(
        child: Text(
          "Online Game Screen",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
