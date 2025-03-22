import 'dart:math';

class Helpers {
  static String generateRandomId() {
    final random = Random();
    return "${random.nextInt(99999)}-${DateTime.now().millisecondsSinceEpoch}";
  }

  static String formatWinRate(int wins, int gamesPlayed) {
    if (gamesPlayed == 0) return "0%";
    double rate = (wins / gamesPlayed) * 100;
    return "${rate.toStringAsFixed(1)}%";
  }
}
