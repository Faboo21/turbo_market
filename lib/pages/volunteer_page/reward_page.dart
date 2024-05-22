import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/api/level_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/stats_play_request.dart';
import 'package:turbo_market/api/success_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/api/user_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/level.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key, required this.selectedUser, this.multiPlayers = false});

  final bool multiPlayers;
  final User selectedUser;

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  List<Level> levelslist = [];
  bool loading = false;
  List<Success> oldSuccess = [];
  List<Success> actualSuccess = [];

  @override
  void initState() {
    super.initState();
    loadLevels();
  }

  Future<void> loadOldSuccess() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Chargement des succès"),
        );
      },
    );
    List<User> users = await getAllUsers();
    List<StatsPlay> plays = await getAllStatsPlays();
    List<Game> games = await getAllGames();
    List<Transaction> transactionsList = await getAllTransactions();
    List<Level> levelList = await getAllLevels();
    List<Prize> prizesList = await getAllPrizes();
    List<Success> successList = await getAllSuccess();
    List<Success> validSuccess = [];
    for (var success in successList) {
      if (success.evaluate(widget.selectedUser, plays, users, games, levelList, prizesList, transactionsList)) {
        validSuccess.add(success);
      }
    }
    oldSuccess = validSuccess;
    Navigator.pop(context);
  }

  Future<void> loadNewSuccess() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Chargement des succès"),
        );
      },
    );
    List<User> users = await getAllUsers();
    List<StatsPlay> plays = await getAllStatsPlays();
    List<Game> games = await getAllGames();
    List<Transaction> transactionsList = await getAllTransactions();
    List<Level> levelList = await getAllLevels();
    List<Prize> prizesList = await getAllPrizes();
    List<Success> successList = await getAllSuccess();
    List<Success> validSuccess = [];
    for (var success in successList) {
      if (success.evaluate(widget.selectedUser, plays, users, games, levelList, prizesList, transactionsList)) {
        validSuccess.add(success);
      }
    }
    actualSuccess = validSuccess;

    for (var success in successList){
      String newSuccess = "";
      String loseSuccess = "";
      if (actualSuccess.any((element) => element.id == success.id) && !oldSuccess.any((element) => element.id == success.id)){
        newSuccess += "${success.libelle}, ";
      }
      if (oldSuccess.any((element) => element.id == success.id) && !actualSuccess.any((element) => element.id == success.id)){
        loseSuccess += "${success.libelle}, ";
      }
      if (newSuccess != ""){
        newSuccess = newSuccess.substring(0,newSuccess.length-2);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nouveau succès : $newSuccess")));
      }
      if (loseSuccess != ""){
        loseSuccess = loseSuccess.substring(0,loseSuccess.length-2);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Succès perdu : $loseSuccess")));
      }
    }
    Navigator.pop(context);
  }

  Future<void> loadLevels() async {
    var resLevelsList = await getAllLevelsByGame(AppConfig.game);
    if (resLevelsList.length == 1) {
      Game game = await getGameById(AppConfig.game);
      bool res2 = await addPlays(AppConfig.game, resLevelsList[0].step, widget.selectedUser.id);
      bool res1 = false;
      if (res2) {
        if (resLevelsList[0].libelle == "") {
          res1 = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance + resLevelsList[0].cashPrize - game.price);
          widget.selectedUser.balance = widget.selectedUser.balance + resLevelsList[0].cashPrize - game.price;
        } else {
          res1 = await updateUserBalance(widget.selectedUser, widget.selectedUser.balance - game.price);
          widget.selectedUser.balance = widget.selectedUser.balance - game.price;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gain : ${resLevelsList[0].libelle == "" ? "${resLevelsList[0].cashPrize * AppConfig.rate}ƒ" : resLevelsList[0].libelle} + ${resLevelsList[0].score} points")));
      Navigator.pop(context, res1 && res2);
    }
    setState(() {
      levelslist = resLevelsList;
    });
    setState(() {
      loading = false;
    });
    if (!widget.multiPlayers) {
      await loadOldSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompense'),
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: levelslist.length,
        itemBuilder: (context, index) {
          Level level = levelslist[index];
          return Card(
            child: ListTile(
              enabled: !loading,
              trailing: Text("${level.score} points"),
              title: level.libelle == "" ? Text(
                  "${level.step.toString()} : ${level.cashPrize *
                      AppConfig.rate}ƒ") : Text(
                  "${level.step.toString()} : ${level.libelle}"),
              onTap: () async {
                Game game = await getGameById(level.gameId);
                bool res2 = await addPlays(
                    AppConfig.game, level.step, widget.selectedUser.id);
                bool res1 = false;
                if (res2) {
                  if (level.libelle == "") {
                    res1 = await updateUserBalance(widget.selectedUser, widget
                        .selectedUser.balance + level.cashPrize - game.price);
                    widget.selectedUser.balance =
                        widget.selectedUser.balance + level.cashPrize -
                            game.price;
                  } else {
                    res1 = await updateUserBalance(widget.selectedUser, widget
                        .selectedUser.balance - game.price);
                    widget.selectedUser.balance =
                        widget.selectedUser.balance - game.price;
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gain : ${level.libelle == ""
                      ? "${level.cashPrize * AppConfig.rate}ƒ"
                      : level.libelle} + ${level.score} points")));
                if (!widget.multiPlayers) {
                  await loadNewSuccess();
                }
                Navigator.pop(context, res1 && res2);
              },
            ),
          );
        },
      ),
    );
  }
}