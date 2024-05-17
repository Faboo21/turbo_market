import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import '../api/api_request.dart';
import '../type/game.dart';
import '../type/level.dart';
import '../type/prize.dart';
import '../type/stats_play.dart';
import '../type/success.dart';
import '../type/transaction.dart';
import '../type/user.dart';

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
    for (var user in widget.playersList) {
      List<Success> validSuccess = [];
      if (user != null) {
        for (var success in successList) {
          if (success.evaluate(user, plays, users, games, levelList, prizesList, transactionsList)) {
            validSuccess.add(success);
          }
        }
      }
      oldSuccess.add(validSuccess);
    }
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
    for (var user in widget.playersList) {
      List<Success> validSuccess = [];
      if (user != null) {
        for (var success in successList) {
          if (success.evaluate(user, plays, users, games, levelList, prizesList, transactionsList)) {
            validSuccess.add(success);
          }
        }
      }
      actualSuccess.add(validSuccess);
    }

    for (int i = 0; i < widget.playersList.length; i++) {
      User? player = widget.playersList[i];
      if (player != null) {
        for (var success in successList){
          String newSuccess = "";
          String loseSuccess = "";
          if (actualSuccess[i].any((element) => element.id == success.id) && !oldSuccess[i].any((element) => element.id == success.id)){
            newSuccess += "${success.libelle}, ";
          }
          if (oldSuccess[i].any((element) => element.id == success.id) && !actualSuccess[i].any((element) => element.id == success.id)){
            loseSuccess += "${success.libelle}, ";
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
      }
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
                if (res != null && res is bool && res) {
                  for (int i = 0; i < widget.playersList.length; i++) {
                    if (i != index && widget.playersList[i] != null) {
                      await Future.delayed(const Duration(seconds: 1));
                      res = await updateUserBalance(widget.playersList[i]!, widget.playersList[i]!.balance - game.price) && res;
                      widget.playersList[i]?.balance = widget.playersList[i]!.balance - game.price;
                      res = await addPlays(AppConfig.game, 0, widget.playersList[i]!.id) && res;
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
