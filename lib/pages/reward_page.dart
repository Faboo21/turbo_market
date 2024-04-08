import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/level.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<Level> levelslist = [];

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> loadLevels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var resLevelsList = await getAllLevels(prefs.getInt("game_id")!);
    setState(() {
      levelslist = resLevelsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choix du jeu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: levelslist.isEmpty ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: levelslist.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text("${levelslist[index].step.toString()} : ${levelslist[index].cashPrize.toString()} Floppies"),
              onTap: () async {
                print(levelslist[index].step);
                print(levelslist[index].gameId);
              },
            ),
          );
        },
      ),
    );
  }
}