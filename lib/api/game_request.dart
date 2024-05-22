import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/game.dart';

Future<List<Game>> getAllGames() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/games?token=${AppConfig.token}"),);

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Game> games =
    responseData.map((gameData) => Game.fromJson(gameData)).toList();
    return games;
  }
  return [];
}

Future<Game> getGameById(int gamId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/games?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> gameData in responseData) {
      if (gameData['gam_id'] == gamId.toString()) {
        return Game.fromJson(gameData);
      }
    }
  }
  return Game(
      id: 0,
      name: "Probleme d'api",
      rules: "rules",
      createdAt: "createdAt",
      price: 1000000000000000000,
      nbPlayersMin: 0, nbPlayersMax: 0, image: '');
}

Future<bool> updateGame(Game game) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/games?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "gam_id": game.id.toString(),
        "gam_name": game.name,
        "gam_rules": game.rules,
        "gam_price": game.price.toString(),
        "gam_min_players": game.nbPlayersMin.toString(),
        "gam_max_players": game.nbPlayersMax.toString(),
        "gam_image": game.image
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteGame(Game game) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/games?token=${AppConfig.token}&gam_id=${game.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertGame(Game game) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_game?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "gam_id": game.id.toString(),
        "gam_name": game.name,
        "gam_rules": game.rules,
        "gam_price": game.price.toString(),
        "gam_min_players": game.nbPlayersMin.toString(),
        "gam_max_players": game.nbPlayersMax.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> uploadGameImageToAPI(XFile imageFile, String name) async {
  try {
    Uint8List bytes = await imageFile.readAsBytes();
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: name,
    );
    var formData = http.MultipartRequest('POST', Uri.parse('https://obsolete-events.com/turbo-market/api/upload_game?token=${AppConfig.token}'));
    formData.files.add(multipartFile);
    http.StreamedResponse response = await formData.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return false;
  }
}

Future<bool> updateGameImage(int prizeId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/update_game_image?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "gam_id": prizeId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}