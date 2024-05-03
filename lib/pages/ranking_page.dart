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

  TextEditingController searchController = TextEditingController();

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

  void _loadPlayersList() async {
    setState(() {
      playersList = [];
    });
    List<StatsPlay> plays = await getAllStatsPlays();
    List<User> users = await getAllUsers();
    List<Game> games = await getAllGames();
    List<UserTitle> titles = await getAllTitles();
    for (var user in users) {
      int nbGames = getNumberOfGames(plays, user.id);
      int nbVictories = getScore(plays, user.id);
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
                mean: nbVictories/(nbGames == 0 ? 1 : nbGames),
                bestGame: favGame,
                nbGames: nbGames,
                titles: validTitles,
                score: nbVictories));
      });
    }
    playersList.sort((a, b) => b.score.compareTo(a.score));
    setState(() {
      filteredPlayersList = playersList;
    });
  }

  int getNumberOfGames(List<StatsPlay> statsList, int userId) {
    int numberOfGames = 0;
    for (var stats in statsList) {
      if (stats.userId == userId) {
        numberOfGames++;
      }
    }
    return numberOfGames;
  }

  int getScore(List<StatsPlay> statsList, int userId) {
    int score = 0;
    for (var stats in statsList) {
      if (stats.userId == userId) {
        score += stats.score;
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
      body:
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: filterUsers,
                decoration: const InputDecoration(
                  labelText: 'Rechercher par username',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
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
                        trailing: Text('Moyenne: ${player.mean} p/g', style: const TextStyle(fontSize: 15),),
                      ),
                      if (player.titles.isNotEmpty) ListTile(
                        title: const Text('Titres:'),
                        subtitle: Wrap(
                          spacing: 8.0, // Espace entre chaque élément dans la ligne
                          runSpacing: 8.0, // Espace entre les lignes
                          children: [
                            for (var title in player.titles)
                              Container(
                                constraints: const BoxConstraints(minWidth: 0, minHeight: 0), // Taille minimale
                                padding: const EdgeInsets.all(8.0), // Ajoutez un padding pour l'espace intérieur
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(int.parse(title.color))), // Couleur de la bordure
                                  borderRadius: BorderRadius.circular(10), // Coins arrondis
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Pour réduire la taille du conteneur à son contenu
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: AspectRatio(
                                        aspectRatio: 1, // Aspect ratio 1:1 for square image
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
                                    Flexible( // Pour que le texte passe à la ligne s'il est trop long
                                      child: Text(
                                        title.libelle,
                                        style: TextStyle(color: Color(int.parse(title.color)), fontSize: 20),
                                        overflow: TextOverflow.ellipsis, // Tronquer le texte s'il est trop long
                                        maxLines: 1, // Limite le nombre de lignes à une seule ligne
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
