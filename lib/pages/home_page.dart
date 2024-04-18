import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:turbo_market/type/game.dart';
import 'package:turbo_market/type/user.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User?> playerList = List<User?>.filled(1, null);
  bool isPlaying = false;
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000, nbPlayers: 0);

  @override
  void initState() {
    super.initState();
    loadGame();
  }

  Future<void> loadGame() async {
    if (AppConfig.game != 0){
      Game getGame = await getGameById(AppConfig.game);
      setState(() {
        game = getGame;
        playerList = List<User?>.filled(game.nbPlayers, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: AppConfig.role == 3,
        title: const Text("Turbo Market"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: homeBody(context),
      floatingActionButton: AppConfig.role == 3 ?FloatingActionButton(
        onPressed: () {
          _showModal(context);
        },
        child: const Icon(Icons.info), // Couleur du bouton flottant
      ) : null,
      bottomNavigationBar: navBar(context),
    );
  }

  ListView homeBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        if (AppConfig.role == 3) ...[
          const SizedBox(height: 8.0),
          NomJeu(game: game),
        ],
        const SizedBox(height: 16.0),
        playerListWidget(),
        if (AppConfig.role == 3 && !isPlaying) ...[
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: playerList.every((player) => player != null) && playerList.every((player) => player!.balance >= game.price) ? () {
              setState(() {
                isPlaying = true;
              });
            } : null,
            child: const Text('Lancer la partie'),
          ),
        ],
        if (AppConfig.role == 3 && isPlaying) ...[
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: playerList.length > 1 ? () async {
              dynamic res = await Navigator.pushNamed(context, '/winner', arguments: playerList);
                if (res != null && res is bool && res == true) {
                  setState(() {
                    isPlaying = false;
                    for (int i = 0; i < playerList.length; i++) {
                      playerList[i] = null;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Partie terminée avec succès")));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour des soldes")));
                }
            } : () async {
              dynamic result = await Navigator.pushNamed(context, "/reward", arguments: playerList[0]);
              if (result != null && result is bool && result == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recuperation du gain réussi')));
                setState(() {
                  isPlaying = false;
                  for (int i = 0; i < playerList.length; i++) {
                    playerList[i] = null;
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Probleme lors de la recuperation du gain')));
              }
            },
            child: const Text("Terminer la partie"),
          ),
        ],
        if (AppConfig.role == 3 && isPlaying) ...[
          const SizedBox(height: 16.0),
          cancelGameButton(context),
        ],
        if (AppConfig.role == 2 || AppConfig.role == 1 && playerList[0] != null) ...[
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              Object? res = await Navigator.pushNamed(context, "/manage_balance", arguments: playerList[0]);
              if (res is bool) {
                if (res) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte mis à jour avec succès"),));
                  setState(() {
                    for (int i = 0; i < playerList.length; i++) {
                      playerList[i] = null;
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du compte"),));
                }
              }
            },
            child: const Text ('Recharger le compte'),
          ),
        ],
      ],
    );
  }


  ElevatedButton cancelGameButton(BuildContext context) {
    return ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context)
            {
              return AlertDialog(
                title: const Text('Confirmation'),
                content: const Text(
                    'Êtes-vous sûr de vouloir annuler la partie ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isPlaying = false;
                        for (int i = 0; i < playerList.length; i++) {
                          playerList[i] = null;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Partie Annulée")));
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text('Confirmer'),
                  ),
                ],
              );
            });
          },
          child: const Text("Annuler la partie"),
        );
  }

  SizedBox playerListWidget() {
    return SizedBox(
      height: playerList.length <= 8 ? 65 * playerList.length + 20 : 65 * 8 + 20,
      child: ListView.builder(
      itemCount: playerList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            var res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleBarcodeScannerPage(),
              ),
            );
            if (res is String) {
              var getQrUser = await getUserByQr(res);
              if (getQrUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code QR non attribué")));
              }
              setState(() {
                playerList[index] = getQrUser;
              });
            }
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: playerList[index] != null
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    playerList[index]!.username,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 16.0),
                  Text(
                    '${playerList[index]!.balance * AppConfig.taux} ƒ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: (AppConfig.game != 0 && game.price > playerList[index]!.balance) ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              )
                  : const Row(
                    children: [
                      Icon(Icons.qr_code_scanner_rounded),
                      SizedBox(width: 30.0),
                      Text(
                        'Ajouter un joueur',
                        style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
            ),
          ),
        );
      }
      ),
    );
  }

  BottomAppBar navBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (AppConfig.role == 2 || AppConfig.role == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                Navigator.pushNamed(context, '/ajout_user');
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
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
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
  void _showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Regles du jeu : ${game.name}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(game.rules),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

}

class NomJeu extends StatelessWidget {
  const NomJeu({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(
            game.name,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Prix : ${(game.price * AppConfig.taux).toString()}',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
