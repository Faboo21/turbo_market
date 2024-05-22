import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/prize.dart';

Future<bool> updatePrize(Prize prize) async {
  http.Response response = await http.put(
      Uri.parse(
          "https://obsolete-events.com/turbo-market/api/prizes?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prize.id.toString(),
        "pri_name": prize.name,
        "pri_description": prize.description,
        "pri_price": prize.price.toString(),
        "pri_image": prize.image,
        "pri_stock": prize.stock.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deletePrize(Prize prize) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/prizes?token=${AppConfig.token}&pri_id=${prize.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertPrize(Prize prize) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_prize?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prize.id.toString(),
        "pri_name": prize.name,
        "pri_description": prize.description,
        "pri_price": prize.price.toString(),
        "pri_image": prize.image,
        "pri_stock": prize.stock.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> uploadPrizeImageToAPI(XFile imageFile, String name) async {
  try {
    Uint8List bytes = await imageFile.readAsBytes();
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: name,
    );
    var formData = http.MultipartRequest('POST', Uri.parse('https://obsolete-events.com/turbo-market/api/upload_prize?token=${AppConfig.token}'));
    formData.files.add(multipartFile);
    http.StreamedResponse response = await formData.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return false;
  }
}

Future<bool> updatePrizeImage(int prizeId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/update_prize_image?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "pri_id": prizeId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<Prize>> getAllPrizes() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/prizes?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Prize> prizes = responseData.map((prizeData) => Prize.fromJson(prizeData)).toList();
    return prizes;
  }
  return [];
}