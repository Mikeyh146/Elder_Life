import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class LocalStorage {
  static const String _playersKey = 'players';

  // Get the list of players from SharedPreferences.
  static Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getStringList(_playersKey) ?? [];
    return playersJson
        .map((playerString) =>
            Player.fromJson(jsonDecode(playerString) as Map<String, dynamic>))
        .toList();
  }

  // Add a new player and save the updated list.
  static Future<void> addPlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    List<Player> players = await getPlayers();
    players.add(player);
    final playersJson =
        players.map((player) => jsonEncode(player.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  // Update stats for all players and persist them.
  static Future<void> updateAllStats(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson =
        players.map((player) => jsonEncode(player.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  // Update a single player's record.
  static Future<void> updatePlayer(Player player) async {
  final prefs = await SharedPreferences.getInstance();
  List<Player> players = await getPlayers();
  int index = players.indexWhere((p) => p.id == player.id);
  if (index != -1) {
    players[index] = player;
    final updatedJson = players.map((p) => jsonEncode(p.toJson())).toList();
    print("Saving updated players: $updatedJson"); // Debug print
    await updateAllStats(players);
  } else {
    print("Player with id ${player.id} not found in storage.");
  }
}

  


}
