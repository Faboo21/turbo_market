import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';

Future<bool> updateExchangeRate(int newExchangeRate) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/exchange_rate?token=${AppConfig
              .token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "set_value": newExchangeRate.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<int> getExchangeRate() async {
  http.Response response = await http.get(Uri.parse(
      "https://obsolete-events.com/turbo-market/api/exchange_rate?token=${AppConfig.token}"),);
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