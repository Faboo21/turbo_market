import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:gif/gif.dart';
import 'package:turbo_market/api/success_request.dart';
import 'package:turbo_market/api/users_success_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/api/game_request.dart';
import 'package:turbo_market/api/rarity_request.dart';
import 'package:turbo_market/api/stats_play_request.dart';
import 'package:turbo_market/api/user_request.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/rarity.dart';
import 'package:turbo_market/type/api_type/stats_play.dart';
import 'package:turbo_market/type/api_type/success.dart';
import 'package:turbo_market/type/api_type/user.dart';
import 'package:turbo_market/type/api_type/user_rank.dart';
import 'package:turbo_market/type/api_type/users_success.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key, required this.viewOnly});
  final bool viewOnly;
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with TickerProviderStateMixin {
  List<UserRank> playersList = [];
  List<UserRank> filteredPlayersList = [];
  List<String> gamesList = [];
  List<Rarity> rarities = [];
  List<Success> success = [];

  TextEditingController searchController = TextEditingController();
  String selectedGame = "All Games";
  String sortedBy = 'Score';

  bool loading = true;
  bool successActivated = false;

  late GifController _controller;

  @override
  void initState() {
    setState(() {
      _controller = GifController(vsync: this);
    });
    _loadPlayersList();
    super.initState();
    if (widget.viewOnly) {
      Timer.periodic(const Duration(seconds: 10), (timer) {
        setState(() {
          _loadPlayersList();
        });
      });
    }

  }

  void filterUsers(String query) {
    List<UserRank> filteredPlayers = playersList.where((user) => user.username.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredPlayersList = filteredPlayers;
    });
  }

  void sortUsers() {
    switch (sortedBy) {
      case 'Score':
        setState(() {
          filteredPlayersList.sort((a, b) => b.score.compareTo(a.score));
        });
        break;
      case 'Solde':
        setState(() {
          filteredPlayersList.sort((a, b) => b.balance.compareTo(a.balance));
        });
        break;
      case 'Parties Jouée':
        setState(() {
          filteredPlayersList.sort((a, b) => b.nbGames.compareTo(a.nbGames));
        });
        break;
      case 'Moyenne':
        setState(() {
          filteredPlayersList.sort((a, b) => b.mean.compareTo(a.mean));
        });
        break;
    }
  }

  void _loadPlayersList() async {
    setState(() {
      loading = true;
      playersList = [];
    });
    List<StatsPlay> plays;
    if (AppConfig.selectedTimeRange == "24h") {
      plays = await get24hStatsPlays();
    } else {
      plays = await getAllStatsPlays();
    }
    List<User> users = await getAllUsers();
    List<Rarity> raritiesList = await getAllRarities();
    List<Game> games = await getAllGames();
    List<String> resGamesId = List.generate(games.length, (index) => "${games[index].id} : ${games[index].name}");
    List<Success> successList = await getAllSuccess();
    List<UsersSuccess> links = await getAllUserSuccess();

    for (var user in users) {
      int nbGames = getNumberOfGames(plays, user.id);
      int score = getScore(plays, user.id);
      String favGame = getFavoriteGame(plays, user.id, games);
      List<Success> success = await loadSuccess(user.id, links, successList);
      setState(() {
        playersList.add(
          UserRank(id: user.id,
            username: user.username,
            balance: user.balance,
            mean: score/(nbGames == 0 ? 1 : nbGames),
            bestGame: favGame,
            nbGames: nbGames,
            success: success,
            score: score,
            email: user.email
          ));
      });
    }

    switch (sortedBy) {
      case 'Score':
        playersList.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'Solde':
        playersList.sort((a, b) => b.balance.compareTo(a.balance));
        break;
      case 'Parties Jouée':
        playersList.sort((a, b) => b.nbGames.compareTo(a.nbGames));
        break;
      case 'Moyenne':
        playersList.sort((a, b) => b.mean.compareTo(a.mean));
        break;
    }

    setState(() {
      success = successList;
      filteredPlayersList = playersList;
      rarities = raritiesList;
      gamesList = ["All Games"] + resGamesId;
    });
    setState(() {
      loading = false;
    });
  }

  Future<List<Success>> loadSuccess(int userId, List<UsersSuccess> links, List<Success> success) async {
    List<Success> resList = [];
    for (var link in links) {
      if (link.usrId == userId) {
        resList.add(success.where((e) => e.id == link.titId).first);
      }
    }
    return resList.sorted((a,b) => b.rarity.value.compareTo(a.rarity.value));
  }

  int getNumberOfGames(List<StatsPlay> statsList, int userId) {
    int numberOfGames = 0;
    for (var stats in statsList) {
      if (stats.userId == userId) {
        if (selectedGame == "All Games") {
          numberOfGames++;
        }
        else {
          if (stats.gameid == int.parse(selectedGame.split(" : ")[0])) {
            numberOfGames++;
          }
        }
      }
    }
    return numberOfGames;
  }

  int getScore(List<StatsPlay> statsList, int userId) {
    int score = 0;
    for (var stats in statsList) {
      if (stats.userId == userId) {
        if (selectedGame == "All Games") {
          score += stats.score;
        }
        else {
          if (stats.gameid == int.parse(selectedGame.split(" : ")[0])) {
            score += stats.score;
          }
        }
      }
    }
    return score;
  }

  Game? findGameById(int id, List<Game> gameList) {
    for (var game in gameList) {
      if (game.id == id) {
        return game;
      }
    }
    return null;
  }

  int getMaxGameId(List<Game> gameList) {
    int maxId = 0;
    for (var game in gameList) {
      if (game.id > maxId) {
        maxId = game.id;
      }
    }
    return maxId;
  }

  String getFavoriteGame(List<StatsPlay> statsList, int userId, List<Game> games) {
    List<int> listTot = List.filled(getMaxGameId(games) + 1, 0);
    for (var stats in statsList) {
      if (stats.userId == userId) {
        listTot[stats.gameid]++;
      }
    }
    return findGameById(listTot.indexOf(listTot.max), games)?.name ?? "aucun";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !widget.viewOnly ?
      IconButton(
        icon: const Icon(Icons.info, size: 40,),
        onPressed: () {
          Navigator.pushNamed(context, "/success", arguments: success);
        },
      ) : null,
      body:
      Column(
        children: [
          if (!widget.viewOnly) ...[Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterUsers,
                    decoration: const InputDecoration(
                      labelText: 'Rechercher par pseudo',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(onPressed: () {
                    _loadPlayersList();
                  },
                      icon: const Icon(Icons.refresh, size: 40,)
                  ),
                )
              ],
            ),
          ),
          ExpansionTile(
            title: const Text("Filtrer"),
            leading: const Icon(Icons.filter_alt, color: Colors.white,),
            children: [
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        padding: const EdgeInsets.all(5),
                        isExpanded: true,
                        value: selectedGame,
                        onChanged: (newValue) {
                          setState(() {
                            selectedGame = newValue!;
                          });
                          _loadPlayersList();
                        },
                        items: gamesList.map<DropdownMenuItem<String>>((
                            String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        padding: const EdgeInsets.all(5),
                        value: AppConfig.selectedTimeRange,
                        isExpanded: true,
                        onChanged: (newValue) {
                          setState(() {
                            AppConfig.selectedTimeRange = newValue!;
                          });
                          _loadPlayersList();
                        },
                        items: <String>['All time', '24h'].map<
                            DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        padding: const EdgeInsets.all(5),
                        isExpanded: true,
                        value: sortedBy,
                        onChanged: (newValue) {
                          setState(() {
                            sortedBy = newValue!;
                          });
                          sortUsers();
                        },
                        items: <String>[
                          'Score',
                          'Solde',
                          "Parties Jouée",
                          "Moyenne"
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 15,),
          ],
          !loading || widget.viewOnly ? Expanded(
            child: ListView.builder(
              itemCount: filteredPlayersList.length,
              itemBuilder: (context, index) {
                UserRank player = filteredPlayersList[index];
                return ExpansionTile(
                  leading: SizedBox(
                    width: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (index < 3)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              FontAwesome5.medal,
                              color: index == 0 ? Colors.yellow : index == 1
                                  ? Colors.grey
                                  : Colors.brown,
                            ),
                          ),
                        if (index >= 3) ...[
                          Text(
                            (index + 1).toString(),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10,)
                        ]
                      ],
                    ),
                  ),
                  title: Text(player.username),
                  trailing: Text('${player.score} points',
                    style: const TextStyle(fontSize: 20),),
                  children: [
                    ListTile(
                      title: Text('Meilleur jeu: ${player.bestGame}',
                        style: const TextStyle(fontSize: 15),),
                    ),
                    ListTile(
                      title: Text(
                        'Solde: ${player.balance * AppConfig.rate}ƒ',
                        style: const TextStyle(fontSize: 15),),
                    ),
                    ListTile(
                      title: Text(
                        'Nombre de parties: ${player.nbGames.toString()}',
                        style: const TextStyle(fontSize: 15),),
                    ),
                    ListTile(
                      title: Text(
                        'SCORE MOYEN PARTIE: ${player.mean.toStringAsFixed(2)} points',
                        style: const TextStyle(fontSize: 15),),
                    ),
                    if (player.success.isNotEmpty) ListTile(
                      title: const Text('Succès:'),
                      subtitle: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (var success in player.success) ...[
                            success.rarity.id != rarities.last.id ?
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius
                                        .circular(50),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      color: success.rarity.displayColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        child:
                                          Image.network(
                                          "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                          width: 20,
                                          height: 20,
                                          ),
                                      ),
                                    ),
                                  ),
                                ]
                              ) : Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius
                                        .circular(50),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red,
                                            Colors.orange,
                                            Colors.yellow,
                                            Colors.green,
                                            Colors.blue,
                                            Colors.indigo,
                                            Colors.purple,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          stops: [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        child:
                                        Image.network(
                                          "${success.image}?random=${DateTime.now().millisecondsSinceEpoch}",
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                    child: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child:
                                      Gif(
                                        image: const AssetImage(
                                            "images/giphy.gif"),
                                        controller: _controller,
                                        // if duration and fps is null, original gif fps will be used.
                                        //fps: 30,
                                        //duration: const Duration(seconds: 3),
                                        autostart: Autostart.loop,
                                        placeholder: (context) =>
                                        const Text('Loading...'),
                                        onFetchCompleted: () {
                                          _controller.reset();
                                          _controller.forward();
                                        },
                                      ),
                                    ),
                                  )
                                ]
                            ),
                          ],
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ) : const Center(child: CircularProgressIndicator(),)
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}