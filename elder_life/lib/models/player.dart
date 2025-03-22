import 'commander.dart';

class Player {
  final String id;
  final String name;

  // Basic stats
  int wins;
  int losses;
  int gamesPlayed;
  int playersDefeated;

  // Current game states
  bool isMonarch;
  bool hasInitiative;
  bool isAscended;
  String dayNight; // "off", "day", or "night"
  int energy;
  int exp;
  int poison;
  int rad;

  // List of commanders (for up to six commanders per player)
  List<Commander> commanders;

  // New field for tracking total commander damage
  int commanderDamage;

  Player({
    required this.id,
    required this.name,
    this.wins = 0,
    this.losses = 0,
    this.gamesPlayed = 0,
    this.playersDefeated = 0,
    this.isMonarch = false,
    this.hasInitiative = false,
    this.isAscended = false,
    this.dayNight = "off",
    this.energy = 0,
    this.exp = 0,
    this.poison = 0,
    this.rad = 0,
    List<Commander>? commanders,
    this.commanderDamage = 0,
  }) : commanders = commanders ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wins': wins,
        'losses': losses,
        'gamesPlayed': gamesPlayed,
        'playersDefeated': playersDefeated,
        'isMonarch': isMonarch,
        'hasInitiative': hasInitiative,
        'isAscended': isAscended,
        'dayNight': dayNight,
        'energy': energy,
        'exp': exp,
        'poison': poison,
        'rad': rad,
        'commanders': commanders.map((c) => c.toJson()).toList(),
        'commanderDamage': commanderDamage,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      playersDefeated: json['playersDefeated'] ?? 0,
      isMonarch: json['isMonarch'] ?? false,
      hasInitiative: json['hasInitiative'] ?? false,
      isAscended: json['isAscended'] ?? false,
      dayNight: json['dayNight'] ?? "off",
      energy: json['energy'] ?? 0,
      exp: json['exp'] ?? 0,
      poison: json['poison'] ?? 0,
      rad: json['rad'] ?? 0,
      commanders: json['commanders'] != null
          ? (json['commanders'] as List)
              .map((c) => Commander.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      commanderDamage: json['commanderDamage'] ?? 0,
    );
  }
}
