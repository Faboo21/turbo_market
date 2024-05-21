import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/level.dart';

import '../type/game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key, required this.viewMode});

  final bool viewMode;

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<Game> gamesList = [];
  List<List<Level>> levelsList = [];

  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  final double _scrollSpeed = 30;
  bool _scrollingDown = true;

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      double minScrollExtent = _scrollController.position.minScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double scrollIncrement = _scrollSpeed * 0.05;

      if (_scrollingDown) {
        if (currentScroll + scrollIncrement >= maxScrollExtent) {
          _scrollingDown = false;
        } else {
          _scrollController.animateTo(
            currentScroll + scrollIncrement,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      } else {
        if (currentScroll - scrollIncrement <= minScrollExtent) {
          _scrollingDown = true;
        } else {
          _scrollController.animateTo(
            currentScroll - scrollIncrement,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
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
      if (widget.viewMode) {
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            body: gamesList.isNotEmpty ? ListView.builder(
              controller: widget.viewMode ? _scrollController : null,
              itemCount: gamesList.length,
              itemBuilder: (context, index) {
                Game game = gamesList[index];
                List<Level> levels = levelsList[index];
                return
                  ExpansionTile(
                      initiallyExpanded: widget.viewMode,
                      leading: game.image != "" ? AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "${game.image}?random=${DateTime.now().millisecondsSinceEpoch}",
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
                        constraints.maxWidth > 1200 ?
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.green, Colors.yellowAccent, Colors.orangeAccent, Colors.red]),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: levels.map((level) {
                                if (level.step != 0) {
                                  return Column(
                                    children: [
                                      Text("Lvl ${level.step}", style: const TextStyle(color: Colors.black),),
                                      Text(level.libelle == "" ? "${level.cashPrize*AppConfig.rate}ƒ" : level.libelle, style: const TextStyle(color: Colors.black),),
                                      Text("${level.score} pts", style: const TextStyle(color: Colors.black),)
                                    ],
                                  );}
                                return const SizedBox(width: 0,);
                              }).toList(),
                            ),
                          ),
                        ) : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.yellowAccent, Colors.orangeAccent, Colors.red],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: Column(
                              children: levels.map((level) {
                                if (level.step != 0) {
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Lvl ${level.step}", style: const TextStyle(color: Colors.black),),
                                            Text(level.libelle == "" ? "${level.cashPrize*AppConfig.rate}ƒ" : "${level.libelle}", style: const TextStyle(color: Colors.black),),
                                            Text("${level.score} pts", style: const TextStyle(color: Colors.black),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );}
                                return const SizedBox(width: 0,);
                              }).toList(),
                            ),
                          ),
                        ),
                      ]
                  );
              },
            ) : const Center(child: CircularProgressIndicator(),),
          );
        },
    );
  }
}
