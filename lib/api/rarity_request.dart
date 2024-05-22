import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/rarity.dart';

Future<List<Rarity>> getAllRarities() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/rarities?token=${AppConfig.token}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Rarity> raritys =
    responseData.map((rarityData) => Rarity.fromJson(rarityData)).toList();
    return raritys;
  }
  return [];
}