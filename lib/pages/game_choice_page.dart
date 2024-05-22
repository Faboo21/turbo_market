import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
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
        automaticallyImplyLeading: false,
        title: const Text('Choix du jeu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: gameList.isEmpty ? const Center(child: CircularProgressIndicator()) :
      ListView.builder(
        itemCount: gameList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(gameList[index].name),
              onTap: () async {
                AppConfig.game = gameList[index].id;
                Navigator.pushNamed(context, "/home");
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('token');
                AppConfig.role = 0;
                AppConfig.game = 0;
                AppConfig.token = "";
                Navigator.pushReplacementNamed(context, '/connexion');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}
