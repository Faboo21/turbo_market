import 'package:turbo_market/type/success.dart';

class UserRank {
  int id;
  String username;
  double balance;
  double mean;
  String bestGame;
  int nbGames;
  List<Success> titles;
  int score;

  UserRank({
    required this.id,
    required this.username,
    required this.balance,
    required this.mean,
    required this.bestGame,
    required this.nbGames,
    required this.titles,
    required this.score,
  });
}