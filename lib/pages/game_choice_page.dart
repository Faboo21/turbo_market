import 'package:flutter/material.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/type/api_type/game.dart';

class GameChoicePage extends StatefulWidget {
  const GameChoicePage({super.key});

  @override
  State<GameChoicePage> createState() => _GameChoicePageState();
}

class _GameChoicePageState extends State<GameChoicePage> {
  List<Game> gameList = [];

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    var resGameList = await getAllGames();
    setState(() {
      gameList = resGameList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context) ? IconButton(onPressed: () {
          Navigator.pushReplacementNamed(context, "/home");
        },icon: const Icon(Icons.arrow_back),) : null,
        title: const Text('Choix du jeu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: gameList.isEmpty ? const Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: gameList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(gameList[index].name),
                    onTap: () async {
                      AppConfig.role = 3;
                      AppConfig.game = gameList[index].id;
                      Navigator.pushNamed(context, "/home");
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
