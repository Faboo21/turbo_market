import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/level.dart';
import 'package:turbo_market/type/user.dart';

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

Future<User?> getUserByNfc(String nfcId) async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/users?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);

    for (Map<String, dynamic> userData in responseData) {
      if (userData['usr_nfc'] == nfcId) {
        return User.fromJson(userData);
      }
    }
  }
  return null;
}

Future<List<Game>> getAllGames() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/games?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Game> games = responseData.map((gameData) => Game.fromJson(gameData)).toList();
    return games;
  }

  return [];
}

Future<List<Level>> getAllLevels(int gameId) async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/levels?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Level> levels = responseData.map((levelData) => Level.fromJson(levelData)).toList();

    List<Level> filteredLevels = levels.where((level) => level.gameId == gameId).toList();
    return filteredLevels;
  }
  return [];
}

Future<bool> updateUserBalance(User user, int newBalance) async {
  http.Response response = await http.put(
      Uri.parse("https://obsolete-events.com/api/users?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_id": user.id.toString(),
        "usr_username": user.username,
        "usr_email": user.email,
        "usr_balance": newBalance.toString(),
        "usr_nfc": user.nfc,
        "tit_id": user.titleId.toString(),
      }));
  if (response.statusCode == 200){
    return true;
  }
  return false;
}

Future<Level> getLevelById(int levStep, int gamId) async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/levels?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> levelData in responseData) {
      if (levelData['lev_step'] == levStep.toString() && levelData['gam_id'] == gamId.toString()) {
        return Level.fromJson(levelData);
      }
    }
  }
  return Level(gameId: 1, step: 1, cashPrize: 0);
}

Future<Game> getGameById(int gamId) async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/api/games?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> gameData in responseData) {
      if (gameData['gam_id'] == gamId.toString()) {
        return Game.fromJson(gameData);
      }
    }
  }
  return Game(id: 0, name: "Probleme d'api", rules: "rules", createdAt: "createdAt", price: 1000000000000000000);
}