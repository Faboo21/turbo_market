import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/game.dart';

Future<bool> verifyPassword(int roleId, String password) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/api/password?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'tea_id': roleId.toString(),
        'tea_password': password
      }));
  if (response.statusCode == 200){
    if (json.decode(response.body)["res"]){
      return true;
    }
    return false;
  }
  return false;
}

Future<bool> insertUser(String username, String mail, String nfc, int rising) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/api/users?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_username": username,
        "usr_email": mail,
        "usr_balance": (rising * AppConfig.taux).toString(),
        "usr_nfc": nfc,
      }));

  if (response.statusCode == 200){
    return true;
  }
  return false;
}



Future<int> getExchangeRate() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/exchange_rate?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    if (responseData.isNotEmpty) {
      dynamic excValue = responseData[0]["exc_value"];
      if (excValue != null) {
        return int.parse(excValue);
      }
    }
  }
  return 0;
}

Future<String> getUsernameByNfc(String nfcId) async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/users?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);

    for (Map<String, dynamic> user in responseData) {
      if (user['usr_nfc'] == nfcId) {
        return user['usr_username'];
      }
    }
  }
  return "";
}

Future<List<Game>> getAllGames() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/games?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Game> games = responseData.map((gameData) => Game.fromJson(gameData)).toList();
    return games;
  }

  return [Game(id: 0, name: "rien", rules: "", createdAt: "", price: 1)];
}

