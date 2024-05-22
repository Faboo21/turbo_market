import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/widget/graph24h_widget.dart';
import 'package:turbo_market/api/stats_play_request.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<double> hourlyStats = [];
  List<String> gamesList = [];
  double total = 0;
  double mean = 0;
  int nbPlays = 0;

  String selectedGame = "All Games";
  String selectedTimeRange = '24h';

  @override
  void initState() {
    loadPlays();
    super.initState();
  }

  void loadPlays() async {
    List<StatsPlay> resList;
    if (selectedTimeRange == "24h") {
      resList = await get24hStatsPlays();
    } else {
      resList = await getAllStatsPlays();
    }
    List<Game> resGamesList = await getAllGames();
    int cpt = 0;

    Map<int, double> hourlyGains = {};
    for (var play in resList) {
      int day = DateTime.parse(play.parTime).day;
      if (selectedTimeRange == "24h") {
        if (day == DateTime.now().day){
          int hour = DateTime
              .parse(play.parTime)
              .hour;
          if (selectedGame == "All Games") {
            hourlyGains[hour] = (hourlyGains[hour] ?? 0) + play.gain;
            cpt++;
          }
          else {
            if (play.gameid == int.parse(selectedGame.split(" : ")[0])) {
              hourlyGains[hour] = (hourlyGains[hour] ?? 0) + play.gain;
              cpt++;
            }
          }
        }
      } else {
        int hour = DateTime
            .parse(play.parTime)
            .hour;
        if (selectedGame == "All Games") {
          hourlyGains[hour] = (hourlyGains[hour] ?? 0) + play.gain;
          cpt++;
        }
        else {
          if (play.gameid == int.parse(selectedGame.split(" : ")[0])) {
            hourlyGains[hour] = (hourlyGains[hour] ?? 0) + play.gain;
            cpt++;
          }
        }
      }
    }

    List<double> hourlySumGains = List.generate(24, (index) => hourlyGains[index] ?? 0);
    List<String> resGamesId = List.generate(resGamesList.length, (index) => "${resGamesList[index].id} : ${resGamesList[index].name}");

    setState(() {
      gamesList = ["All Games"] + resGamesId;
      total = hourlySumGains.sum;
      mean = double.parse((hourlySumGains.sum / (cpt == 0 ? 1 : cpt)).toStringAsFixed(2));
      hourlyStats = selectedTimeRange == "24h" ? cumulativeSum(hourlySumGains) : hourlySumGains;
      nbPlays = cpt;
    });
  }

  List<double> cumulativeSum(List<double> numbers) {
    List<double> result = [];
    double sum = 0;

    for (double number in numbers) {
      sum += number;
      result.add(sum);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Text(
                "Total : $total",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: total > 0 ? Colors.lightGreenAccent : Colors.red),
              ),
              const SizedBox(width: 10),
              Text(
                "Moyenne : $mean",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: mean > 0 ? Colors.lightGreenAccent : Colors.red),
              ),
              const SizedBox(width: 10),
              Text(
                "Nb Parties : $nbPlays",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: selectedGame,
                  onChanged: (newValue) {
                    setState(() {
                      selectedGame = newValue!;
                    });
                    loadPlays();
                  },
                  items: gamesList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedTimeRange,
                  onChanged: (newValue) {
                    setState(() {
                      selectedTimeRange = newValue!;
                    });
                    loadPlays();
                  },
                  items: <String>['24h', 'All time'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              child: hourlyStats.isNotEmpty
                  ? CustomLineChart(hourlyStats: hourlyStats)
                  : const Placeholder(),
            ),
          ],
        ),
      ),
    );
  }
}
