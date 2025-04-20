import 'commander.dart';

class Player {
  final String id;
  String name;

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

  // NEW: Tracking wins with each commander. The key is the commander's name, value is the win count.
  Map<String, int> winCommanders;

  // NEW: Tracking defeat state
  bool isDefeated;

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
    Map<String, int>? winCommanders,
    this.isDefeated = false, // Initialize isDefeated to false
  })  : commanders = commanders ?? [],
        winCommanders = winCommanders ?? {};

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
        'winCommanders': winCommanders,
        'isDefeated': isDefeated, // Add isDefeated to the saved data
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      playersDefeated: json['playersDefeated'] as int? ?? 0,
      isMonarch: json['isMonarch'] as bool? ?? false,
      hasInitiative: json['hasInitiative'] as bool? ?? false,
      isAscended: json['isAscended'] as bool? ?? false,
      dayNight: json['dayNight'] as String? ?? "off",
      energy: json['energy'] as int? ?? 0,
      exp: json['exp'] as int? ?? 0,
      poison: json['poison'] as int? ?? 0,
      rad: json['rad'] as int? ?? 0,
      commanders: json['commanders'] != null
          ? (json['commanders'] as List)
              .map((c) => Commander.fromJson(c as Map<String, dynamic>))
              .toList()
          : [],
      commanderDamage: json['commanderDamage'] as int? ?? 0,
      winCommanders: (json['winCommanders'] as Map?)?.cast<String, int>() ?? {},
      isDefeated: json['isDefeated'] as bool? ?? false, // Deserialize isDefeated
    );
  }
}
