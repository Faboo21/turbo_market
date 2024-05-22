import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/level.dart';

Future<List<Level>> getAllLevelsByGame(int gameId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}"),);

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Level> levels =
    responseData.map((levelData) => Level.fromJson(levelData)).toList();

    List<Level> filteredLevels =
    levels.where((level) => level.gameId == gameId).toList();
    return filteredLevels;
  }
  return [];
}

Future<List<Level>> getAllLevels() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Level> levels =
    responseData.map((levelData) => Level.fromJson(levelData)).toList();
    return levels;
  }
  return [];
}

Future<Level> getLevelById(int levStep, int gamId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> levelData in responseData) {
      if (levelData['lev_step'] == levStep.toString() &&
          levelData['gam_id'] == gamId.toString()) {
        return Level.fromJson(levelData);
      }
    }
  }
  return Level(gameId: 1, step: 1, cashPrize: 0, libelle: '', score: 0);
}

Future<bool> updateLevel(Level level) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "gam_id": level.gameId.toString(),
        "lev_step": level.step.toString(),
        "lev_cashprize": level.cashPrize.toString(),
        "lev_libelle": level.libelle,
        "lev_score": level.score.toString()
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteLevel(Level level) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}&gam_id=${level.gameId}&lev_step=${level.step}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertLevel(Level level) async {
  http.Response response = await http.post(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/levels?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "gam_id": level.gameId.toString(),
        "lev_step": level.step.toString(),
        "lev_cashprize": level.cashPrize.toString(),
        "lev_libelle": level.libelle,
        "lev_score": level.score.toString()
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}