import 'dart:core';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/level.dart';

import '../type/game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<Game> gamesList = [];
  List<List<Level>> levelsList = [];

  @override
  void initState() {
    loadGames();
    super.initState();
  }

  void loadGames() async {
    List<Game> resGamesList = await getAllGames();
    List<List<Level>> resLevelsList = [];
    for (var game in resGamesList) {
      resLevelsList.add(await getAllLevelsByGame(game.id));
    }
    setState(() {
      gamesList = resGamesList;
      levelsList = resLevelsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return gamesList.isNotEmpty ? ListView.builder(
      itemCount: gamesList.length,
      itemBuilder: (context, index) {
        Game game = gamesList[index];
        List<Level> levels = levelsList[index];
        return
          ExpansionTile(
            leading: game.image != "" ? AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  game.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          // Vous pouvez personnaliser l'indicateur de chargement selon vos besoins
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ) : const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(FontAwesome5.gamepad, color: Colors.white,),
            ),
            title: Text(game.name),
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(game.rules,),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: levels.map((level) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Niveau ${level.step} : ${level.libelle == "" ? "${level.cashPrize*AppConfig.rate} ƒ" : level.libelle}'),
                        Text('${level.score} points')
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
      },
    ) : const Center(child: CircularProgressIndicator(),);
  }
}
