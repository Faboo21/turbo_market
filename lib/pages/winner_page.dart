import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import '../api/api_request.dart';
import '../type/game.dart';
import '../type/user.dart';

class WinnerChoicePage extends StatefulWidget {
  const WinnerChoicePage({super.key, required this.playersList});
  final List<User?> playersList;

  @override
  State<WinnerChoicePage> createState() => _WinnerChoicePageState();
}

class _WinnerChoicePageState extends State<WinnerChoicePage> {
  late Game game;

  bool loading = false;
  bool btnLoading = false;

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
                res = await Navigator.pushNamed(context, "/reward", arguments: widget.playersList[index]);
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
