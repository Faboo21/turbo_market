import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/type/game.dart';

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
        title: const Text('Choix du jeu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: gameList.isEmpty ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: gameList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(gameList[index].name),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setInt("gam_id", gameList[index].id);
                Navigator.pushReplacementNamed(context, "/home");
              },
            ),
          );
        },
      ),
    );
  }
}
