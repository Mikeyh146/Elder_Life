import 'player.dart';

class Game {
  List<Player> players;
  Player? winner;
  Map<String, String> defeatReasons; // Stores defeat reasons using player names as keys

  Game({
    required this.players,
    this.winner,
    Map<String, String>? defeatReasons,
  }) : defeatReasons = defeatReasons ?? {};

  // Convert to JSON for local storage
  Map<String, dynamic> toJson() => {
        'players': players.map((p) => p.toJson()).toList(),
        'winner': winner?.toJson(),
        'defeatReasons': defeatReasons, // Now using a String key instead of Player object
      };

  // Create Game from JSON
  factory Game.fromJson(Map<String, dynamic> json) {
    List<Player> loadedPlayers =
        (json['players'] as List).map((p) => Player.fromJson(p)).toList();
    Player? loadedWinner =
        json['winner'] != null ? Player.fromJson(json['winner']) : null;
    Map<String, String> defeatReasons =
        Map<String, String>.from(json['defeatReasons'] ?? {});

    return Game(players: loadedPlayers, winner: loadedWinner, defeatReasons: defeatReasons);
  }
}
