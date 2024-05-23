import 'dart:convert';
import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'game.dart';
import 'level.dart';

class Success {
  final int id;
  String libelle;
  String image;
  Rarity rarity;
  String condition;
  String rules;
  bool losable;
  int type;

  Success({
    required this.id,
    required this.libelle,
    required this.image,
    required this.rarity,
    required this.condition,
    required this.rules,
    required this.losable,
    required this.type
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
          losable: int.parse(json['tit_lose']) == 1 ? true : false,
          type: int.parse(json['tit_type']),
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
      losable: false,
      type: 0
    );
  }

  bool evaluate(User selectedUser, List<StatsPlay> playsList, List<User> usersList, List<Game> gamesList, List<Level> levelsList, List<Prize> prizesList, List<Transaction> transactionsList) {
    String code = """
    import 'dart:convert';
    
    class Game {
      int id;
      String name;
      String rules;
      String createdAt;
      int price;
      int nbPlayersMin;
      int nbPlayersMax;
      String image;
    
    
      Game({
        required this.id,
        required this.name,
        required this.rules,
        required this.createdAt,
        required this.price,
        required this.nbPlayersMin,
        required this.nbPlayersMax,
        required this.image,
      });
    
      factory Game.fromJson(Map<String, dynamic> json) {
        String price = (json['gam_price']).toString();
        price = price.split('.')[0];
        return Game(
          id: int.parse(json['gam_id']),
          name: json['gam_name'],
          rules: json['gam_rules'],
          createdAt: json['gam_created_at'],
          price: int.parse(price),
          nbPlayersMin : int.parse(json['gam_min_players']),
          nbPlayersMax : int.parse(json['gam_max_players']),
          image : json['gam_image'] ?? "",
        );
      }
    }
    
    class User {
      int id;
      String username;
      String email;
      int balance;
      String qr;
    
      User({
        required this.id,
        required this.username,
        required this.email,
        required this.balance,
        required this.qr,
      });
    
      factory User.fromJson(Map<String, dynamic> json) {
        String balance = (json['usr_balance']).toString();
        balance = balance.split('.')[0];
        return User(
          id: int.parse(json['usr_id']),
          username: json['usr_username'],
          email: json['usr_email'],
          balance: int.parse(balance),
          qr: json['usr_qr'],
        );
      }
    }
    
    class StatsPlay {
      final int gameid;
      final int levStep;
      final String parTime;
      final int gain;
      final int userId;
      final int score;
    
      StatsPlay({
        required this.gameid,
        required this.levStep,
        required this.parTime,
        required this.gain,
        required this.userId,
        required this.score,
      });
    
      factory StatsPlay.fromJson(Map<String, dynamic> json) {
        String gain = (json['gain']).toString();
        gain = gain.split('.')[0];
        return StatsPlay(
          gameid: int.parse(json['gam_id']),
          levStep: int.parse(json['lev_step']),
          parTime: json['par_time'],
          gain: int.parse(gain),
          userId: int.parse(json['usr_id']),
          score: int.parse(json['lev_score'])
        );
      }
    }
    
    class Level {
      final int gameId;
      int step;
      int cashPrize;
      String libelle;
      int score;
    
      Level({
        required this.gameId,
        required this.step,
        required this.cashPrize,
        required this.libelle,
        required this.score
      });
    
      factory Level.fromJson(Map<String, dynamic> json) {
        String cashprize = (json['lev_cashprize']).toString();
        cashprize = cashprize.split('.')[0];
        return Level(
          gameId: int.parse(json['gam_id']),
          step: int.parse(json['lev_step']),
          cashPrize: int.parse(cashprize),
          libelle: json['lev_libelle'] ?? "",
          score: int.parse(json['lev_score']),
        );
      }
    }
    
        
    class Prize {
      final int id;
      String name;
      String description;
      String createdAt;
      int price;
      String image;
      int stock;
    
      Prize({
        required this.id,
        required this.name,
        required this.description,
        required this.createdAt,
        required this.price,
        required this.image,
        required this.stock,
      });
    
      factory Prize.fromJson(Map<String, dynamic> json) {
        String price = (json['pri_price']).toString();
        price = price.split('.')[0];
        return Prize(
          id: int.parse(json['pri_id']),
          name: json['pri_name'] as String,
          description: json['pri_description'] as String,
          createdAt: json['pri_created_at'] as String,
          price: int.parse(price),
          image: json['pri_image'] ?? "",
          stock: int.parse(json['pri_stock']),
        );
      }
    }
    
    class Transaction {
      int usrId;
      int priId;
      String traTime;
      int traAmount;
      int payId;
    
    
      Transaction({
        required this.usrId,
        required this.priId,
        required this.traTime,
        required this.traAmount,
        required this.payId,
      });
    
      factory Transaction.fromJson(Map<String, dynamic> json) {
        String amount = (json['tra_amount']).toString();
        amount = amount.split('.')[0];
        return Transaction(
          usrId: int.parse(json['usr_id']),
          priId: int.tryParse(json['pri_id'] ?? "") ?? 0,
          traTime: json['tra_time'],
          traAmount: int.parse(amount),
          payId: int.tryParse(json['pay_id'] ?? "") ?? 0,
        );
      }
    
      Map<String, dynamic> toJson() {
        return {
          'usr_id': usrId.toString(),
          'pri_id': priId.toString(),
          'tra_time': traTime.toString(),
          'tra_amount': traAmount.toString(),
          'pay_id': payId.toString(),
        };
      }
    }

    List<Game> gamesListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Game> gameList = [];
      for (var json in jsonData) {
        gameList.add(Game.fromJson(json));
      }
      return gameList;
    }
    
    List<StatsPlay> statsPlaysListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<StatsPlay> statsPlayList = [];
      for (var json in jsonData) {
        statsPlayList.add(StatsPlay.fromJson(json));
      }
      return statsPlayList;
    }
    
    List<User> usersListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<User> userList = [];
      for (var json in jsonData) {
        userList.add(User.fromJson(json));
      }
      return userList;
    }
    
    List<Level> levelsListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Level> levelList = [];
      for (var json in jsonData) {
        levelList.add(Level.fromJson(json));
      }
      return levelList;
    }
    
    List<Prize> prizesListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Prize> prizeList = [];
      for (var json in jsonData) {
        prizeList.add(Prize.fromJson(json));
      }
      return prizeList;
    }

    List<Transaction> transactionsListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Transaction> transactionList = [];
      for (var json in jsonData) {
        transactionList.add(Transaction.fromJson(json));
      }
      return transactionList;
    }
    
    bool check(String jsonSelectedUser, String jsonPlaysList, String jsonUsersList, String jsonGamesList, String jsonLevelsList, String jsonPrizesList, String jsonTransactionsList) {
      User selectedUser = User.fromJson(jsonDecode(jsonSelectedUser));
      List<StatsPlay> playsList = statsPlaysListFromJson(jsonPlaysList);
      List<User> usersList = usersListFromJson(jsonUsersList);
      List<Game> gamesList = gamesListFromJson(jsonGamesList);
      List<Level> levelsList = levelsListFromJson(jsonLevelsList);
      List<Level> prizesList = prizesListFromJson(jsonPrizesList);
      List<Transaction> transactionsList = transactionsListFromJson(jsonTransactionsList);
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

  bool evaluatePlay(User selectedUser, List<StatsPlay> playsList, List<User> usersList, List<Game> gamesList, List<Level> levelsList) {
    String code = """
    import 'dart:convert';
    
    class Game {
      int id;
      String name;
      String rules;
      String createdAt;
      int price;
      int nbPlayersMin;
      int nbPlayersMax;
      String image;
    
    
      Game({
        required this.id,
        required this.name,
        required this.rules,
        required this.createdAt,
        required this.price,
        required this.nbPlayersMin,
        required this.nbPlayersMax,
        required this.image,
      });
    
      factory Game.fromJson(Map<String, dynamic> json) {
        String price = (json['gam_price']).toString();
        price = price.split('.')[0];
        return Game(
          id: int.parse(json['gam_id']),
          name: json['gam_name'],
          rules: json['gam_rules'],
          createdAt: json['gam_created_at'],
          price: int.parse(price),
          nbPlayersMin : int.parse(json['gam_min_players']),
          nbPlayersMax : int.parse(json['gam_max_players']),
          image : json['gam_image'] ?? "",
        );
      }
    }
    
    class User {
      int id;
      String username;
      String email;
      int balance;
      String qr;
    
      User({
        required this.id,
        required this.username,
        required this.email,
        required this.balance,
        required this.qr,
      });
    
      factory User.fromJson(Map<String, dynamic> json) {
        String balance = (json['usr_balance']).toString();
        balance = balance.split('.')[0];
        return User(
          id: int.parse(json['usr_id']),
          username: json['usr_username'],
          email: json['usr_email'],
          balance: int.parse(balance),
          qr: json['usr_qr'],
        );
      }
    }
    
    class StatsPlay {
      final int gameid;
      final int levStep;
      final String parTime;
      final int gain;
      final int userId;
      final int score;
    
      StatsPlay({
        required this.gameid,
        required this.levStep,
        required this.parTime,
        required this.gain,
        required this.userId,
        required this.score,
      });
    
      factory StatsPlay.fromJson(Map<String, dynamic> json) {
        String gain = (json['gain']).toString();
        gain = gain.split('.')[0];
        return StatsPlay(
          gameid: int.parse(json['gam_id']),
          levStep: int.parse(json['lev_step']),
          parTime: json['par_time'],
          gain: int.parse(gain),
          userId: int.parse(json['usr_id']),
          score: int.parse(json['lev_score'])
        );
      }
    }
    
    class Level {
      final int gameId;
      int step;
      int cashPrize;
      String libelle;
      int score;
    
      Level({
        required this.gameId,
        required this.step,
        required this.cashPrize,
        required this.libelle,
        required this.score
      });
    
      factory Level.fromJson(Map<String, dynamic> json) {
        String cashprize = (json['lev_cashprize']).toString();
        cashprize = cashprize.split('.')[0];
        return Level(
          gameId: int.parse(json['gam_id']),
          step: int.parse(json['lev_step']),
          cashPrize: int.parse(cashprize),
          libelle: json['lev_libelle'] ?? "",
          score: int.parse(json['lev_score']),
        );
      }
    }
    
    List<User> usersListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<User> userList = [];
      for (var json in jsonData) {
        userList.add(User.fromJson(json));
      }
      return userList;
    }
    
