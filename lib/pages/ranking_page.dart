import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/rarity.dart';
import 'package:turbo_market/type/stats_play.dart';
import 'package:turbo_market/type/title.dart';

import '../type/game.dart';
import '../type/user.dart';
import '../type/user_rank.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<UserRank> playersList = [];
  List<UserRank> filteredPlayersList = [];
  List<String> gamesList = [];

  TextEditingController searchController = TextEditingController();
  String selectedGame = "All Games";
  String selectedTimeRange = 'All time';
  String sortedBy = 'Score';

  @override
  void initState() {
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
      case 'Balance':
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
      playersList = [];
    });
    List<StatsPlay> plays;
    if (selectedTimeRange == "24h") {
      plays = await get24hStatsPlays();
    } else {
      plays = await getAllStatsPlays();
    }
    List<User> users = await getAllUsers();
    List<Game> games = await getAllGames();
    List<UserTitle> titles = await getAllTitles();
    List<String> resGamesId = List.generate(games.length, (index) => "${games[index].id} : ${games[index].name}");
    for (var user in users) {
      int nbGames = getNumberOfGames(plays, user.id);
      int score = getScore(plays, user.id);
      String favGame = getFavoriteGame(plays, user.id, games);
      List<UserTitle> validTitles = [];
      for (var title in titles) {
        if (title.evaluate(user)) {
          validTitles.add(title);
        }
      }
      setState(() {
        playersList.add(
            UserRank(id: user.id,
                username: user.username,
                balance: user.balance,
                mean: score/(nbGames == 0 ? 1 : nbGames),
                bestGame: favGame,
                nbGames: nbGames,
                titles: validTitles,
                score: score));
      });
    }
    switch (sortedBy) {
      case 'Score':
        playersList.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'Balance':
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
      filteredPlayersList = playersList;
    });
    setState(() {
      gamesList = ["All Games"] + resGamesId;
    });
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Turbo Market'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [IconButton(onPressed: () {Navigator.pushNamed(context, "/connexion");}, icon: const Icon(Icons.lock_person))],
      ),
      floatingActionButton:
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            Navigator.pushNamed(context, "/titles");
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
              leading: const Icon(Icons.filter_alt),
              children: [
                SizedBox(
                  height: 200,
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
                          items: gamesList.map<DropdownMenuItem<String>>((String value) {
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
                          items: <String>['All time', '24h'].map<DropdownMenuItem<String>>((String value) {
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
                          items: <String>['Score', 'Balance', "Parties Jouée", "Moyenne"].map<DropdownMenuItem<String>>((String value) {
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
              ]
            ),
            const SizedBox(height: 15,),
            Expanded(
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
                              padding: const EdgeInsets.only(right: 8.0), // Espace entre l'icône et le texte
                              child: Icon(
                                FontAwesome5.medal,
                                color: index == 0 ? Colors.yellow : index == 1 ? Colors.grey : Colors.brown,
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
                    trailing: Text('${player.score} points', style: const TextStyle(fontSize: 20),),
                    children: [
                      ListTile(
                        title: Text('Meilleur jeu: ${player.bestGame}', style: const TextStyle(fontSize: 15),),
                        trailing: Text('Balance: ${player.balance * AppConfig.rate} ƒ', style: const TextStyle(fontSize: 15),),
                      ),
                      ListTile(
                        title: Text('Nombre de parties: ${player.nbGames.toString()}', style: const TextStyle(fontSize: 15),),
                        trailing: Text('Moyenne: ${player.mean.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15),),
                      ),
                      if (player.titles.isNotEmpty) ListTile(
                        title: const Text('Titres:'),
                        subtitle: Wrap(
                          spacing: 8.0, // Espace entre chaque élément dans la ligne
                          runSpacing: 8.0, // Espace entre les lignes
                          children: [
                            for (var title in player.titles)
                              Container(
                                constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: title.rarity.color),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: Image.network(
                                            title.image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5,),
                                    Flexible(
                                      child: Text(
                                        title.libelle,
                                        style: TextStyle(color: title.rarity.color, fontSize: 20),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            )
          ],
        ),
    );
  }
}
