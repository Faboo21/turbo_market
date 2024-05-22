import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/payment_method.dart';

Future<bool> updatePaymentMethod(PaymentMethod mode) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/payment_method?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pay_id": mode.payId.toString(),
        "pay_libelle": mode.libelle,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deletePaymentMethod(PaymentMethod mode) async {
  http.Response response = await http.delete(
    Uri.parse(
        "https://obsolete-events.com/turbo-market/api/payment_method?token=${AppConfig.token}&pay_id=${mode.payId}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertPaymentMethod(PaymentMethod mode) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/payment_method?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pay_id": mode.payId.toString(),
        "pay_libelle": mode.libelle,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<PaymentMethod>> getAllPaymentMethod() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/payment_method?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<PaymentMethod> modes = responseData.map((modeData) => PaymentMethod.fromJson(modeData)).toList();
    return modes;
  }
  return [];
}
