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

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> loadLevels() async {
    var resLevelsList = await getAllLevels(AppConfig.game);
    setState(() {
      levelslist = resLevelsList;
    });
  }

  bool awardSuccess() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompense'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: levelslist.isEmpty ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: levelslist.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text("${levelslist[index].step.toString()} : ${levelslist[index].cashPrize * AppConfig.taux} ƒ"),
              onTap: () async {
                Game game = await getGameById(levelslist[index].gameId);
                bool? res = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + levelslist[index].cashPrize - game.price);
                Navigator.pop(context, res);
              },
            ),
          );
        },
      ),
    );
  }
}