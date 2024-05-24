import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  List<String> xLabels = [];
  double total = 0;
  double mean = 0;
  int nbPlays = 0;

  String selectedGame = "All Games";
  DateTime? _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1);

  @override
  void initState() {
    loadGames();
    _calculateCumulativeSums();
    super.initState();
  }

  Future<void> loadGames() async {
    List<Game> games = await getAllGames();
    setState(() {
      gamesList = ["All Games"] + games.map((e) {return "${e.id} : ${e.name}";}).toList();
    });
  }

  Future<void> _calculateCumulativeSums() async {
    List<StatsPlay> resList = await getAllStatsPlays();

    if (_startDate == null || _endDate == null) {
      return;
    }

    List<StatsPlay> filteredParties = resList.where((partie) {
      DateTime partieDate = DateTime.parse(partie.parTime);
      return (partieDate.isAtSameMomentAs(_startDate!) || partieDate.isAfter(_startDate!)) &&
          (partieDate.isAtSameMomentAs(_endDate!) || partieDate.isBefore(_endDate!));
    }).toList();

    filteredParties.sort((a, b) => DateTime.parse(a.parTime).compareTo(DateTime.parse(b.parTime)));

    Duration totalDuration = _endDate!.difference(_startDate!);
    Duration intervalDuration = totalDuration ~/ 12;

    List<double> cumulativeSums = List.generate(12, (index) => 0.0);
    List<String> labels = List.generate(12, (index) => '');
    double currentSum = 0.0;
    DateFormat dateFormat = DateFormat('HH_ dd-MM');

    List<Game> games = await getAllGames();

    Game? game = games.where((game) {return game.id == (int.tryParse(selectedGame.split(" : ").first) ?? 0);}).firstOrNull;
    int cpt = 0;
    List<int> checkedCluster = [];
    for (int i = 0; i < 12; i++) {
      DateTime intervalStart = _startDate!.add(intervalDuration * i);
      DateTime intervalEnd = i == 11 ? _endDate! : intervalStart.add(intervalDuration);

      labels[i] = dateFormat.format(intervalEnd).replaceAll("_", "H");

      for (StatsPlay partie in filteredParties) {
        DateTime partieDate = DateTime.parse(partie.parTime);
        if (game == null || game.id == partie.gameid) {
          if (i == 0) {
            if (!checkedCluster.contains(partie.cluster)){
              cpt++;
              checkedCluster.add(partie.cluster);
            }
          }
          if ((partieDate.isAtSameMomentAs(intervalStart) || partieDate.isAfter(intervalStart)) &&
              (partieDate.isAtSameMomentAs(intervalEnd) || partieDate.isBefore(intervalEnd))) {
            currentSum -= partie.gain;
          }
        }
      }

      cumulativeSums[i] = currentSum;
    }

    setState(() {
      nbPlays = cpt;
      total = cumulativeSums.last;
      mean = cpt == 0 ? 0 : cumulativeSums.last / cpt;
      hourlyStats = cumulativeSums;
      xLabels = labels;
    });
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
                "Gains : $total€",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: total > 0 ? Colors.lightGreenAccent : Colors.red),
              ),
              const SizedBox(width: 10),
              Text(
                "Gains par partie : ${mean.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: mean > 0 ? Colors.lightGreenAccent : Colors.red),
              ),
              const SizedBox(width: 10),
              Text(
                "Nb Parties : $nbPlays",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedGame,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGame = newValue!;
                      });
                      _calculateCumulativeSums();
                    },
                    items: gamesList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 12,),
                IconButton(
                  onPressed: () {
                    _showDatePicker(context);
                  },
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 500,
              child: hourlyStats.isNotEmpty
                  ? CustomLineChart(hourlyStats: hourlyStats, xLabels: xLabels)
                  : const Placeholder(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Date Range'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  if (args.value is PickerDateRange) {
                    setState(() {
                      _startDate = args.value.startDate;
                      _endDate = args.value.endDate;
                    });
                    _calculateCumulativeSums();
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
