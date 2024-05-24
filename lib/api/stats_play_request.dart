import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';

Future<bool> addPlays(int gameId, int levStep, int userId, int cluster) async {
  http.Response response = await http.post(
      Uri.parse("https://obsolete-events.com/turbo-market/api/plays?token=${AppConfig.token}"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{
        "gam_id": gameId.toString(),
        "lev_step": levStep.toString(),
        "usr_id": userId.toString(),
        "pla_cluster": cluster.toString()
      }));
  if (response.statusCode == 200) {
    return true;
  }
  return false;
}

Future<List<StatsPlay>> get24hStatsPlays() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/stats24h?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<StatsPlay> plays = responseData.map((playsData) => StatsPlay.fromJson(playsData)).toList();
    return plays;
  }
  return [];
}

Future<List<StatsPlay>> getAllStatsPlays() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/statsAllTime?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<StatsPlay> plays = responseData.map((playsData) => StatsPlay.fromJson(playsData)).toList();
    return plays;
  }
  return [];
}

Future<int> getLastCluster() async {
  http.Response response = await http.get(Uri.parse("https://obsolete-events.com/turbo-market/api/statsAllTime?token=${AppConfig.token}"));
  if (response.statusCode == 200) {
    List<dynamic> responseData = json.decode(response.body);
    List<StatsPlay> plays = responseData.map((playsData) => StatsPlay.fromJson(playsData)).toList();
    return plays.map((e) {return e.cluster;}).max;
  }
  return 0;
}