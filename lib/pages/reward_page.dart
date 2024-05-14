import 'package:flutter/material.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/level.dart';

import '../type/game.dart';
import '../type/user.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key, required this.selectedUser});

  final User selectedUser;

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<Level> levelslist = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> loadLevels() async {
    var resLevelsList = await getAllLevelsByGame(AppConfig.game);
    if (resLevelsList.length == 1) {
      Game game = await getGameById(resLevelsList[0].gameId);
      bool res2 = await addPlays(AppConfig.game, resLevelsList[0].step, widget.selectedUser.id);
      bool res1 = false;
      if (res2) {
        res1 = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + resLevelsList[0].cashPrize - game.price);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gain : ${resLevelsList[0].libelle == "" ? "${resLevelsList[0].cashPrize * AppConfig.rate} ƒ" : resLevelsList[0].libelle} + ${resLevelsList[0].score} points")));
      Navigator.pop(context, res1 && res2);
    }
    setState(() {
      levelslist = resLevelsList;
    });
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompense'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: levelslist.length,
        itemBuilder: (context, index) {
          Level level = levelslist[index];
          return Card(
            child: ListTile(
              trailing: Text("${level.score} points"),
              title: level.libelle == "" ? Text("${level.step.toString()} : ${level.cashPrize * AppConfig.rate} ƒ") : Text("${level.step.toString()} : ${level.libelle}"),
              onTap: () async {
                Game game = await getGameById(level.gameId);
                bool res2 = await addPlays(AppConfig.game, level.step, widget.selectedUser.id);
                bool res1 = false;
                if (res2) {
                  if (level.libelle == "") {
                    res1 = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + level.cashPrize - game.price);
                  } else {
                    res1 = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance - game.price);
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gain : ${level.libelle == "" ? "${level.cashPrize * AppConfig.rate} ƒ" : level.libelle} + ${level.score} points")));
                Navigator.pop(context, res1 && res2);
              },
            ),
          );
        },
      ),
    );
  }
}