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
        if (role == 3)Column(children: [Text("Jeu : ${game.name}, Prix : ${(game.price * AppConfig.taux).toString()}"),],),
        if (scannedQrId != null) Column(children: [Text('Scanned QR ID: $scannedQrId'),],),
        if (scannedQrUser != null)Column(children: [Text('QR de ${scannedQrUser?.username}'), Text("Solde : ${scannedQrUser!.balance * AppConfig.taux}")],),
        if (scannedQrUser == null && scannedQrId != null)const Column(children: [Text("Code QR non attribué"),],),
        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && !isPlaying)
          ElevatedButton(
              onPressed: scannedQrUser!.balance >= game.price
                  ? () {
                setState(() {
                  isPlaying = true;
                });
              } : null,
              child: const Text("Démarrer la partie"),
          ),
        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && isPlaying)
          ElevatedButton(
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
          ),
        if (scannedQrUser != null && role == 3 && game.nbPlayers == 1 && isPlaying)
          ElevatedButton(
            onPressed: () {
              setState(() {
                isPlaying = false;
                scannedQrId = null;
                scannedQrUser = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Partie Annulée")));
            },
            child: const Text("Annuler la partie"),
          ),
      ],
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
