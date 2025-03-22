import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Colors.black;
  static const Color primary = Colors.deepPurple;
  static const Color secondary = Colors.deepOrange;
  static const Color text = Colors.white;
  static const Color accent = Colors.amber;
}

class GameRules {
  static const int startingLifeTotal = 40;
  static const int poisonCounterLimit = 10;
}

class Strings {
  static const String appName = "Elder Life";
  static const String confirmDeleteMessage = "Are you sure? This action is permanent.";
  static const String noCommanderMessage = "You have not selected a commander. Stats for this game will only track wins and losses.";
}
