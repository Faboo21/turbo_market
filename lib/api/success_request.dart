import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/success.dart';

Future<List<Success>> getAllSuccess() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/titles?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<Success> success = await Future.wait(responseData.map((successData) => Success.fromJson(successData)));
    return success;
  }
  return [];
}

Future<bool> updateSuccess(Success success) async {
  http.Response response = await http.put(
      Uri.parse("https://obsolete-events.com/turbo-market/api/titles?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "tit_id": success.id.toString(),
        "tit_libelle": success.libelle,
        "tit_condition": success.condition,
        "tit_rarity": success.rarity.id.toString(),
        "tit_image": success.image,
        "tit_rules": success.rules,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> deleteSuccess(Success success) async {
  http.Response response = await http.delete(
    Uri.parse("https://obsolete-events.com/turbo-market/api/titles?token=${AppConfig.token}&tit_id=${success.id}"),
  );
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> insertSuccess(Success success) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/create_title?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "tit_id": success.id.toString(),
        "tit_libelle": success.libelle,
        "tit_condition": success.condition,
        "tit_rarity": success.rarity.id.toString(),
        "tit_image": success.image,
        "tit_rules": success.rules,
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<bool> uploadSuccessImageToAPI(XFile imageFile, String name) async {
  try {
    Uint8List bytes = await imageFile.readAsBytes();
    http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: name,
    );
    var formData = http.MultipartRequest('POST', Uri.parse('https://obsolete-events.com/turbo-market/api/upload_title?token=${AppConfig.token}'));
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

Future<bool> updateSuccessImage(int successId) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/update_title_image?token=${AppConfig.token}"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "tit_id": successId.toString(),
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}