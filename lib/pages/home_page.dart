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
  late Game game = Game(id: 0, name: "Chargement", rules: "rules", createdAt: "createdAt", price: 1000000000000, nbPlayersMin: 0, nbPlayersMax: 0, image: '');

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
        automaticallyImplyLeading: AppConfig.role == 3,
        title: const Text("Turbo Market"),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
        if (AppConfig.role == 3 && !isPlaying) ...[
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: checkMinPlayers() && checkPlayersBalance() ? () {
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de mise à jour des soldes")));
                }
            } : () async {
              dynamic result = await Navigator.pushNamed(context, "/reward", arguments: playerList[0]);
              if (result != null && result is bool && result == true) {
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
        if ((AppConfig.role == 2 || AppConfig.role == 1) && playerList[0] != null) ...[
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
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () async {
              Object? res = await Navigator.pushNamed(context, "/prizes", arguments: playerList[0]);
              if (res is bool) {
                if (res) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recuperation des lots réussie"),));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Problème de la recuperation des lots"),));
                }
              }
            },
            child: const Text ('Recuperer un lot'),
          ),
        ],
        if (AppConfig.role == 2 || AppConfig.role == 1) ...[
          const SizedBox(height: 15,),
          const Divider(),
          ListTile(
              onTap: () {
                Navigator.pushNamed(context, '/ajout_user');
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

  bool checkPlayersBalance() {
    for (var player in playerList) {
      if (player != null && player.balance < game.price) {
        return false;
      }
    }
    return true;
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
                    '${playerList[index]!.balance * AppConfig.rate} ƒ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: (AppConfig.game != 0 && game.price > playerList[index]!.balance) ? Colors.red : Colors.white,
                    ),
                  ),IconButton(
                      onPressed: () {
                        setState(() {
                          playerList[index] = null;
                        });
                      },
                      icon: const Icon(Icons.cancel, color: Colors.white,)),
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
          if (AppConfig.role == 1)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
            ),
          if (AppConfig.role == 1)
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
                String email = emailController.text.trim();
                if (isEmailValid(email)) {
                  if (await userExist(email)) {
                    bool res = await sendQr(email);
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
            'Prix : ${(game.price * AppConfig.rate).toString()}',
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
