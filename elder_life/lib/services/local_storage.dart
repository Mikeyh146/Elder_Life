import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';
import '../models/pod.dart'; // Import the Pod model

class LocalStorage {
  static const String _playersKey = 'players';
  static const String _podsKey = 'pods';  // New key for storing pods

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

  // Get the list of pods from SharedPreferences.
  static Future<List<Pod>> getPods() async {
    final prefs = await SharedPreferences.getInstance();
    final podsJson = prefs.getStringList(_podsKey) ?? [];
    return podsJson
        .map((podString) =>
            Pod.fromJson(jsonDecode(podString) as Map<String, dynamic>))
        .toList();
  }

  // Add a new pod and save the updated list.
  static Future<void> addPod(Pod pod) async {
    final prefs = await SharedPreferences.getInstance();
    List<Pod> pods = await getPods();
    pods.add(pod);
    final podsJson =
        pods.map((pod) => jsonEncode(pod.toJson())).toList();
    await prefs.setStringList(_podsKey, podsJson);
  }

  // Delete a pod's record.
  static Future<void> deletePod(Pod pod) async {
    final prefs = await SharedPreferences.getInstance();
    List<Pod> pods = await getPods();
    pods.removeWhere((p) => p.id == pod.id);
    final podsJson =
        pods.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_podsKey, podsJson);
  }

  // Update stats for all players and persist them.
  static Future<void> updateAllStats(List<Player> updatedPlayers) async {
    final prefs = await SharedPreferences.getInstance();
    // Load all players currently stored.
    List<Player> allPlayers = await getPlayers();
    
    // For each player from the game, update or add it in the full list.
    for (var updated in updatedPlayers) {
      int index = allPlayers.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        // Update the existing player.
        allPlayers[index] = updated;
      } else {
        // If not found, add the player (if needed).
        allPlayers.add(updated);
      }
    }
    
    // Save the complete list back.
    final playersJson = allPlayers.map((player) => jsonEncode(player.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  // Update a single player's record.
  static Future<void> updatePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    List<Player> players = await getPlayers();
    int index = players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      players[index] = player;
      final updatedJson =
          players.map((p) => jsonEncode(p.toJson())).toList();
      print("Saving updated players: $updatedJson"); // Debug print
      await updateAllStats(players);
    } else {
      print("Player with id ${player.id} not found in storage.");
    }
  }

  // Delete a player's record.
  static Future<void> deletePlayer(Player player) async {
    final prefs = await SharedPreferences.getInstance();
    List<Player> players = await getPlayers();
    players.removeWhere((p) => p.id == player.id);
    final playersJson =
        players.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_playersKey, playersJson);
  }
}
