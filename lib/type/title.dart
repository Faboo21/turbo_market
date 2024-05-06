import 'package:dart_eval/dart_eval.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/user.dart';

class UserTitle {
  final int id;
  String libelle;
  String image;
  Rarity rarity;
  String condition;
  String rules;

  UserTitle({
    required this.id,
    required this.libelle,
    required this.image,
    required this.rarity,
    required this.condition,
    required this.rules
  });

  factory UserTitle.fromJson(Map<String, dynamic> json) {
    return UserTitle(
      id: int.parse(json['tit_id']),
      libelle: json['tit_libelle'],
      image: json['tit_image'] ?? "",
      rarity: json['tit_rarity'].toString().stringToRarity(),
      condition: json['tit_condition'],
      rules: json['tit_rules'],
    );
  }

  bool evaluate(User selectedUser) {
    String userAsString = '''
    ${selectedUser.id.toString()},
    "${selectedUser.username}",
    "${selectedUser.email}",
    ${selectedUser.balance.toInt().toString()},
    "${selectedUser.qr}"
  ''';

    String code = """
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
    }

    User stringToUser(String userData) {
      List<String> data = userData.split(',');
      int id = int.parse(data[0]);
      String username = data[1].trim().replaceAll('"', '');
      String email = data[2].trim().replaceAll('"', '');
      int balance = int.parse(data[3]);
      String qr = data[4].trim().replaceAll('"', '');
      
      return User(id: id, username: username, email: email, balance: balance, qr: qr);
    }

    bool check(String userData) {
      User selectedUser = stringToUser(userData);
      $condition
    }
  """;

    final dynamic result = eval(code, function: 'check', args: [$String(userAsString)]);

    return result as bool;
  }


}