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
  late List<User?> playerList;
  String? scannedQrId;
  User? scannedQrUser;
  bool isPlaying = false;
  late int role = 0;
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000, nbPlayers: 0);
  String result = '';

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? stockRole = prefs.getInt('tea_id');
    int? stockGame = prefs.getInt('gam_id');
    if (stockGame != null){
      Game getGame = await getGameById(stockGame);
      setState(() {
        game = getGame;
        playerList = List<User?>.filled(game.nbPlayers, null);
      });
    }
    setState(() {
      role = stockRole!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Turbo Market"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: homeBody(context),
      bottomNavigationBar: navBar(context),
    );
  }

  ListView homeBody(BuildContext context) {
    return ListView(
      children: [
        if (role == 3)
          NomJeu(game: game),
        if (role == 3 && game.nbPlayers > 1 && role == 3)
          playerListWidget(),
        if (role == 3 && game.nbPlayers > 1 && !isPlaying)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
            onPressed: playerList.every((player) => player != null) && playerList.every((player) => player!.balance >= game.price) ? () {
              setState(() {
                isPlaying = true;
              });
            }
            : null,
            child: const Text('Lancer la partie'),
            ),
          ),
        if (role == 3 && game.nbPlayers > 1 && isPlaying)
          ElevatedButton(
          onPressed: () async {
             dynamic res = await Navigator.pushNamed(context, '/winner', arguments: playerList);
             try {
               if (res is User) {
                 for (int i = 0; i < playerList.length; i++) {
                   if (playerList[i] == res) {
                     await updateUserBalance(playerList[i]!, playerList[i]!.balance - game.price + (game.price * game.nbPlayers) * 0.75);
                   } else {
                     await updateUserBalance(playerList[i]!, playerList[i]!.balance - game.price);
                   }
                 }
               }
               setState(() {
                 isPlaying = false;
                 for (int i = 0; i < playerList.length; i++) {
                   playerList[i] = null;
                 }
               });
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Partie terninée avec Succés")));
             } on Exception {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Probleme de mise à jours des soldes")));
             }
          },
          child: const Text("Terminer la partie"),
        ),
        if (role == 3 && game.nbPlayers > 1 && isPlaying)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text('Êtes-vous sûr de vouloir annuler la partie ?'),
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Partie Annulée")));
                            Navigator.of(context).pop();
                          },
                          child: const Text('Confirmer'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Annuler la partie"),
            ),
          ),

        if (scannedQrId != null)
          Column(
            children: [
              Text(
                'Scanned QR ID: $scannedQrId',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

        if (scannedQrUser != null)
          Column(
            children: [
              Text(
                'QR de ${scannedQrUser?.username}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Solde : ${scannedQrUser!.balance * AppConfig.taux}',
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

        if (scannedQrUser == null && scannedQrId != null)
          const Column(
            children: [
              Text(
                'Code QR non attribué',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && !isPlaying)
          launchGameButton(),
        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && isPlaying)
          endGameButton(context),
        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && isPlaying)
          cancelGameButton(context),
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

  ElevatedButton endGameButton(BuildContext context) {
    return ElevatedButton(
          onPressed: () async {
            dynamic result = await Navigator.pushNamed(context, "/reward", arguments: scannedQrUser);
            if (result != null && result is bool && result == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recuperation du gain réussi')));
              setState(() {
                scannedQrUser = null;
                scannedQrId = null;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Probleme lors de la recuperation du gain')));
            }
          },
          child: const Text("Terminer la partie"),
        );
  }

  Padding launchGameButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: scannedQrUser!.balance >= game.price
            ? () {
          setState(() {
            isPlaying = true;
          });
        } : null,
        child: const Text("Démarrer la partie"),
      ),
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
                            (playerList[index]!.balance * AppConfig.taux).toString(),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
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
          if (role == 2 || role == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                Navigator.pushNamed(context, '/ajout_user');
              },
            ),
          IconButton(
            icon: Image.asset('images/logo-obsolete-noir.png', fit: BoxFit.cover,),
            onPressed: () async {
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleBarcodeScannerPage(),
                  ));
                if (res is String) {
                  var getQrUser = await getUserByQr(res);
                  setState(() {
                    scannedQrId = res;
                    scannedQrUser = getQrUser;
                  });
                }
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
                prefs.remove('tea_id');
                prefs.remove('date');
                prefs.remove('gam_id');
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Déconnexion'),
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
            'Jeu : ${game.name}',
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
