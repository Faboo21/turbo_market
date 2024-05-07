import 'dart:convert';

import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/level.dart';
import 'package:turbo_market/type/prize.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/stats_play.dart';
import 'package:turbo_market/type/transaction.dart';
import 'package:turbo_market/type/user.dart';

class Success {
  final int id;
  String libelle;
  String image;
  Rarity rarity;
  String condition;
  String rules;

  Success({
    required this.id,
    required this.libelle,
    required this.image,
    required this.rarity,
    required this.condition,
    required this.rules
  });

  static Future<Success> fromJson(Map<String, dynamic> json) async {
    List<Rarity> rarities = await getAllRarities();
    for (Rarity rarity in rarities) {
      if (rarity.id == int.parse(json['tit_rarity'])) {
        return Success(
          id: int.parse(json['tit_id']),
          libelle: json['tit_libelle'],
          image: json['tit_image'] ?? "",
          rarity: rarity,
          condition: json['tit_condition'],
          rules: json['tit_rules'],
        );
      }
    }
    return Success(
      id: int.parse(json['tit_id']),
      libelle: json['tit_libelle'],
      image: json['tit_image'] ?? "",
      rarity: Rarity(id: 0, libelle: "unknown", value: 0, color: "0x000000"),
      condition: json['tit_condition'],
      rules: json['tit_rules'],
    );
  }

  bool evaluate(User selectedUser, List<StatsPlay> playsList, List<User> usersList, List<Game> gamesList, List<Level> levelsList, List<Prize> prizesList, List<Transaction> transactionsList) {
    String code = """
    
    bool check(String userData) {
      User selectedUser = stringToUser(userData);
      $condition
    }
    
  """;

    String jsonSelectedUser = jsonEncode(selectedUser.toJson());
    String jsonPlaysList = jsonEncode(playsList.map((play) => play.toJson()).toList());
    String jsonUsersList = jsonEncode(usersList.map((user) => user.toJson()).toList());
    String jsonGamesList = jsonEncode(gamesList.map((game) => game.toJson()).toList());
    String jsonLevelsList = jsonEncode(levelsList.map((level) => level.toJson()).toList());
    String jsonPrizesList = jsonEncode(prizesList.map((prize) => prize.toJson()).toList());
    String jsonTransactionsList = jsonEncode(transactionsList.map((transaction) => transaction.toJson()).toList());

    final dynamic result = eval(code, function: 'check', args: [$String(jsonSelectedUser), $String(jsonPlaysList), $String(jsonUsersList), $String(jsonGamesList), $String(jsonLevelsList), $String(jsonPrizesList), $String(jsonTransactionsList),]);
    return result as bool;
  }
}