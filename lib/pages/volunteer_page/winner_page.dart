import 'package:flutter/material.dart';
import 'package:turbo_market/api/users_success_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/level.dart';
import 'package:turbo_market/type/api_type/prize.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/transaction.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/api/level_request.dart';
import 'package:turbo_market/api/prize_request.dart';
import 'package:turbo_market/api/stats_play_request.dart';
import 'package:turbo_market/api/success_request.dart';
import 'package:turbo_market/api/transaction_request.dart';
import 'package:turbo_market/api/user_request.dart';

class WinnerChoicePage extends StatefulWidget {
  final List<User?> playersList;
  final bool showSuccess;

  const WinnerChoicePage({super.key, required this.playersList, this.showSuccess = true});

  @override
  State<WinnerChoicePage> createState() => _WinnerChoicePageState();
}

class _WinnerChoicePageState extends State<WinnerChoicePage> {
  late Game game;

  bool loading = false;
  bool btnLoading = false;

  List<List<Success>> oldSuccess = [];
  List<List<Success>> actualSuccess = [];

  @override
  void initState() {
    initGame();
    super.initState();
  }

  void initGame() async {
    Game resGame = await getGameById(AppConfig.game);
    setState(() {
      game = resGame;
    });
    if (widget.showSuccess) {
      loadOldSuccess();
    }
  }

  Future<void> loadOldSuccess() async {
    for (var user in widget.playersList) {
      if (user != null) {
        oldSuccess.add(await getAllSuccessByUserId(user.id));
      }
    }
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
    List<Level> levelList = await getAllLevelsActive();
    List<Prize> prizesList = await getAllPrizes();
    List<Success> successList = await getAllSuccess();
    int i = 0;
    try {
    for (var user in widget.playersList) {
      List<Success> oldSuccessUser = oldSuccess[i].where((element) => element.losable == false).toList();
      List<Success> validSuccess = [];
      if (user != null) {
        for (var success in successList) {
          if (success.losable || !oldSuccess[i].contains(success)) {
            if (success.type == 1 && success.evaluatePlay(user, plays, users, games, levelList)) {
              validSuccess.add(success);
            }
            if (success.type == 0 && success.evaluate(user, plays, users, games, levelList, prizesList, transactionsList)) {
              validSuccess.add(success);
            }
          }
        }
      }
      actualSuccess.add(oldSuccessUser + validSuccess);
      i++;
    }

    for (int i = 0; i < widget.playersList.length; i++) {
      User? player = widget.playersList[i];
      if (player != null) {
        String newSuccess = "";
        String loseSuccess = "";
        for (var success in successList){
          if (actualSuccess[i].any((element) => element.id == success.id) && !oldSuccess[i].any((element) => element.id == success.id)){
            insertUsersSuccess(player.id, success.id);
            newSuccess += "${success.libelle}, ";
          }
          if (oldSuccess[i].any((element) => element.id == success.id) && !actualSuccess[i].any((element) => element.id == success.id)){
            deleteUsersSuccess(player.id, success.id);
            loseSuccess += "${success.libelle}, ";
          }
        }
        if (newSuccess != ""){
          newSuccess = newSuccess.substring(0,newSuccess.length-2);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Nouveau succès ${player.username} : $newSuccess")));
        }
        if (loseSuccess != ""){
          loseSuccess = loseSuccess.substring(0,loseSuccess.length-2);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Succès perdu ${player.username} : $loseSuccess")));
        }
      }
    }} catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur du chargement des succès")));
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choix du gagnant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
      !loading ? ListView.builder(
        itemCount: widget.playersList.length,
        itemBuilder: (context, index) {
          return widget.playersList[index] != null ? Card(
            child: ListTile(
              enabled: !btnLoading,
              title: Text(widget.playersList[index]!.username),
              onTap: () async {
                setState(() {
                  btnLoading = true;
                });
                dynamic res = true;
                res = await Navigator.pushNamed(context, "/reward_multi", arguments: widget.playersList[index]);
                int cluster = await getLastCluster();
                if (res != null && res is bool && res) {
                  for (int i = 0; i < widget.playersList.length; i++) {
                    if (i != index && widget.playersList[i] != null) {
                      res = await updateUserBalance(widget.playersList[i]!, widget.playersList[i]!.balance - game.price) && res;
                      widget.playersList[i]?.balance = widget.playersList[i]!.balance - game.price;
                      res = await addPlays(AppConfig.game, 0, widget.playersList[i]!.id, cluster) && res;
                    }
                  }
                } else {
                  setState(() {
                    btnLoading = false;
                  });
                  Navigator.pop(context, false);
                }
                if (widget.showSuccess) {
                  await loadNewSuccess();
                }
                setState(() {
                  btnLoading = false;
                });
                Navigator.pop(context, res);
              },
            ),
          ) : null;
        },
      ) :  const Center(child: CircularProgressIndicator(),),
    );
  }
}
