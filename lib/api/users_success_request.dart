import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/api/success_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/users_success.dart';

Future<List<Success>> getAllSuccessByUserId(int userId) async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users_titles?token=${AppConfig.token}"),);
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<UsersSuccess> links = responseData.map((successData) => UsersSuccess.fromJson(successData)).toList();
    List<Success> success = await getAllSuccess();
    List<Success> validSuccess = [];
    for (UsersSuccess link in links){
      if (link.usrId == userId) {
        validSuccess.add(success.where((element) {return element.id == link.titId;}).first);
      }
    }
    return validSuccess;
  }
  return [];
}

Future<bool> insertUsersSuccess(int userId, int succId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/users_titles?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "tit_id": succId.toString(),
        "usr_id": userId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<UsersSuccess>> getAllUserSuccess() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/users_titles?token=${AppConfig.token}"),);

  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<UsersSuccess> links = responseData.map((successData) => UsersSuccess.fromJson(successData)).toList();
    return links;
  }
  return [];
}

Future<bool> deleteUsersSuccess(int usrId, int titId) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/users_titles?token=${AppConfig.token}&usr_id=$usrId&tit_id=$titId"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}