    List<Game> gamesListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Game> gameList = [];
      for (var json in jsonData) {
        gameList.add(Game.fromJson(json));
      }
      return gameList;
    }
    
    List<StatsPlay> statsPlaysListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<StatsPlay> statsPlayList = [];
      for (var json in jsonData) {
        statsPlayList.add(StatsPlay.fromJson(json));
      }
      return statsPlayList;
    }
    
    List<Level> levelsListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Level> levelList = [];
      for (var json in jsonData) {
        levelList.add(Level.fromJson(json));
      }
      return levelList;
    }
    
    bool check(String jsonSelectedUser, String jsonPlaysList, String jsonUsersList, String jsonGamesList, String jsonLevelsList) {
      User selectedUser = User.fromJson(jsonDecode(jsonSelectedUser));
      List<User> usersList = usersListFromJson(jsonUsersList);
      List<StatsPlay> playsList = statsPlaysListFromJson(jsonPlaysList);
      List<Game> gamesList = gamesListFromJson(jsonGamesList);
      List<Level> levelsList = levelsListFromJson(jsonLevelsList);
      $condition
    }
  """;

    String jsonSelectedUser = jsonEncode(selectedUser.toJson());
    String jsonPlaysList = jsonEncode(playsList.map((play) => play.toJson()).toList());
    String jsonUsersList = jsonEncode(usersList.map((user) => user.toJson()).toList());
    String jsonGamesList = jsonEncode(gamesList.map((game) => game.toJson()).toList());
    String jsonLevelsList = jsonEncode(levelsList.map((level) => level.toJson()).toList());
    final dynamic result = eval(code, function: 'check', args: [$String(jsonSelectedUser), $String(jsonPlaysList), $String(jsonUsersList), $String(jsonGamesList), $String(jsonLevelsList),]);
    return result as bool;
  }

  bool evaluateTransaction(User selectedUser, List<User> usersList, List<Prize> prizesList, List<Transaction> transactionsList) {
    String code = """
    import 'dart:convert';
    
    class User {
      int id;
      String username;
      String email;
      int balance;
      String qr;
    
      User({
        required this.id,
        required this.username,
        required this.email,
        required this.balance,
        required this.qr,
      });
    
      factory User.fromJson(Map<String, dynamic> json) {
        String balance = (json['usr_balance']).toString();
        balance = balance.split('.')[0];
        return User(
          id: int.parse(json['usr_id']),
          username: json['usr_username'],
          email: json['usr_email'],
          balance: int.parse(balance),
          qr: json['usr_qr'],
        );
      }
    }
        
    class Prize {
      final int id;
      String name;
      String description;
      String createdAt;
      int price;
      String image;
      int stock;
    
      Prize({
        required this.id,
        required this.name,
        required this.description,
        required this.createdAt,
        required this.price,
        required this.image,
        required this.stock,
      });
    
      factory Prize.fromJson(Map<String, dynamic> json) {
        String price = (json['pri_price']).toString();
        price = price.split('.')[0];
        return Prize(
          id: int.parse(json['pri_id']),
          name: json['pri_name'] as String,
          description: json['pri_description'] as String,
          createdAt: json['pri_created_at'] as String,
          price: int.parse(price),
          image: json['pri_image'] ?? "",
          stock: int.parse(json['pri_stock']),
        );
      }
    }
    
    class Transaction {
      int usrId;
      int priId;
      String traTime;
      int traAmount;
      int payId;
    
      Transaction({
        required this.usrId,
        required this.priId,
        required this.traTime,
        required this.traAmount,
        required this.payId,
      });
    
      factory Transaction.fromJson(Map<String, dynamic> json) {
        String amount = (json['tra_amount']).toString();
        amount = amount.split('.')[0];
        return Transaction(
          usrId: int.parse(json['usr_id']),
          priId: int.tryParse(json['pri_id'] ?? "") ?? 0,
          traTime: json['tra_time'],
          traAmount: int.parse(amount),
          payId: int.tryParse(json['pay_id'] ?? "") ?? 0,
        );
      }
    
      Map<String, dynamic> toJson() {
        return {
          'usr_id': usrId.toString(),
          'pri_id': priId.toString(),
          'tra_time': traTime.toString(),
          'tra_amount': traAmount.toString(),
          'pay_id': payId.toString(),
        };
      }
    }

    List<User> usersListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<User> userList = [];
      for (var json in jsonData) {
        userList.add(User.fromJson(json));
      }
      return userList;
    }
    
    List<Prize> prizesListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Prize> prizeList = [];
      for (var json in jsonData) {
        prizeList.add(Prize.fromJson(json));
      }
      return prizeList;
    }

    List<Transaction> transactionsListFromJson(String jsonString) {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      List<Transaction> transactionList = [];
      for (var json in jsonData) {
        transactionList.add(Transaction.fromJson(json));
      }
      return transactionList;
    }
    
    bool check(String jsonSelectedUser, String jsonUsersList, String jsonPrizesList, String jsonTransactionsList) {
      User selectedUser = User.fromJson(jsonDecode(jsonSelectedUser));
      List<User> usersList = usersListFromJson(jsonUsersList);
      List<Level> prizesList = prizesListFromJson(jsonPrizesList);
      List<Transaction> transactionsList = transactionsListFromJson(jsonTransactionsList);
      $condition
    }
  """;

    String jsonSelectedUser = jsonEncode(selectedUser.toJson());
    String jsonUsersList = jsonEncode(usersList.map((user) => user.toJson()).toList());
    String jsonPrizesList = jsonEncode(prizesList.map((prize) => prize.toJson()).toList());
    String jsonTransactionsList = jsonEncode(transactionsList.map((transaction) => transaction.toJson()).toList());
    final dynamic result = eval(code, function: 'check', args: [$String(jsonSelectedUser), $String(jsonUsersList), $String(jsonPrizesList), $String(jsonTransactionsList),]);
    return result as bool;
  }

  @override
  String toString() {
    return libelle;
  }
}