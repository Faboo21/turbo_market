import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/user.dart';

Future<bool> insertUser(String username, String mail, double rising, int payId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_account?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_username": username,
        "usr_email": mail,
        "usr_balance": rising.toString(),
        "pay_id": payId.toString()
      }));

  if (response.statusCode == 200) {
    return true;
  }

  return false;
}

Future<User?> getUserByQr(String qrId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}"),);

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

Future<bool> updateUserBalance(User user, double newBalance) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_id": user.id.toString(),
        "usr_username": user.username,
        "usr_email": user.email,
        "usr_balance": newBalance.toString(),
        "usr_qr": user.qr,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> userExist(String userEmail) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}"));
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

Future<List<User>> getAllUsers() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}"));
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
          "https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "usr_id": user.id.toString(),
        "usr_username": user.username,
        "usr_email": user.email,
        "usr_balance": user.balance.toString(),
        "usr_qr": user.qr,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteUser(User user) async {
  http.Response response = await http.delete(
    Uri.parse(
        "https://obsolete-events.com/turbo-market/api/users?token=${AppConfig.token}&usr_id=${user.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}
