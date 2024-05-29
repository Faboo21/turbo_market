import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/transaction.dart';

Future<bool> insertTransaction(int usrId, int priId, double traAmount, int payId) async {
  http.Response response = await http.post(
    Uri.parse("https://obsolete-events.com/turbo-market/api/transactions?token=${AppConfig.token}"),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
    body: jsonEncode(<String, String>{
      "usr_id": usrId.toString(),
      "pri_id": priId.toString(),
      "tra_amount": traAmount.toString(),
      "pay_id": payId.toString()
    }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> addTransaction(int usrId, int priId, double traAmount, int payId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/add_transaction?token=${AppConfig.token}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "usr_id": usrId.toString(),
        "pri_id": priId.toString(),
        "tra_amount": traAmount.toString(),
        "pay_id": payId.toString()
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<Transaction>> getAllTransactions() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/transactions?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Transaction> transactions = responseData.map((transactionData) => Transaction.fromJson(transactionData)).toList();
    return transactions;
  }
  return [];
}