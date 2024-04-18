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
      ListView.builder(
        itemCount: widget.playersList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(widget.playersList[index]!.username),
              onTap: () async {
                dynamic res = true;
                res = await Navigator.pushNamed(context, "/reward", arguments: widget.playersList[index]);
                if (res != null && res is bool && res == true) {
                  for (int i = 0; i < widget.playersList.length; i++) {
                    if (i != index) {
                      res = await updateUserBalance(widget.playersList[i]!, widget.playersList[i]!.balance - game.price) && res;
                      res = await addPlays(AppConfig.game, 0, widget.playersList[i]!.id) && res;
                    }
                  }
                } else {
                  Navigator.pop(context, false);
                }
                Navigator.pop(context, res);
              },
            ),
          );
        },
      ),
    );
  }
}
