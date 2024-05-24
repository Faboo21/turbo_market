import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turbo_market/api/api_request.dart';
import 'package:turbo_market/private/config.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:turbo_market/type/api_type/game.dart';
import 'package:turbo_market/type/api_type/user.dart';

import '../api/game_request.dart';
import '../api/user_request.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<User?> playerList = List<User?>.filled(1, null);
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000, nbPlayersMin: 0, nbPlayersMax: 0, image: '');

  bool btnEndGameLoading = false;
  bool btnMngBalanceLoading = false;
  bool btnPrizesLoading = false;
  bool btnEmailLoading = false;

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
        playerList = List<User?>.filled(game.nbPlayersMax, null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Turbo Market"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [IconButton(onPressed: () {
          Navigator.pushReplacementNamed(context, "/choixGames");
        }, icon: const Icon(Icons.list))],
      ),
      body: homeBody(context),
      floatingActionButton: AppConfig.role == 3 ? FloatingActionButton(
        onPressed: () {
          _showModal(context);
        },
        child: const Icon(Icons.info),
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
        if (AppConfig.role == 3) ...[
          const SizedBox(height: 16.0),
          !btnEndGameLoading ? ElevatedButton(
            onPressed: checkMinPlayers() && checkPlayersBalance().isEmpty ? playerList.length > 1 ? () async {
              setState(() {
                btnEndGameLoading = true;
              });
              dynamic res = await Navigator.pushNamed(context, '/winner', arguments: playerList);
              if (res != null && res is bool && res == true) {} else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour des soldes")));
              }
              setState(() {
                btnEndGameLoading = false;
              });
            } : () async {
              setState(() {
                btnEndGameLoading = true;
              });
              dynamic result = await Navigator.pushNamed(context, "/reward", arguments: playerList[0]);
              if (result != null && result is bool && result == true) {

              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Probleme lors de la recuperation du gain')));
              }
              setState(() {
                btnEndGameLoading = false;
              });
            } : null,
            child: const Text("Résultat de la partie"),
          ) : const Center(child: CircularProgressIndicator(),),
        ],
        if ((AppConfig.role == 2 || AppConfig.role == 1) && playerList[0] != null) ...[
          const SizedBox(height: 16.0),
          !btnMngBalanceLoading ? ElevatedButton(
            onPressed: () async {
              setState(() {
                btnMngBalanceLoading = true;
              });
              Object? res = await Navigator.pushNamed(context, "/manage_balance", arguments: playerList[0]);
              if (res is bool) {
                if (res) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte mis à jour avec succès"),));
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour du compte"),));
                }
              }
              setState(() {
                btnMngBalanceLoading = false;
              });
            },
            child: const Text ('Recharger le compte'),
          ): const Center(child: CircularProgressIndicator(),),
          const SizedBox(height: 16.0),
          !btnPrizesLoading ? ElevatedButton(
            onPressed: () async {
              setState(() {
                btnPrizesLoading = true;
              });
              Object? res = await Navigator.pushNamed(context, "/prizes", arguments: playerList[0]);
              if (res is bool) {
                if (res) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recuperation des lots réussie"),));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de la recuperation des lots"),));
                }
              }
              setState(() {
                btnPrizesLoading = false;
              });
            },
            child: const Text ('Recuperer un lot'),
          ) : const Center(child: CircularProgressIndicator(),),
        ],
        if (AppConfig.role == 2 || AppConfig.role == 1) ...[
          const SizedBox(height: 15,),
          const Divider(),
          ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/ajout_user').then((res) async {
                  if (res != null && res is String) {
                    playerList[0] = await getUserByEmail(res);
                    setState(() {});
                  }
                });
              },
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.add),
              title: const Text("Créer Utilisateur")
          ),
          const Divider(),
          ListTile(
            onTap: () {
              _showEmailModal(context, "");
            },
            trailing: const Icon(Icons.arrow_forward_ios),
            leading: const Icon(Icons.email_outlined),
            title: const Text("QR perdu")
          ),
          const Divider(),
        ],
      ],
    );
  }

  bool checkMinPlayers() {
    int count = 0;
    for (var user in playerList) {
      if (user != null) {
        count++;
        if (count >= game.nbPlayersMin) {
          return true;
        }
      }
    }
    return false;
  }

  List<User> checkPlayersBalance() {
    // Créer un map pour stocker les occurrences de chaque joueur.
    final Map<User, int> playerCount = {};
    final List<User> insufficientBalancePlayers = [];

    // Compter les occurrences de chaque joueur dans la liste.
    for (var player in playerList) {
      if (player != null) {
        if (playerCount.containsKey(player)) {
          playerCount[player] = playerCount[player]! + 1;
        } else {
          playerCount[player] = 1;
        }
      }
    }

    // Vérifier si chaque joueur a assez de balance pour payer le nombre de parties équivalent à ses occurrences.
    for (var entry in playerCount.entries) {
      final player = entry.key;
      final count = entry.value;

      if (player.balance < game.price * count) {
        insufficientBalancePlayers.add(player);
      }
    }

    return insufficientBalancePlayers;
  }


  SizedBox playerListWidget() {
    return SizedBox(
      height: playerList.length <= 4 ? 65 * playerList.length + 20 : 65 * 4 + 20,
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
              User? getQrUser = await getUserByQr(res);
              if (getQrUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code QR non attribué")));
              } else {
                setState(() {
                  playerList[index] = checkUser(getQrUser) ?? getQrUser;
                });
              }
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
                  Text(
                    '${playerList[index]!.balance * AppConfig.rate}ƒ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: (AppConfig.game != 0 && checkPlayersBalance().contains(playerList[index])) ? Colors.red : Colors.white,
                    ),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        playerList[index] = null;
                      });
                    },
                    icon: const Icon(Icons.cancel, color: Colors.white,)
                  ),
                ],
              )
              : const Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded),
                  SizedBox(width: 30.0),
                  Text(
                    'Scanner un code QR',
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
          if (AppConfig.admin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
            ),
          if (AppConfig.admin)
            IconButton(
              icon: const Icon(Icons.query_stats),
              onPressed: () {
                Navigator.pushNamed(context, '/stats');
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
                AppConfig.token = "";
                AppConfig.role = 0;
                AppConfig.game = 0;
                Navigator.pushReplacementNamed(context, '/connexion');
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

  void _showEmailModal(BuildContext context, String errorMessage) {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Envoyer QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(fontFamily: "Nexa"),
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Adresse e-mail',
                  errorText: errorMessage.isNotEmpty ? errorMessage : null,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  btnEmailLoading = true;
                });
                String email = emailController.text.trim();
                if (isEmailValid(email)) {
                  if (await userExist(email)) {
                    bool res = await sendQr(email);
                    setState(() {
                      btnEmailLoading = false;
                    });
                    if (res) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email envoyé")));
                      Navigator.of(context).pop();
                    } else {
                      errorMessage = 'Probleme d\'envoi de l\'email';
                      Navigator.pop(context);
                      _showEmailModal(context, errorMessage);
                    }
                  } else {
                    errorMessage = 'E-mail non attribué';
                    Navigator.pop(context);
                    _showEmailModal(context, errorMessage);
                  }
                } else {
                  setState(() {
                    btnEmailLoading = false;
                  });
                  Navigator.pop(context);
                  _showEmailModal(context, "Adresse e-mail invalide");
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }


  bool isEmailValid(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  User? checkUser(User scannedUser) {
    return playerList.where((user) => user?.id == scannedUser.id).firstOrNull;
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
            'Prix : ${(game.price * AppConfig.rate).toString()}ƒ',
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
