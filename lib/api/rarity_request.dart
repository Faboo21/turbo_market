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

Future<bool> updateRarity(Rarity rarity) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/rarities?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "rar_id": rarity.id.toString(),
        "rar_libelle": rarity.libelle,
        "rar_value": rarity.value.toString(),
        "rar_color": rarity.color,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteRarity(Rarity rarity) async {
  http.Response response = await http.delete(
    Uri.parse(
        "https://obsolete-events.com/turbo-market/api/rarities?token=${AppConfig.token}&rar_id=${rarity.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertRarity(Rarity rarity) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/rarities?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "rar_id": rarity.id.toString(),
        "rar_libelle": rarity.libelle,
        "rar_value": rarity.value.toString(),
        "rar_color": rarity.color,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}