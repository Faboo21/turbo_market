import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';

Future<bool> verifyPassword(int roleId, String password) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/api/password.php?api_key=${AppConfig.apiKey}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'tea_id': roleId.toString(),
        'tea_password': password
      }));
  if (response.statusCode == 200){
    if (json.decode(response.body)["res"]){
      return true;
    }
    return false;
  }
  return false;
}