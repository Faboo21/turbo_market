import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';

Future<String> verifyPassword(int roleId, String password) async {
  try {
  http.Response response = await http.post(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/password?token=${AppConfig.token}"),
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
  } on Exception catch (_) {return "cors";}
}

Future<Map<String, dynamic>> getTokenInfo(String token) async {
  Uri uri = Uri.parse("https://obsolete-events.com/turbo-market/api/token?token=${AppConfig.token}");
  http.Response response = await http.get(uri, headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  return {};
}

Future<bool> sendQr(String usrEmail) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/qr?token=${AppConfig.token}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "usr_email": usrEmail,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> updatePassword(String masterPassword, String newPassword, int teaId) async {
  http.Response response = await http.put(
      Uri.parse("https://obsolete-events.com/turbo-market/api/password?token=${AppConfig.token}"),
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