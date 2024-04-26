import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/level.dart';
import 'package:turbo_market/type/stats_play.dart';
import 'package:turbo_market/type/user.dart';
import '../type/prize.dart';
import 'dart:typed_data';

Future<String> verifyPassword(int roleId, String password) async {
  http.Response response = await http.post(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/password?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'tea_id': roleId.toString(),
        'tea_password': password
      }));
  if (response.statusCode == 200) {
    if (json.decode(response.body)["token"] != null) {
      return json.decode(response.body)["token"];
    }
    return "";
  }
  return "";
}

Future<bool> insertUser(
    String username, String mail, int rising) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_account?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "usr_username": username,
        "usr_email": mail,
        "usr_balance": rising.toString(),
      }));

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<int> getExchangeRate() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/exchange_rate?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    if (responseData.isNotEmpty) {
      dynamic excValue = responseData[0]["set_value"];
      if (excValue != null) {
        return int.parse(excValue);
      }
    }
  }
  return 0;
}

Future<User?> getUserByQr(String qrId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);

    for (Map<String, dynamic> userData in responseData) {
      if (userData['usr_qr'] == qrId) {
        return User.fromJson(userData);
      }
    }
  }
  return null;
}

Future<List<Game>> getAllGames() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/games?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Game> games =
        responseData.map((gameData) => Game.fromJson(gameData)).toList();
    return games;
  }
  return [];
}

Future<List<Level>> getAllLevels(int gameId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/levels?api_key=${AppConfig.apiKey}"));

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

Future<bool> updateUserBalance(User user, double newBalance) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_id": user.id.toString(),
        "usr_username": user.username,
        "usr_email": user.email,
        "usr_balance": newBalance.toString(),
        "usr_qr": user.qr,
        "tit_id": user.titleId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<Level> getLevelById(int levStep, int gamId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/levels?api_key=${AppConfig.apiKey}"));

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> levelData in responseData) {
      if (levelData['lev_step'] == levStep.toString() &&
          levelData['gam_id'] == gamId.toString()) {
        return Level.fromJson(levelData);
      }
    }
  }
  return Level(gameId: 1, step: 1, cashPrize: 0, libelle: '');
}

Future<Game> getGameById(int gamId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/games?api_key=${AppConfig.apiKey}"));
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

Future<Map<String, dynamic>> getTokenInfo(String token) async {
  Uri uri = Uri.parse("https://obsolete-events.com/turbo-market/api/token?api_key=${AppConfig.apiKey}");
  http.Response response = await http.post(uri,
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "token": token,
      }));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return {};
}

Future<bool> addPlays(int gameId, int levStep, int userId) async {
    http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/plays?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "gam_id": gameId.toString(),
        "lev_step": levStep.toString(),
        "usr_id": userId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> sendQr(String usrEmail) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/qr?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "usr_email": usrEmail,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> userExist(String userEmail) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    for (Map<String, dynamic> userData in responseData) {
      if (userData['usr_email'] == userEmail) {
        return true;
      }
    }
  }
  return false;
}

Future<bool> updatePassword(String masterPassword, String newPassword, int teaId) async {
  http.Response response = await http.put(
      Uri.parse("https://obsolete-events.com/turbo-market/api/password?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "tea_id": teaId.toString(),
        "master_password": masterPassword,
        "new_password": newPassword
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<Prize>> getAllPrizes() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/prizes?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Prize> prizes = responseData.map((prizeData) => Prize.fromJson(prizeData)).toList();
    return prizes;
  }
  return [];
}

Future<bool> addTransaction(int usrId, int priId, double traAmount) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/transactions?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "usr_id": usrId.toString(),
        "pri_id": priId.toString(),
        "tra_amount": traAmount.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<StatsPlay>> get24hStatsPlays() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/stats24h?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<StatsPlay> plays = responseData.map((playsData) => StatsPlay.fromJson(playsData)).toList();
    return plays;
  }
  return [];
}

Future<List<StatsPlay>> getAllStatsPlays() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/statsAllTime?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<StatsPlay> plays = responseData.map((playsData) => StatsPlay.fromJson(playsData)).toList();
    return plays;
  }
  return [];
}

Future<List<User>> getAllUsers() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<User> users = responseData.map((userData) => User.fromJson(userData)).toList();
    return users;
  }
  return [];
}

Future<bool> updateUser(User user) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_id": user.id.toString(),
        "usr_username": user.username,
        "usr_email": user.email,
        "usr_balance": user.balance.toString(),
        "usr_qr": user.qr,
        "tit_id": user.titleId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteUser(User user) async {
  http.Response response = await http.delete(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/users?api_key=${AppConfig.apiKey}&usr_id=${user.id}"),
      );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> updateGame(Game game) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/games?api_key=${AppConfig.apiKey}"),
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

Future<bool> deleteGame(Game game) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/games?api_key=${AppConfig.apiKey}&gam_id=${game.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertGame(Game game) async {
  http.Response response = await http.post(
    Uri.parse("https://obsolete-events.com/turbo-market/api/create_game?api_key=${AppConfig.apiKey}"),
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

Future<bool> updatePrize(Prize prize) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/prizes?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prize.id.toString(),
        "pri_name": prize.name,
        "pri_description": prize.description,
        "pri_price": prize.price.toString(),
        "pri_image": prize.image,
        "pri_stock": prize.stock.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deletePrize(Prize prize) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/prizes?api_key=${AppConfig.apiKey}&pri_id=${prize.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertPrize(Prize prize) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_prize?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prize.id.toString(),
        "pri_name": prize.name,
        "pri_description": prize.description,
        "pri_price": prize.price.toString(),
        "pri_image": prize.image,
        "pri_stock": prize.stock.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> uploadPrizeImageToAPI(XFile imageFile, String name) async {
  try {
    Uint8List bytes = await imageFile.readAsBytes();
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: name,
    );
    var formData = http.MultipartRequest('POST', Uri.parse('https://obsolete-events.com/turbo-market/api/upload_prize?api_key=${AppConfig.apiKey}'));
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

Future<bool> updatePrizeImage(int prizeId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/update_prize_image?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prizeId.toString(),
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
    var formData = http.MultipartRequest('POST', Uri.parse('https://obsolete-events.com/turbo-market/api/upload_game?api_key=${AppConfig.apiKey}'));
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
      Uri.parse("https://obsolete-events.com/turbo-market/api/update_game_image?api_key=${AppConfig.apiKey}"),
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