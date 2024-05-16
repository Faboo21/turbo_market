import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:gif/gif.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/level.dart';
import 'package:turbo_market/type/prize.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/stats_play.dart';
import 'package:turbo_market/type/success.dart';
import 'package:turbo_market/type/transaction.dart';

import '../type/game.dart';
import '../type/user.dart';
import '../type/user_rank.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> with TickerProviderStateMixin {
  List<UserRank> playersList = [];
  List<UserRank> filteredPlayersList = [];
  List<String> gamesList = [];
  List<Rarity> rarities = [];

  TextEditingController searchController = TextEditingController();
  String selectedGame = "All Games";
  String selectedTimeRange = 'All time';
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
    if (selectedTimeRange == "24h") {
      plays = await get24hStatsPlays();
    } else {
      plays = await getAllStatsPlays();
    }
    List<User> users = await getAllUsers();
    List<Rarity> raritiesList = await getAllRarities();
    List<Game> games = await getAllGames();
    List<String> resGamesId = List.generate(games.length, (index) => "${games[index].id} : ${games[index].name}");

    for (var user in users) {
      int nbGames = getNumberOfGames(plays, user.id);
      int score = getScore(plays, user.id);
      String favGame = getFavoriteGame(plays, user.id, games);
      setState(() {
        playersList.add(
            UserRank(id: user.id,
                username: user.username,
                balance: user.balance,
                mean: score/(nbGames == 0 ? 1 : nbGames),
                bestGame: favGame,
                nbGames: nbGames,
                success: [],
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

    if (successActivated) loadSuccess(users, plays, games);

    setState(() {
      filteredPlayersList = playersList;
      rarities = raritiesList;
      gamesList = ["All Games"] + resGamesId;
    });
    setState(() {
      loading = false;
    });
  }

  void loadSuccess(List<User> users, List<StatsPlay> plays, List<Game> games) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Chargement des succès"),
        );
      },
    );
    List<Transaction> transactionsList = await getAllTransactions();
    List<Level> levelList = await getAllLevels();
    List<Prize> prizesList = await getAllPrizes();
    List<Success> successList = await getAllSuccess();
    for (var user in users) {
      List<Success> validSuccess = [];
      for (var success in successList) {
        if (success.evaluate(user, plays, users, games, levelList, prizesList, transactionsList)) {
          validSuccess.add(success);
        }
      }
      validSuccess.sort((a, b) => b.rarity.value.compareTo(a.rarity.value));
      setState(() {
        filteredPlayersList.where((element) => element.id == user.id).first.success = validSuccess;
      });
    }
    Navigator.pop(context);
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
      floatingActionButton:
      IconButton(
        icon: const Icon(Icons.info),
        onPressed: () {
          Navigator.pushNamed(context, "/success");
        },
      ),
      body:
      Column(
        children: [
          Padding(
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
                          value: selectedTimeRange,
                          isExpanded: true,
                          onChanged: (newValue) {
                            setState(() {
                              selectedTimeRange = newValue!;
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
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              const Text("Activer les succès : "),
                              Checkbox(value: successActivated, onChanged: (newVal) {
                                setState(() {
                                  successActivated = newVal ?? false;
                                });
                                _loadPlayersList();
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ]
          ),
          const SizedBox(height: 15,),
          !loading ? Expanded(
            child: ListView.builder(
              itemCount: filteredPlayersList.length,
              itemBuilder: (context, index) {
                UserRank player = filteredPlayersList[index];
                return ExpansionTile(
                  leading: SizedBox(
                    width: 32, // Largeur fixe pour le conteneur du texte
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (index < 3) // Affiche l'icône de médaille pour les trois premiers joueurs
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            // Espace entre l'icône et le texte
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
                        'Solde: ${player.balance * AppConfig.rate} ƒ',
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