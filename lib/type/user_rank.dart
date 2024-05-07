import 'package:turbo_market/type/success.dart';

class UserRank {
  int id;
  String username;
  double balance;
  double mean;
  String bestGame;
  String email;
  int nbGames;
  List<Success> success;
  int score;

  UserRank({
    required this.id,
    required this.username,
    required this.balance,
    required this.mean,
    required this.bestGame,
    required this.nbGames,
    required this.success,
    required this.score,
    required this.email,
  });
}