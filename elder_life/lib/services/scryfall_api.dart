import 'dart:convert';
import 'package:http/http.dart' as http;

class ScryfallAPI {
  static const String baseUrl = "https://api.scryfall.com/cards/named?exact=";

  static Future<String?> fetchCommanderImage(String commanderName) async {
    final url = Uri.parse("$baseUrl$commanderName");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["image_uris"]["normal"];
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching commander image: $e");
      return null;
    }
  }
}
